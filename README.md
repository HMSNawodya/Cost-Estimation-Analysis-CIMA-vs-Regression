# Cost Estimation Analysis – CIMA High–Low vs Regression

R project comparing a traditional CIMA High–Low costing method with a multiple
linear regression model for estimating overhead costs in a fictional Sri Lankan
tea factory.

- Simulated 24 months of production and inflation data.
- Built a CIMA High–Low model to estimate fixed and variable cost.
- Built a regression model: `Actual_Cost ~ Units + Inflation`.
- Compared accuracy using Mean Absolute Percentage Error (MAPE).

Results (this run):

- CIMA High–Low MAPE: **3.08%**
- Regression MAPE: **0.65%**

The regression model is clearly more accurate because it includes both
production volume and inflation as predictors.

Main files:

- `cima-vs-stats-cost-prediction.ipynb` – R notebook with full analysis.
- `cost-estimation-analysis.R` – Script version of the analysis.
- `cost-model-comparison.pdf` – Visual comparison of Actual vs CIMA vs Regression.
