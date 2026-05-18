#install.packages(c("farver", "distributional", "fabletools", "feasts", "labeling", "ggplot2", "nonlinearTseries", "tseries", "BreakoutDetection", "anomalize"))
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
library(anomalize)
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

M0 <- prophet(iota_train)
future_df <- make_future_dataframe(M0, periods = 100)

#Step 2
iota_price <- iota_price[order(iota_price$ds),]
result_iota <- iota_price %>% as_tibble() %>% time_decompose(y, merge = TRUE) %>% anomalize(remainder) %>% time_recompose()
print(result_iota)
png("anomaly_decomp_default.png", width = 1200, height = 800, res = 150)
print(result_iota %>% plot_anomaly_decomposition())
dev.off()

#Step 3
png("anomalies_plot.png", width = 1200, height = 800, res = 150)
print(result_iota %>% plot_anomalies())
dev.off()
png("anomalies_line_plot.png", width = 1200, height = 800, res = 150)
print(result_iota %>% plot_anomalies() + geom_line())
dev.off()

#Step 4
print(get_time_scale_template())
png("anomaly_decomp_custom.png", width = 1200, height = 800, res = 150)
iota_price %>% as_tibble() %>% time_decompose(y, frequency = "2 days", trend = "6 days") %>% anomalize(remainder) %>% time_recompose() %>% plot_anomaly_decomposition() %>% print()
dev.off()

#Step 5
png("anomaly_decomp_twitter.png", width = 1200, height = 800, res = 150)
iota_price %>% as_tibble() %>% time_decompose(y, frequency = "2 days", trend = "6 days", method = "twitter") %>% anomalize(remainder) %>% time_recompose() %>% plot_anomaly_decomposition() %>% print()
dev.off()

#Step 6
png("anomaly_decomp_alpha.png", width = 1200, height = 800, res = 150)
iota_price %>% as_tibble() %>% time_decompose(y, frequency = "2 days", trend = "6 days", method = "twitter") %>% anomalize(remainder, alpha = 0.025) %>% time_recompose() %>% plot_anomaly_decomposition() %>% print()
dev.off()