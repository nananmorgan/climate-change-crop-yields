# Climate Change Impact on Global Crop Yields

## Overview
Climate change poses significant challenges to global food production. This project analyzes the relationship between climate variables and crop yields for four major crops (maize, rice, soya beans, and wheat) using historical data spanning 1961 to 2022. Four datasets covering crop production, CO2 emissions, global temperature anomalies, and precipitation anomalies are merged and analyzed to answer a central question: can we predict crop yields based on historical climate data, and how can those predictions inform agricultural practices?

## Key Results
- CO2 emissions showed the strongest positive correlation with crop yield (r = 0.70) and with temperature anomalies (r = 0.996), confirming the well-established relationship between CO2 and warming
- Temperature anomalies also showed a strong positive correlation with yield (r = 0.69), with corn and rice showing the most sensitivity to rising temperatures
- Precipitation anomalies showed no meaningful correlation with yield (r = 0.11), likely due to irrigation and other agricultural adaptation strategies
- The initial linear regression model achieved an adjusted R-squared of 0.9298, meaning 92.98% of yield variability was explained
- A log-transformed model improved fit to an adjusted R-squared of **0.947**, with more randomly distributed residuals and better homoscedasticity
- CO2 emissions (avg.co2.ppm) was the only climate variable with a statistically significant coefficient in the initial model (p < 0.001). In the log model, temperature change rate also became significant (p < 0.001)
- Crop type was highly significant across both models, with corn consistently producing the highest yields

## Methods
- **Data preparation**: Removed duplicates, converted columns to numeric, merged four datasets on year using inner joins, engineered two new features (temperature change rate and CO2 change rate) using lagged differences
- **Exploratory analysis**: Line charts of yield, harvest area, and production over time; individual time series for CO2, global temperature, and precipitation anomalies; scatter plots of each climate variable against yield and area harvested by crop type
- **Correlation analysis**: Full correlation matrix across all variables
- **Modeling**: Linear regression predicting yield from all climate variables and crop type; residual diagnostics (residuals vs. fitted, Q-Q plot); log-transformation of yield to improve model fit

## Datasets
| File | Source | Coverage |
|------|--------|----------|
| `crop_yields.csv` | FAO / Our World in Data | 1961 to 2022, 4 crops |
| `global_temp.csv` | NASA GISS | 1880 to present |
| `global_co2.csv` | NOAA / Mauna Loa | 1958 to present |
| `global_precipitation.csv` | NOAA | 1901 to present |

## Tools
R, ggplot2, dplyr, tidyr, base R (lm, cor, qqnorm)

## Repository Contents
```
climate-change-crop-yields/
├── crop_yield_analysis.pdf       # Final analysis pdf version
├── crop_yield_analysis.Rmd       # Final analysis in R Markdown
├── crop_yield_exploration.R      # Initial exploration
├── crop_yields.csv
├── global_temp.csv
├── global_co2.csv
├── global_precipitation.csv
└── README.md
```

## How to Run
1. Open `crop_yield_analysis.Rmd` in RStudio
2. Install required packages if needed: `install.packages(c("ggplot2", "dplyr", "tidyr"))`
3. Knit the document or run cells individually. All four CSV files must be in the same working directory as the `.Rmd` file
