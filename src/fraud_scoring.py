"""Score transactions using rules and optional Isolation Forest anomaly detection.

Default input:
    data/processed/transaction_features.csv

Default outputs:
    data/processed/fraud_scores.csv
    data/processed/high_risk_transactions.csv
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd


DEFAULT_INPUT_PATH = Path("data/processed/transaction_features.csv")
DEFAULT_OUTPUT_PATH = Path("data/processed/fraud_scores.csv")
DEFAULT_HIGH_RISK_OUTPUT_PATH = Path("data/processed/high_risk_transactions.csv")


FEATURE_COLUMNS = [
    "amount",
    "transaction_hour",
    "transactions_last_hour",
    "transactions_last_24h",
    "amount_z_score",
    "amount_to_prior_avg_ratio",
    "merchant_risk_score",
    "kyc_risk_score",
    "triggered_rule_count",
]


RULE_WEIGHTS = {
    "country_mismatch_flag": 10,
    "night_transaction_flag": 8,
    "high_risk_merchant_flag": 15,
    "international_card_not_present_flag": 15,
    "velocity_flag": 12,
    "sudden_spend_increase_flag": 15,
    "above_prior_max_flag": 8,
    "new_merchant_flag": 7,
}


def load_features(input_path: Path) -> pd.DataFrame:
    df = pd.read_csv(input_path)
    df["transaction_ts"] = pd.to_datetime(df["transaction_ts"], errors="coerce")
    return df


def score_rules(df: pd.DataFrame) -> pd.Series:
    scores = pd.Series(10, index=df.index, dtype=float)

    for column, weight in RULE_WEIGHTS.items():
        if column in df.columns:
            scores += df[column].fillna(False).astype(bool).astype(int) * weight

    amount_ratio = pd.to_numeric(df.get("amount_to_prior_avg_ratio"), errors="coerce").fillna(1)
    amount_z_score = pd.to_numeric(df.get("amount_z_score"), errors="coerce").fillna(0)

    scores += np.select(
        [
            amount_ratio >= 10,
            amount_ratio >= 5,
            amount_ratio >= 3,
        ],
        [15, 10, 5],
        default=0,
    )
    scores += np.select(
        [
            amount_z_score >= 5,
            amount_z_score >= 3,
        ],
        [10, 5],
        default=0,
    )

    return scores.clip(lower=0, upper=100).round(2)


def add_isolation_forest_scores(df: pd.DataFrame, contamination: float) -> pd.DataFrame:
    scored = df.copy()

    try:
        from sklearn.ensemble import IsolationForest
        from sklearn.impute import SimpleImputer
        from sklearn.pipeline import make_pipeline
        from sklearn.preprocessing import StandardScaler
    except ImportError:
        scored["isolation_forest_score"] = np.nan
        scored["isolation_forest_anomaly_flag"] = False
        scored["isolation_forest_available"] = False
        return scored

    model_columns = [column for column in FEATURE_COLUMNS if column in scored.columns]
    model_data = scored[model_columns].apply(pd.to_numeric, errors="coerce")

    if len(model_data) < 5:
        scored["isolation_forest_score"] = np.nan
        scored["isolation_forest_anomaly_flag"] = False
        scored["isolation_forest_available"] = True
        return scored

    pipeline = make_pipeline(
        SimpleImputer(strategy="median"),
        StandardScaler(),
        IsolationForest(
            n_estimators=200,
            contamination=contamination,
            random_state=42,
        ),
    )
    pipeline.fit(model_data)

    isolation_forest = pipeline.named_steps["isolationforest"]
    transformed_data = pipeline[:-1].transform(model_data)
    anomaly_prediction = isolation_forest.predict(transformed_data)
    anomaly_score = -isolation_forest.score_samples(transformed_data)

    min_score = anomaly_score.min()
    max_score = anomaly_score.max()
    if max_score == min_score:
        normalized_score = np.zeros_like(anomaly_score)
    else:
        normalized_score = (anomaly_score - min_score) / (max_score - min_score) * 100

    scored["isolation_forest_score"] = normalized_score.round(2)
    scored["isolation_forest_anomaly_flag"] = anomaly_prediction == -1
    scored["isolation_forest_available"] = True
    return scored


def assign_risk_band(score: float) -> str:
    if score >= 80:
        return "Critical"
    if score >= 65:
        return "High"
    if score >= 40:
        return "Medium"
    return "Low"


def score_transactions(df: pd.DataFrame, contamination: float) -> pd.DataFrame:
    scored = df.copy()
    scored["rule_based_risk_score"] = score_rules(scored)
    scored = add_isolation_forest_scores(scored, contamination)

    if scored["isolation_forest_available"].any():
        scored["final_risk_score"] = np.maximum(
            scored["rule_based_risk_score"],
            scored["isolation_forest_score"].fillna(0) * 0.6 + scored["rule_based_risk_score"] * 0.4,
        ).clip(0, 100).round(2)
    else:
        scored["final_risk_score"] = scored["rule_based_risk_score"]

    scored["risk_band"] = scored["final_risk_score"].apply(assign_risk_band)
    scored["review_priority"] = np.select(
        [
            scored["risk_band"].eq("Critical"),
            scored["risk_band"].eq("High"),
            scored["risk_band"].eq("Medium"),
        ],
        ["Immediate Review", "Same Day Review", "Standard Review"],
        default="Monitor",
    )
    scored["recommended_action"] = np.select(
        [
            scored["risk_band"].eq("Critical"),
            scored["risk_band"].eq("High"),
            scored["risk_band"].eq("Medium"),
        ],
        [
            "Block or hold transaction and contact customer",
            "Queue for fraud analyst review",
            "Monitor customer and merchant behavior",
        ],
        default="No immediate action",
    )

    return scored.sort_values(["final_risk_score", "transaction_ts"], ascending=[False, True]).reset_index(drop=True)


def write_outputs(scored: pd.DataFrame, output_path: Path, high_risk_output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    scored.to_csv(output_path, index=False)

    high_risk = scored[scored["risk_band"].isin(["Critical", "High"])].copy()
    high_risk.to_csv(high_risk_output_path, index=False)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Score fraud risk for transaction feature rows.")
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT_PATH, help="Feature CSV path.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_PATH, help="Scored transaction output CSV path.")
    parser.add_argument(
        "--high-risk-output",
        type=Path,
        default=DEFAULT_HIGH_RISK_OUTPUT_PATH,
        help="High-risk queue output CSV path.",
    )
    parser.add_argument(
        "--contamination",
        type=float,
        default=0.15,
        help="Expected anomaly share for Isolation Forest.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    features = load_features(args.input)
    scored = score_transactions(features, args.contamination)
    write_outputs(scored, args.output, args.high_risk_output)

    high_risk_count = scored["risk_band"].isin(["Critical", "High"]).sum()
    print(f"Wrote {len(scored):,} scored transactions to {args.output}")
    print(f"Wrote {high_risk_count:,} high-risk transactions to {args.high_risk_output}")


if __name__ == "__main__":
    main()
