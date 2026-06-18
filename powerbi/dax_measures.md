# Suggested Power BI DAX Measures

```DAX
Total Transactions = COUNTROWS(fraud_scores)
```

```DAX
Total Transaction Value = SUM(fraud_scores[amount])
```

```DAX
High Risk Transactions =
CALCULATE(
    COUNTROWS(fraud_scores),
    fraud_scores[risk_band] IN {"Critical", "High"}
)
```

```DAX
Confirmed Fraud Transactions =
CALCULATE(
    COUNTROWS(fraud_scores),
    fraud_scores[fraud_label] = TRUE()
)
```

```DAX
Fraud Rate =
DIVIDE(
    [Confirmed Fraud Transactions],
    [Total Transactions]
)
```

```DAX
Average Risk Score = AVERAGE(fraud_scores[final_risk_score])
```

```DAX
Critical Transaction Count =
CALCULATE(
    COUNTROWS(fraud_scores),
    fraud_scores[risk_band] = "Critical"
)
```

```DAX
High Risk Review Share =
DIVIDE(
    [High Risk Transactions],
    [Total Transactions]
)
```
