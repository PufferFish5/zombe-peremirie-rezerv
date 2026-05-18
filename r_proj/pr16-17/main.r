install.packages(c("farver", "distributional", "fabletools", "feasts", "labeling", "ggplot2", "nonlinearTseries", "tseries", "BreakoutDetection"))
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

M0 <- prophet(iota_train)
future_df <- make_future_dataframe(M0, periods = 100)

library(BreakoutDetection)
BO0 <- breakout(log(iota_price$y), plot = TRUE, ylab = "y")
png("BO0_plot.png", width = 1000, height = 800)
print(BO0$plot)
dev.off()
BO0_perm <- breakout(log(iota_price$y), nperm = 1000)
print(BO0_perm)

#Step 3
BO1 <- breakout(log(iota_price$y), method = "multi", plot = TRUE, ylab = "y")
png("BO1_plot.png", width = 1000, height = 800)
print(BO1$plot)
dev.off()


#Step 4
BO2 <- breakout(log(iota_price$y), method = "multi", degree = 0, plot = TRUE, ylab = "y")
png("BO2_plot.png", width = 1000, height = 800)
print(BO2$plot)
dev.off()
print(BO2$loc)

#Step 5
BO3 <- breakout(log(iota_price$y), method = "multi", percent = 0.05, plot = TRUE, ylab = "y")
png("BO3_plot.png", width = 1000, height = 800)
print(BO3$plot)
dev.off()

#Step 6
BO4 <- breakout(log(iota_price$y), method = "multi", beta = 0.0001, plot = TRUE, ylab = "y")
png("BO4_plot.png", width = 1000, height = 800)
print(BO4$plot)
dev.off()