# install.packages("keras3")
# install.packages("tidyverse")
# install.packages("caret")

library(keras)

py_require_legacy_keras()

library(tidyverse)
library(caret)

weather_data <- read.csv("seattleWeather_1948-2017.csv")

if (is.logical(weather_data$RAIN)) {
  weather_data$RAIN <- as.numeric(weather_data$RAIN)
} else if (is.character(weather_data$RAIN) || is.factor(weather_data$RAIN)) {
  weather_data$RAIN <- ifelse(weather_data$RAIN == "TRUE" || weather_data$RAIN == "Yes", 1, 0)
}

rain <- na.omit(weather_data$RAIN)
print(table(rain))

max_len <- 6
batch_size <- 32
total_epochs <- 15
set.seed(123)

start_indexes <- seq(1, length(rain) - (max_len + 1), by = 3)
weather_matrix <- matrix(nrow = length(start_indexes), ncol = max_len + 1)
for (i in 1:length(start_indexes)) {
  weather_matrix[i, ] <- rain[start_indexes[i]:(start_indexes[i] + max_len)]
}

X <- weather_matrix[, -ncol(weather_matrix)]
y <- weather_matrix[, ncol(weather_matrix)]
training_index <- createDataPartition(y, p = 0.9, list = FALSE, times = 1)
X_train <- array(X[training_index, ], dim = c(length(training_index), max_len, 1))
y_train <- y[training_index]
X_test <- array(X[-training_index, ], dim = c(length(y) - length(training_index), max_len, 1))
y_test <- y[-training_index]


model <- keras_model_sequential()
model |> 
  layer_simple_rnn(units = 6, input_shape = dim(X_train)[2:3]) |> 
  layer_dense(units = 1, activation = "sigmoid")

model |> compile(
  optimizer = "adam", 
  loss = "binary_crossentropy", 
  metrics = c("accuracy")
)
trained_model <- model |> fit(
  x = X_train,
  y = y_train,
  batch_size = 32,
  epochs = 15,
  validation_split = 0.1
)
print(trained_model)

evaluation <- model |> evaluate(X_test, y_test)
print(evaluation)

predictions <- model |> predict(X_test)
predicted_classes <- ifelse(predictions > 0.5, 1, 0)
test_error <- mean(predicted_classes != y_test)
print(paste("Test Learning Error (Classification Error Rate):", round(test_error, 4)))

png("rnn_weather_training_history.png", width = 1200, height = 800, res = 150)
plot(trained_model)
dev.off()