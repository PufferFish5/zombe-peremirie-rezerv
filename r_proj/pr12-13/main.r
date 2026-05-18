#install.packages(c("farver", "distributional", "fabletools", "feasts", "labeling", "ggplot2", "nonlinearTseries", "tseries"))
#install.packages(c("prophet", "rstan"))
library(readr)
library(tsibble)
library(dplyr)
library(lubridate)
library(farver)
library(distributional)
library(fabletools)
library(feasts)
library(labeling)
library(ggplot2)
library(ggtime)
library(nonlinearTseries)
library(tseries)
library(prophet)
library(rstan)

cryptos_price <- read_csv("cryptos_price.csv")
print("Step 1")
#View(cryptos_price)
#fix(cryptos_price)
str(cryptos_price)
unique(cryptos_price$coin)

iota_price <- cryptos_price |>
  filter(coin == "iota") |>
  mutate(ds = as.Date(ds)) |>
  transmute(ds = ymd(ds), y = y) |>
  arrange(ds)

iota_train <- iota_price |>
  mutate(ds = as.Date(ds)) |>
  mutate(y = log(y)) |>
  slice(1:(n() - 100)) |>
  as.data.frame()

iota_test <- iota_price |>
  mutate(ds = as.Date(ds)) |>
  mutate(y = log(y), ds = as.Date(ds)) |>
  tail(100) |>
  as.data.frame()
print("ds")
range(iota_train$ds)
str(iota_train)
print(head(iota_train))
M0 <- prophet(iota_train)

dates <- as.Date(c(
  "2018-03-01", "2018-06-01", "2018-09-01", "2018-12-01",
  "2019-03-01", "2019-06-01", "2019-09-01", "2019-12-01"
))
dates <- dates[dates %in% iota_train$ds]
valid_dates <- dates[dates >= min(iota_train$ds) & dates <= max(iota_train$ds)]

future_df <- make_future_dataframe(M0, periods = 100)




M3A <- prophet(iota_train, yearly.seasonality = 10, changepoint.range = 0.9, changepoint.prior.scale = 0.02)
png("M3A_yearly.png", width = 800, height = 600)
print(prophet:::plot_yearly(M3A))
dev.off()

M3B <- prophet(iota_train, yearly.seasonality = 20, changepoint.range = 0.9, changepoint.prior.scale = 0.02)
png("M3B_yearly.png", width = 800, height = 600)
print(prophet:::plot_yearly(M3B))
dev.off()

M10 <- prophet(weekly.seasonality = FALSE, yearly.seasonality = TRUE)
M10 <- add_seasonality(m = M10, name = "monthly", period = 30.5, fourier.order = 5)
M10 <- fit.prophet(M10, iota_train)
forecast_M10 <- predict(M10, future_df)
png("M10_components.png", width = 1200, height = 1000, res = 150)
prophet_plot_components(M10, forecast_M10)
dev.off()

M11 <- prophet(weekly.seasonality = FALSE, yearly.seasonality = TRUE)
M11 <- add_seasonality(m = M11, name = "quarter", period = 365.25/4, fourier.order = 2)
M11 <- fit.prophet(M11, iota_train)
forecast_M11 <- predict(M11, future_df)
png("M11_components.png", width = 1200, height = 1000, res = 150)
prophet_plot_components(M11, forecast_M11)
dev.off()

is_summer <- function(ds) {
  month <- as.numeric(format(ds, '%m'))
  return(month > 5 & month < 9)
}
iota_train$summer <- is_summer(iota_train$ds)
iota_train$not_summer <- !iota_train$summer
future_df$summer <- is_summer(future_df$ds)
future_df$not_summer <- !future_df$summer
M12 <- prophet(weekly.seasonality = FALSE)
M12 <- add_seasonality(M12, name = 'weekly_summer', period = 7, fourier.order = 3, condition.name = 'summer') 
M12 <- add_seasonality(M12, name = "weekly_not_summer", period = 7, fourier.order = 3, condition.name = "not_summer")
M12 <- fit.prophet(M12, iota_train)
forecast_M12 <- predict(M12, future_df)
png("M12_components.png", width = 1200, height = 1000, res = 150)
prophet_plot_components(M12, forecast_M12)
dev.off()

M14 <- prophet(iota_train, seasonality.mode = "multiplicative")
forecast_M14 <- predict(M14, future_df)
png("M14_forecast.png", width = 1200, height = 800, res = 150)
print(plot(M14, forecast_M14))
dev.off()

M15 <- prophet(yearly.seasonality = FALSE)
M15 <- add_seasonality(M15, name = 'yearly', period = 365.25, fourier.order = 10, mode = "multiplicative")
M15 <- fit.prophet(M15, iota_train)
forecast_M15 <- predict(M15, future_df)
png("M15_components.png", width = 1200, height = 1000, res = 150)
prophet_plot_components(M15, forecast_M15)
dev.off()