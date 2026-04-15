# 🚕 Optimizing for the Driver: A Predictive Positioning System to Enhance Welfare in Gig Networks

> A driver-centric zone recommendation system using XGBoost demand forecasting and a Weighted Sum Model (WSM) to maximize per-driver earnings in ride-hailing gig networks.

---

## 📌 Overview

Current ride-hailing platforms (Uber, Ola, etc.) optimize almost entirely for **passenger wait times** — not driver welfare. This project fills that gap with a two-stage predictive system:

1. **Stage 1 — XGBoost Demand Forecaster**: Predicts 15-minute zone-level trip demand across all 263 official NYC TLC zones using a 15-feature spatio-temporal input vector.
2. **Stage 2 — WSM Zone Scorer**: Combines predicted demand, driver supply, idle-time risk, and fuel cost into a single per-driver welfare score to recommend the optimal waiting zone.

The system is validated on **NYC Yellow Taxi Trip Records (Jan–Mar 2025)** and outperforms three baselines: random zone, nearest zone, and greedy demand.

---

## 📊 Results Summary

| Scenario | Revenue ($/15-min window) | vs. Our System |
|---|---|---|
| Random Zone | $16.67 | −68.5% |
| Nearest Zone | $41.70 | −21.2% |
| Greedy Demand | $11.85 | −77.6% |
| **Our System (WSM)** | **$52.89** | **0% (best)** |

**XGBoost Forecasting Metrics:**
| Metric | Value |
|---|---|
| MAE | 2.5953 |
| RMSE | 5.0695 |
| R² | 0.9405 |
| MAPE | 40.97% |
| NRMSE | 1.96% |

---

## 🗂️ Repository Structure

```
yellow-taxi-analysis/
│
├── phase_two_improved.ipynb        # Main analysis notebook (Stage 1 + Stage 2)
│
├── graphs/
│   ├── graph1_actual_vs_predicted.png    # Actual vs Predicted demand scatter
│   ├── graph2_residuals.png              # Residual distribution & analysis
│   ├── graph3_feature_importance.png     # XGBoost feature importance
│   ├── graph4_wsm_scores.png             # WSM welfare scores (top 20 zones)
│   ├── graph5_baseline_comparison.png    # Per-driver revenue comparison
│   ├── graph6_zone_distribution.png      # Trip distribution across TLC zones
│   ├── graph7_revenue_vs_idle.png        # Revenue vs idle penalty breakdown
│   └── zone_distribution.png            # Zone distribution overview
│
├── .gitignore
└── README.md
```

> **Note:** Raw `.parquet` data files are excluded from this repository due to size. Download them from the [NYC TLC Open Data Portal](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

---

## 📦 Dataset

- **Source**: [NYC Taxi & Limousine Commission (TLC)](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
- **Files**: `yellow_tripdata_2025-01.parquet`, `yellow_tripdata_2025-02.parquet`, `yellow_tripdata_2025-03.parquet`
- **Coverage**: January – March 2025
- **Zones**: 263 official TLC PULocationID zones

### Data Cleaning Filters Applied
- Removed fares ≤ $0 or ≥ $500
- Removed trips with distance ≤ 0 or > 120 km
- Restricted `PULocationID` to valid range [1, 263]
- Dropped records with missing pickup timestamp, zone ID, or fare

---

## ⚙️ Methodology

### Feature Engineering (15 Features)

| Category | Features |
|---|---|
| Cyclical Time Encoding | `hour_sin`, `hour_cos`, `weekday_sin`, `weekday_cos`, `month_sin`, `month_cos` |
| Multi-Lag Demand | `lag_1`, `lag_2`, `lag_4`, `lag_8`, `lag_96` (24-hour lookback) |
| Rolling Statistics | `rolling_mean_4`, `rolling_std_4`, `rolling_mean_96` |
| Zone ID | `PULocationID` |

### XGBoost Hyperparameters

| Parameter | Value |
|---|---|
| n_estimators | 800 |
| learning_rate | 0.02 |
| max_depth | 8 |
| subsample | 0.8 |
| colsample_bytree | 0.8 |
| min_child_weight | 5 |

### WSM Scoring Formula

```
WSM(z) = α·Rd_z − β·(I_z + S_z) − γ·C_z
```

Where:
- `Rd_z` = Per-driver revenue (demand × avg fare / estimated drivers)
- `I_z` = Idle-time penalty (inverse demand density)
- `S_z` = Supply saturation penalty (supply/demand ratio)
- `C_z` = Fuel cost (geodesic distance × $0.12/km)

Weights `(α, β, γ)` are determined via **grid search** over 27 candidate triplets — no manual tuning.

---

## 🚀 Getting Started

### Prerequisites

```bash
pip install xgboost pandas numpy scikit-learn geopy matplotlib seaborn jupyter
```

### Run the Notebook

```bash
jupyter notebook phase_two_improved.ipynb
```

### Download the Data

```bash
# Download parquet files from NYC TLC
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-01.parquet
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-02.parquet
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-03.parquet
```

Place the downloaded files in the root project directory before running the notebook.

---

## 📈 Key Visualizations

| Graph | Description |
|---|---|
| `graph1_actual_vs_predicted.png` | R²=0.94 scatter plot confirming strong forecasting accuracy |
| `graph2_residuals.png` | Zero-mean residuals confirming low model bias |
| `graph3_feature_importance.png` | `lag_1`, `lag_2`, `rolling_mean_4` are top predictors |
| `graph4_wsm_scores.png` | Zone 132 recommended despite lower demand due to high avg fare ($62.87) |
| `graph5_baseline_comparison.png` | WSM earns $52.89 vs $11.85 for greedy demand baseline |
| `graph6_zone_distribution.png` | Gini=0.834 confirms multi-zone demand structure |
| `graph7_revenue_vs_idle.png` | Recommended zone maximizes revenue with low idle penalty |

---

## 🔬 Research Paper

This project is based on the paper:

> **"Optimizing for the Driver: A Predictive Positioning System to Enhance Welfare in Gig Networks"**
> P. R. Pulipati, S. Parashar, and M. Zaman — Dayananda Sagar University, Bengaluru, India, 2026.

---

## ⚠️ Limitations

- Driver supply uses a fixed proxy ratio (0.75 trips/driver/15-min); real-time fleet API data would improve accuracy
- Zone centroids are approximated; a full TLC centroid file would improve fuel cost estimates
- No fatigue/shift modelling due to data unavailability
- Validated on NYC data only — Indian city generalization (Bengaluru, Mumbai) requires separate evaluation

---

## 🔮 Future Work

- Integrate real-time driver density from fleet APIs
- Add fatigue and shift scheduling constraints
- Validate on Indian ride-hailing datasets (Ola, Rapido)
- Deploy as a real-time mobile recommendation API

---

## 📄 License

This project is for academic research purposes. Dataset sourced from [NYC TLC Open Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page).
