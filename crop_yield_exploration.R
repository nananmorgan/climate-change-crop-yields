library(dplyr)

# Load datasets
crop_yields <- read.csv('crop_yields.csv')
global_temp <- read.csv('global_temp.csv')
global_co2 <- read.csv('global_co2.csv')
global_precipitation <- read.csv('global_precipitation.csv')

# Preview the datasets
head(crop_yields)
head(global_temp)
head(global_co2)
head(global_precipitation)


# Data cleaning and preparation
# Remove duplicates, if there are any
global_precipitation <- global_precipitation %>% distinct()
global_temp <- global_temp %>% distinct()
crop_yields <- crop_yields %>% distinct()
global_co2 <- global_co2 %>% distinct()


# Check for missing values
summary(global_precipitation)
summary(global_temp)
summary(crop_yields)
summary(global_co2)

# Convert columns to numeric
global_temp <- global_temp %>%
  mutate(across(everything(), as.numeric))

global_co2 <- global_co2 %>%
  mutate(across(everything(), as.numeric))

global_precipitation <- global_precipitation %>%
  mutate(across(everything(), as.numeric))


# Merge climate data into a single dataframe
# Merge datasets on 'year'
combined_data <- global_precipitation %>%
  inner_join(global_temp, by = "year") %>%
  inner_join(global_co2, by = "year") %>% 
  inner_join(crop_yields, by = "year")

# Create new variables, temperature change rate and co2 change rate, by taking the difference between consecutive years.
combined_data <- combined_data %>%
  group_by(item) %>%
  arrange(year) %>%  # Ensure the data is sorted by year within each crop type
  mutate(
    temp_change_rate = c(NA, diff(lowess)),
    co2_change_rate = c(NA, diff(avg.c02.ppm))
  ) %>%
  ungroup()

#Create new variable of yield per area harvested
combined_data <- combined_data %>%
  mutate(yield_per_area_harvested = Yield / Area.harvested)

combined_data

# Count missing values in each column
missing_values <- sapply(combined_data, function(x) sum(is.na(x)))
    
# Split data by crop
corn_data <- combined_data %>% filter(item == "Maize (corn)")
wheat_data <- combined_data %>% filter(item == "Wheat")
rice_data <- combined_data %>% filter(item == "Rice")
soy_data <- combined_data %>% filter(item == "Soya beans")

# Visual preview
library(ggplot2)

ggplot(crop_yields, aes(x = year, y = Yield, color = factor(item))) +
  geom_line() +
  labs(title = "Global Crop Yield", x = "Year", y = "Yield (tonnes)") +
  theme_minimal() +
  theme(legend.position = "none")

ggplot(crop_yields, aes(x = year, y = Area.harvested, color = factor(item))) +
  geom_line() +
  labs(title = "Global Crop Harvest Area", x = "Year", y = "Area Harvested (Hectacres)") +
  theme_minimal() +
  theme(legend.position = "none")

ggplot(crop_yields, aes(x = year, y = Production, color = factor(item))) +
  geom_line() +
  labs(title = "Global Crop Production", x = "Year", y = "Production (100g/ha)") +
  theme_minimal() +
  theme(legend.position = "none")


ggplot(global_temp, aes(x = year)) +
  geom_line(aes(y = no_smoothing, color = "blue")) +
  geom_line(aes(y = lowess, color = "red")) +
  labs(title = "Global Temperature", x = "Year", y = "Temperature Anomaly (C)") +
  theme_minimal() +
  theme(legend.position = "none")

ggplot(global_co2, aes(x = year)) +
  geom_line(aes(y = avg.c02.ppm, color = "blue")) +
  labs(title = "Global CO2 Emissions", x = "Year", y = "Average CO2 Emissings (parts per million") +
  theme_minimal() +
  theme(legend.position = "none")


ggplot(global_precipitation, aes(x = year)) +
  geom_line(aes(y = anomaly, color = "blue")) +
  labs(title = "Global Percipitation", x = "Year", y = "Precipitation Anomaly (inches)") +
  theme_minimal() +
  theme(legend.position = "none")

ggplot(global_precipitation, aes(x = year, y = anomaly, fill = anomaly > 0)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("TRUE" = "blue", "FALSE" = "red")) +
  labs(title = "Global Precipitation Anomalies", x = "Year", y = "Precipitation Anomaly") +
  theme_minimal() +
  theme(legend.position = "none")


# Scatter plot of temperature vs crop yield
ggplot(combined_data, aes(x = anomaly, y = crop_yields$Yield)) +
  geom_point(aes(color=crop_yields$item)) +
  labs(title = "Temperature vs Crop Yield",
       x = "Temperature Anomalies",
       y = "Crop Yield")

# Scatter plot of temperature vs crop yield
ggplot(combined_data, aes(x = avg.c02.ppm, y = crop_yields$Yield)) +
  geom_point(aes(color=crop_yields$item)) +
  labs(title = "Co2 Emissions vs Crop Yield",
       x = "Co2 Emissions",
       y = "Crop Yield")
## This scratter plot shows us a positive correlation between CO2 emissions and crop yields for all crops selected. It appears different crops may have different amount of sensitivity to CO2 emissions. Specifically, this graph would indicate that corn and rice may have higher yields at with higher CO2 emissions compared to Wheat and soya beans. However, further analysis, looking at other factors will be important.

ggplot(combined_data, aes(x = lowess, y = crop_yields$Yield)) +
  geom_point(aes(color=crop_yields$item)) +
  labs(title = "Global Temperature vs Crop Yield",
       x = "Global Temperature Anomalies",
       y = "Crop Yield")
## This also gives us a positive correlation where corn and rice appear to produce higher yield when the temperature anomaly is greater.

# Correlation Analysis
cor_matrix_change_rates <- combined_data %>%
  select(temp_change_rate, co2_change_rate, Yield) %>%
  cor(use = "complete.obs")

print(cor_matrix_change_rates)


# Correlation Analysis
cor_matrix <- combined_data %>%
  select(anomaly, lowess, avg.c02.ppm, Yield, Area.harvested, Production) %>%
  cor(use = "complete.obs")

print(cor_matrix)
# CO2 and temp is highly correlated. Next are yield and CO2 (0.70) and yield and lowess (temp anomaly) (0.69)
  lowess and Yield: The correlation coefficient is 0.70, indicating a strong positive correlation. This suggests that the smoothed temperature data (which captures underlying trends better) is strongly correlated with crop yields.
  Area.harvested and Yield: The correlation coefficient is 0.32, indicating a moderate positive correlation. This suggests that an increase in the area harvested is associated with an increase in crop yields, but other factors also play a significant role.
  Production and Yield: The correlation coefficient is 0.88, indicating a very strong positive correlation. This is expected, as higher crop production typically leads to higher yields.

  corn_data <- subset(corn_data, select = -item)
  corn_model <- lm(Yield ~ ., data = corn_data)
  summary(corn_model)
  
  rice_data <- subset(rice_data, select = -item)
  rice_model <- lm(Yield ~ ., data = rice_data)
  summary(rice_model)
  
  wheat_data <- subset(wheat_data, select = -item)
  wheat_model <- lm(Yield ~ ., data = wheat_data)
  summary(wheat_model)
  
  soy_data <- subset(soy_data, select = -item)
  soy_model <- lm(Yield ~ ., data = soy_data)
  summary(soy_model)
  
#Residuals tell us the difference between the actual values in the data, and the values predicted by the model. We can see the distribution of the residuals, with the median being -63,293.

#The next coefficients table is telling us the estimates of the regression parameters. Intercept is roughly 641,800, with a SE of 3,800. The intercept is telling us what the Sale Price is, if the lot size (sqft) is 0. The following line gives us the sq_ft_lot of 0.8651 with a SE of 0.062, which means for each sqft added, the Sale Price would increase by $0.851.

#The R-squared is 0.01435 which means that 1.435% of the changes in Sale Price can be explained by the lot size. This is actually a pretty low number, indicating a weak linear relationship.
#The adjusted R-squared is 0.01428 is still very low and is close to the R-squared because we only have one predictor (and this changes based on the number of predictors in the model).
