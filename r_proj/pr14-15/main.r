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
future_df <- make_future_dataframe(M0, periods = 100)

M3 <- prophet(iota_train, changepoint.range = 0.9, changepoint.prior.scale = 0.50)
M3_cv <- cross_validation(M3, initial = 280, period = 60, horizon = 60, units = "days")
head(M3_cv)

#Step 2
performance_metrics(M3_cv, metrics = "mse", rolling_window = 0) |> head()
performance_metrics(M3_cv, metrics = "mse", rolling_window = 0.1) |> head()
png("M3_cv_metric.png", width = 1000, height = 800, res = 150)
print(plot_cross_validation_metric(M3_cv, metric = "mse", rolling_window = 0.1))
dev.off()
performance_metrics(M3_cv, metrics = "mse", rolling_window = 1) |> head()

#Step 3
M10 <- prophet(weekly.seasonality = FALSE, yearly.seasonality = TRUE)
M10 <- add_seasonality(m = M10, name = "monthly", period = 30.5, fourier.order = 5)
M10 <- fit.prophet(M10, iota_train)
M14 <- prophet(iota_train, seasonality.mode = "multiplicative")
M15 <- prophet(yearly.seasonality = FALSE)
M15 <- add_seasonality(M15, name = 'yearly', period = 365.25, fourier.order = 10, mode = "multiplicative")
M15 <- fit.prophet(M15, iota_train)
forecast_M15 <- predict(M15, future_df)
M10_cv <- cross_validation(M10, initial = 280, period = 120, horizon = 60, units = "days")
M14_cv <- cross_validation(M14, initial = 280, period = 120, horizon = 60, units = "days")
M15_cv <- cross_validation(M15, initial = 280, period = 120, horizon = 60, units = "days")
M10_perf <- performance_metrics(M10_cv, metrics = c("mse", "rmse", "mae", "mape", "coverage"), rolling_window = 1)
M14_perf <- performance_metrics(M14_cv, metrics = c("mse", "rmse", "mae", "mape", "coverage"), rolling_window = 1)
M15_perf <- performance_metrics(M15_cv, metrics = c("mse", "rmse", "mae", "mape", "coverage"), rolling_window = 1)
print(M10_perf)
print(M14_perf)
print(M15_perf)
M10_cv_plot <- plot_cross_validation_metric(M10_cv, metric = "mape", rolling_window = 0.1) + 
  coord_cartesian(ylim = c(0, 0.4)) + ggtitle("M10")

M14_cv_plot <- plot_cross_validation_metric(M14_cv, metric = "mape", rolling_window = 0.1) + 
  coord_cartesian(ylim = c(0, 0.4)) + ggtitle("M14")

M15_cv_plot <- plot_cross_validation_metric(M15_cv, metric = "mape", rolling_window = 0.1) + 
  coord_cartesian(ylim = c(0, 0.4)) + ggtitle("M15")
png("comparison_cv_mape.png", width = 1500, height = 600, res = 150)
gridExtra::grid.arrange(M10_cv_plot, M14_cv_plot, M15_cv_plot, ncol = 3)
dev.off()

#Step 4
png("M10_test_comparison.png", width = 1200, height = 800, res = 150)
print(plot(M10, predict(M10, future_df)) + geom_point(data = iota_test, aes(as.POSIXct(ds), y), col = "red"))
dev.off()
png("M14_test_comparison.png", width = 1200, height = 800, res = 150)
print(plot(M14, predict(M14, future_df)) + geom_point(data = iota_test, aes(as.POSIXct(ds), y), col = "red"))
dev.off()
png("M15_test_comparison.png", width = 1200, height = 800, res = 150)
p_final <- plot(M15, forecast_M15) + coord_cartesian(xlim = c(as.POSIXct("2019-01-01"), as.POSIXct("2020-01-01"))) + geom_point(data = iota_test, aes(as.POSIXct(ds), y), col = "red")
print(p_final)
dev.off()