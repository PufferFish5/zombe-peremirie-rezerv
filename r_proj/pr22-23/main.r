sigmoid <- function(x) {
  return(1.0 / (1.0 + exp(-x)))
}
sigmoid_derivative <- function(x) {
  return(x * (1.0 - x))
}
softM <- function(x) {
  res <- matrix(0, nrow = nrow(x), ncol = ncol(x))
  for (j in 1:ncol(x)) {
    max_val <- max(x[, j])
    exp_vals <- exp(x[, j] - max_val)
    res[, j] <- exp_vals / sum(exp_vals)
  }
  return(res)
}
feedforward <- function(nn) {
  nn$layer1 <- sigmoid(nn$weights1 %*% nn$input)
  nn$output <- softM(nn$weights2 %*% nn$layer1)
  return(nn)
}
backprop <- function(nn, lr = 0.05) {
  error <- nn$y - nn$output
  d_weights2 <- error %*% t(nn$layer1)
  d_layer1 <- (t(nn$weights2) %*% error) * sigmoid_derivative(nn$layer1)
  d_weights1 <- d_layer1 %*% t(nn$input)
  nn$weights1 <- nn$weights1 + lr * d_weights1
  nn$weights2 <- nn$weights2 + lr * d_weights2
  return(nn)
}
compute_loss <- function(y, output) {
  epsilon <- 1e-15
  output <- pmax(pmin(output, 1 - epsilon), epsilon)
  return(-sum(y * log(output)) / ncol(y))
}
set.seed(123)
input_dim <- 10
hidden_dim <- 15
output_dim <- 8
num_samples <- 100
X <- matrix(runif(input_dim * num_samples), nrow = input_dim)
Y <- matrix(0, nrow = output_dim, ncol = num_samples)
for (i in 1:num_samples) {
  random_class <- sample(1:output_dim, 1)
  Y[random_class, i] <- 1
}
nn <- list(
  input = NULL,
  y = NULL,
  weights1 = matrix(runif(hidden_dim * input_dim, -0.5, 0.5), nrow = hidden_dim),
  weights2 = matrix(runif(output_dim * hidden_dim, -0.5, 0.5), nrow = output_dim),
  layer1 = NULL,
  output = NULL
)
epochs <- 1000
loss_history <- rep(0, epochs)
for (epoch in 1:epochs) {
  epoch_loss <- 0
  for (i in 1:num_samples) {
    nn$input <- matrix(X[, i], ncol = 1)
    nn$y <- matrix(Y[, i], ncol = 1)
    nn <- feedforward(nn)
    nn <- backprop(nn, lr = 0.02)
    epoch_loss <- epoch_loss + compute_loss(nn$y, nn$output)
  }
  loss_history[epoch] <- epoch_loss / num_samples
  if (epoch %% 100 == 0) {
    print(paste("Epoch:", epoch, "-> Average Categorical Cross-Entropy Loss:", round(loss_history[epoch], 5)))
  }
}
png("nn_high_dim_loss_trajectory.png", width = 1200, height = 800, res = 150)
plot(1:epochs, loss_history, type = "l", col = "darkgreen", lwd = 2, main = "Neural Network Training Trajectory (High-Dimensional Vectors)", xlab = "Epochs", ylab = "Cross-Entropy Loss")
grid(nx = NULL, ny = NULL, col = "lightgray", lty = "dotted")
dev.off()