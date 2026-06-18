"""Create transaction monitoring features from cleaned transaction data.

Default input:
    data/processed/clean_transactions.csv

Default output:
    data/processed/transaction_features.csv
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd


DEFAULT_INPUT_PATH = Path("data/processed/clean_transactions.csv")
DEFAULT_OUTPUT_PATH = Path("data/processed/transaction_features.csv")


RISK_RATING_MAP = {"Low": 1, "Medium": 2, "High": 3}


def load_clean_transactions(input_path: Path) -> pd.DataFrame:
    df = pd.read_csv(input_path)
    df["transaction_ts"] = pd.to_datetime(df["transaction_ts"], errors="coerce")
    return df.sort_values(["account_id", "transaction_ts", "transaction_id"]).reset_index(drop=True)


def _rolling_count_by_time(group: pd.DataFrame, window: str) -> pd.Series:
    indexed = group.set_index("transaction_ts")
    counts = indexed["transaction_id"].rolling(window=window, closed="both").count()
    return pd.Series(counts.to_numpy(), index=group.index)


def _prior_unique_count(group: pd.DataFrame, column: str) -> pd.Series:
    seen: set[object] = set()
    counts = []
    for value in group[column]:
        counts.append(len(seen))
        if pd.notna(value):
            seen.add(value)
    return pd.Series(counts, index=group.index)


def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    features = df.copy()
    features = features.sort_values(["account_id", "transaction_ts", "transaction_id"]).reset_index(drop=True)

    account_groups = features.groupby("account_id", group_keys=False)
    features["prior_account_avg_amount"] = account_groups["amount"].transform(
        lambda s: s.shift(1).expanding(min_periods=1).mean()
    )
    features["prior_account_std_amount"] = account_groups["amount"].transform(
        lambda s: s.shift(1).expanding(min_periods=2).std()
    )
    features["prior_account_max_amount"] = account_groups["amount"].transform(
        lambda s: s.shift(1).expanding(min_periods=1).max()
    )
    features["account_transaction_sequence"] = account_groups.cumcount() + 1

    features["transactions_last_hour"] = 0.0
    features["transactions_last_24h"] = 0.0
    for _, group in features.groupby("account_id", sort=False):
        features.loc[group.index, "transactions_last_hour"] = _rolling_count_by_time(group, "1h")
        features.loc[group.index, "transactions_last_24h"] = _rolling_count_by_time(group, "24h")

    features["amount_z_score"] = (
        (features["amount"] - features["prior_account_avg_amount"]) / features["prior_account_std_amount"]
    ).replace([np.inf, -np.inf], np.nan)
    features["amount_to_prior_avg_ratio"] = (
        features["amount"] / features["prior_account_avg_amount"]
    ).replace([np.inf, -np.inf], np.nan)

    features["merchant_risk_score"] = features["merchant_risk_rating"].map(RISK_RATING_MAP).fillna(1).astype(int)
    features["kyc_risk_score"] = features["kyc_risk_rating"].map(RISK_RATING_MAP).fillna(1).astype(int)

    features["country_mismatch_flag"] = features["transaction_country"] != features["customer_country"]
    features["night_transaction_flag"] = features["transaction_hour"].between(0, 5)
    features["high_risk_merchant_flag"] = features["merchant_risk_rating"] == "High"
    features["card_not_present_flag"] = ~features["is_card_present"].astype(bool)
    features["international_card_not_present_flag"] = (
        features["is_international"].astype(bool) & features["card_not_present_flag"]
    )
    features["velocity_flag"] = features["transactions_last_hour"] >= 3
    features["sudden_spend_increase_flag"] = (
        features["prior_account_avg_amount"].notna()
        & (features["amount"] >= features["prior_account_avg_amount"] * 3)
    )
    features["above_prior_max_flag"] = (
        features["prior_account_max_amount"].notna()
        & (features["amount"] > features["prior_account_max_amount"])
    )

    features["prior_unique_merchant_count"] = 0
    new_merchant_flags = []
    for _, group in features.groupby("account_id", sort=False):
        seen_merchants: set[object] = set()
        prior_unique_counts = []
        for merchant_id in group["merchant_id"]:
            prior_unique_counts.append(len(seen_merchants))
            is_new = pd.notna(merchant_id) and merchant_id not in seen_merchants
            new_merchant_flags.append(is_new)
            if pd.notna(merchant_id):
                seen_merchants.add(merchant_id)
        features.loc[group.index, "prior_unique_merchant_count"] = prior_unique_counts
    features["new_merchant_flag"] = new_merchant_flags

    rule_columns = [
        "country_mismatch_flag",
        "night_transaction_flag",
        "high_risk_merchant_flag",
        "international_card_not_present_flag",
        "velocity_flag",
        "sudden_spend_increase_flag",
        "above_prior_max_flag",
        "new_merchant_flag",
    ]
    features["triggered_rule_count"] = features[rule_columns].astype(int).sum(axis=1)

    return features.sort_values(["transaction_ts", "transaction_id"]).reset_index(drop=True)


def write_output(df: pd.DataFrame, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Engineer fraud monitoring features.")
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT_PATH, help="Clean transaction CSV path.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_PATH, help="Feature output CSV path.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    clean = load_clean_transactions(args.input)
    features = engineer_features(clean)
    write_output(features, args.output)
    print(f"Wrote {len(features):,} feature rows to {args.output}")


if __name__ == "__main__":
    main()
