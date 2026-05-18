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

# print("Step 2")
# cryptos_price$ds <- ymd(cryptos_price$ds)
# print(unique(cryptos_price$coin))
# iota_price <- cryptos_price |>
#   filter(coin == "iota") |>
#   mutate(ds = ymd(ds)) |>
#   select(ds, y) |>
#   distinct(ds, .keep_all = TRUE)
# summary(iota_price)

# print("Step 3")
# iota_price <- as_tsibble(iota_price, key=NULL, index=ds)
# str(iota_price)
# glimpse(iota_price, width = 60)

# print("Step 4")
# png("price_data_plot.png", width = 800, height = 600)
# plot(iota_price$ds, iota_price$y, type = "l")
# dev.off()

# print("Step 5")
# # acf(iota_price$y)
# # pacf(iota_price)
# #ts_ap <- as_tsibble(iota_price, key = NULL, index = ds)
# ts_ap <- iota_price
# ts_ap |> gg_lag(geom = "point") + theme_minimal()
# ts_ap |> ACF(lag_max = 6)
# ts_ap |> ACF() |> autoplot() + theme_minimal()
# ggsave("acf_plot.png", width = 20, height = 15, units = "cm")
# ts_ap |> PACF() |> autoplot() + theme_minimal()
# ggsave("pacf_plot.png", width = 20, height = 15, units = "cm")

# print("Step 6")
# nonlinearityTest(iota_price$y, verbose = TRUE)
# adf.test(iota_price$y)
# kpss.test(iota_price$y)
# pp.test(iota_price$y)

# print("Step 7")
# tsData  <- ts(data = iota_price$y, start = c(2018, 1), frequency = 30)
# stlData <- stl(tsData, s.window = "periodic")
# par(mfrow = c(1, 2))
# png("price_plot.png", width = 800, height = 600)
# hist(iota_price$y, main = "Price", xlab = "iota Price", col="lightblue")
# dev.off()
# png("diff_plot.png", width = 800, height = 600)
# hist(diff(iota_price$y), main = "Diff", xlab = "Price Change", col="lightgreen")
# dev.off()
# par(mfrow = c(1, 1))


#PR8 9, prophet
print("Step 1 (prophet)")

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
str(M0)

dates <- as.Date(c(
  "2018-03-01", "2018-06-01", "2018-09-01", "2018-12-01",
  "2019-03-01", "2019-06-01", "2019-09-01", "2019-12-01"
))
dates <- dates[dates %in% iota_train$ds]
summary(iota_train$ds)
valid_dates <- dates[dates >= min(iota_train$ds) & dates <= max(iota_train$ds)]


future_df <- make_future_dataframe(M0, periods = 100)
forecast_M0 <- predict(M0, future_df)
head(forecast_M0)
png("M0_prophet_forecast.png", width = 1200, height = 800, res = 150)
print(plot(M0, forecast_M0) + add_changepoints_to_plot(M0) + theme_minimal() + labs(title = "Prophet Forecast", x = "Date", y = "Log Price"))
dev.off()

print("Step 2 (prophet)")
print(plot(M0, forecast_M0) + add_changepoints_to_plot(M0))
M1 <- prophet(iota_train, n.changepoints = 15)
forecast_M1 <- predict(M1, future_df)
png("M1_prophet_changepoints.png", width = 1200, height = 800, res = 150)
print(plot(M1, forecast_M1) + add_changepoints_to_plot(M1) + theme_minimal() + labs(title = "Prophet Forecast", x = "Date", y = "Log Price"))
dev.off()

print("Step 3 (prophet)")
M2 <- prophet(iota_train, n.changepoints = 20, changepoint.range = 0.9)
forecast_M2 <- predict(M2, future_df)
png("M2_prophet_changepoints.png", width = 1200, height = 800, res = 150)
print(plot(M2, forecast_M2) + add_changepoints_to_plot(M2) + theme_minimal() + labs(title = "Prophet Forecast", x = "Date", y = "Log Price"))
dev.off()

print("Step 4 (prophet)")
M3 <- prophet(iota_train, changepoint.range = 0.9, changepoint.prior.scale = 0.5)
forecast_M3 <- predict(M3, future_df)
png("M3_prophet_changepoints.png", width = 1200, height = 800, res = 150)
print(plot(M3, forecast_M3) + add_changepoints_to_plot(M3) + theme_minimal() + labs(title = "Prophet Forecast", x = "Date", y = "Log Price"))
dev.off()

print("Step 5 (prophet)")

M4 <- prophet(iota_train, changepoint.range = 0.9, changepoint.prior.scale = 0.5, changepoints = valid_dates)
forecast_M4 <- predict(M4, future_df)
png("M4_prophet_changepoints.png", width = 1200, height = 800, res = 150)
print(plot(M4, forecast_M4) + add_changepoints_to_plot(M4) + theme_minimal() + labs(title = "Prophet Forecast", x = "Date", y = "Log Price"))
dev.off()
