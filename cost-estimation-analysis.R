# Load necessary libraries
library(tidyverse)
library(knitr)

set.seed(123)

# 1. Create the Data Variables (24 Months)
months <- 1:24

# Simulate Production Units (Normal Distribution: Mean 12,000, SD 1,500)
units <- round(rnorm(24, mean = 12000, sd = 1500))

# Simulate Sri Lankan Inflation Index (Rising trend with randomness)
# We assume inflation index fluctuates between 100 and 150
inflation_index <- round(sort(runif(24, min = 100, max = 150)) + rnorm(24, sd = 2), 1)

# 2. Create the "True" Cost Formula 
# Fixed Cost: 5,000,000 LKR
# Variable Cost: 250 LKR per unit
# Inflation Impact: 20,000 LKR for every point of inflation
# Random Noise (Unexpected repairs, waste): Normal dist, SD 100,000
true_error <- rnorm(24, mean = 0, sd = 100000)

total_cost <- 5000000 + (250 * units) + (20000 * inflation_index) + true_error

# 3. Combine into a Dataframe
df <- data.frame(
  Month      = months,
  Units      = units,
  Inflation  = inflation_index,
  Actual_Cost = total_cost
)

# Show first rows
kable(head(df), caption = "Fictional Tea Factory Cost Data (LKR)")

# --- CIMA P1: High-Low Method ---

# 1. Identify High and Low Activity Levels
high_row <- df[which.max(df$Units), ]
low_row  <- df[which.min(df$Units), ]

# 2. Calculate Variable Cost per Unit (b)
# Formula: (High Cost - Low Cost) / (High Units - Low Units)
vc_per_unit_cima <- (high_row$Actual_Cost - low_row$Actual_Cost) / 
  (high_row$Units       - low_row$Units)

# 3. Calculate Fixed Cost (a)
# Formula: Total Cost - (Variable Cost * Units)
# Use the High row
fc_cima <- high_row$Actual_Cost - (vc_per_unit_cima * high_row$Units)

# 4. Create Predictions using High-Low
df$CIMA_Prediction <- fc_cima + (vc_per_unit_cima * df$Units)

print(paste("CIMA Fixed Cost:", round(fc_cima, 2)))
print(paste("CIMA Variable Cost per Unit:", round(vc_per_unit_cima, 2)))

# --- Statistics: Multiple Linear Regression ---

# 1. Build the Model (Cost depends on Units AND Inflation)
stats_model <- lm(Actual_Cost ~ Units + Inflation, data = df)

# 2. View Summary (Check R-squared and P-values)
summary(stats_model)

# 3. Add Predictions to the dataframe
df$Stats_Prediction <- predict(stats_model, df)

# --- Validation: Calculate Error Rates ---

# Calculate Absolute % Error for CIMA
df$CIMA_Error_Pct <- abs(df$Actual_Cost - df$CIMA_Prediction) / df$Actual_Cost

# Calculate Absolute % Error for Stats
df$Stats_Error_Pct <- abs(df$Actual_Cost - df$Stats_Prediction) / df$Actual_Cost

# Calculate Mean Absolute Percentage Error (MAPE)
mape_cima  <- mean(df$CIMA_Error_Pct)  * 100
mape_stats <- mean(df$Stats_Error_Pct) * 100

print(paste("CIMA High-Low Error Rate:", round(mape_cima, 2), "%"))
print(paste("Statistical Regression Error Rate:", round(mape_stats, 2), "%"))

if (mape_stats < mape_cima) {
  print("CONCLUSION: The Statistical approach is significantly more accurate.")
}

# --- Visualization: Comparison Plot ---

df_long <- df %>%
  select(Month, Actual_Cost, CIMA_Prediction, Stats_Prediction) %>%
  tidyr::pivot_longer(-Month, names_to = "Method", values_to = "Cost")

ggplot(df_long, aes(x = Month, y = Cost, color = Method)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  scale_color_manual(values = c("black", "red", "green3"),
                     labels = c("Actual_Cost"      = "Actual Cost",
                                "CIMA_Prediction"  = "CIMA (High-Low)",
                                "Stats_Prediction" = "Stats (Regression)")) +
  labs(title = "Cost Estimation Model Comparison",
       subtitle = "Comparing Traditional Accounting vs. Multivariate Statistics",
       y = "Total Overhead Cost (LKR)",
       x = "Month") +
  theme_minimal() +
  theme(legend.position = "bottom")

