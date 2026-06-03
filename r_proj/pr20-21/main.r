sigmoid <- function(x) {
  return(1 / (1 + exp(-x)))
}
derivativeActivation <- function(x) {
  return(sigmoid(x) * (1 - sigmoid(x)))
}
feedForward <- function(x, w1, w2, activation) {
  output <- rep(0, length(x))
  for (i in 1:length(x)) {
    a1 <- w1 %*% matrix(rbind(1, x[i]), ncol = 1)
    z1 <- activation(a1)
    a2 <- w2 %*% matrix(rbind(1, z1), ncol = 1)
    output[i] <- a2
  }
  return(output)
}
backPropagation <- function(x, y, w1, w2, activation, derivativeActivation) {
  preds <- feedForward(x, w1, w2, activation)
  derivCost <- -2 * (y - preds)
  dw1 <- matrix(0, ncol = 2, nrow = nrow(w1))
  dw2 <- matrix(0, nrow = length(x), ncol = ncol(w2))
  for (i in 1:length(x)) {
    a1 <- w1 %*% matrix(rbind(1, x[i]), ncol = 1)
    da2dw2 <- matrix(rbind(1, activation(a1)), nrow = 1)
    dw2[i, ] <- derivCost[i] * da2dw2
  }
  for (i in 1:length(x)) {
    a1 <- w1 %*% matrix(rbind(1, x[i]), ncol = 1)
    da2da1 <- derivativeActivation(a1) * matrix(w2[, -1], ncol = 1)
    da2dw1 <- da2da1 %*% matrix(rbind(1, x[i]), nrow = 1)
    dw1 <- dw1 + derivCost[i] * da2dw1
  }
  gradient <- list(dw1, colSums(dw2))
  return(gradient)
}
set.seed(42)
x_train <- seq(-pi, pi, length.out = 200)
y_train <- sin(x_train)
hidden_neurons <- 10
w1 <- matrix(runif(hidden_neurons * 2, -1, 1), nrow = hidden_neurons)
w2 <- matrix(runif(1 * (hidden_neurons + 1), -1, 1), nrow = 1)
lr <- 0.01
epochs <- 500
for (epoch in 1:epochs) {
  shuffle_idx <- sample(length(x_train))
  x_shuffled <- x_train[shuffle_idx]
  y_shuffled <- y_train[shuffle_idx]
  for (i in 1:length(x_shuffled)) {
    grads <- backPropagation(x_shuffled[i], y_shuffled[i], w1, w2, sigmoid, derivativeActivation)
    w1 <- w1 - lr * grads[[1]]
    w2 <- w2 - lr * matrix(grads[[2]], nrow = 1)
  }
}
final_preds <- feedForward(x_train, w1, w2, sigmoid)
mse <- mean((y_train - final_preds)^2)
print(paste("Training Error (MSE):", mse))
png("nn_trigonometric_approximation.png", width = 1200, height = 800, res = 150)
plot(x_train, y_train, type = "l", col = "blue", lwd = 2, main = "Trigonometric Function Approximation by NN", xlab = "X", ylab = "Y")
lines(x_train, final_preds, col = "red", lwd = 2, lty = 2)
legend("topright", legend = c("True sin(x)", "NN Prediction"), col = c("blue", "red"), lty = c(1, 2), lwd = 2)
dev.off()