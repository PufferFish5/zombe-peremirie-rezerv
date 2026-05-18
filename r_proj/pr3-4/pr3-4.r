#1)
fr <- data.frame (
  patient = c("biba", "boba", "byba", "baba", "beba", "buba", "antonchik"),
  glucose = c(1, 2, 11, 12, 111, 122, 1111),
  pulse = c(80, 90, 100, 70, 75, 85, 95)
)
print(fr)
age <- c(10, 100, 20, 90, 30, 80, 40)
fr <- cbind(fr, age)
print(fr)

#2)
mat1 <- matrix(c(1, 2, 3, 9, 8, 7, 4, 5, 6), nrow = 3, ncol = 3)
mat2 <- matrix(c(11, 22, 33, 99, 88, 77, 44, 55, 66), nrow = 3, ncol = 3)
print(mat1 %*% mat2)

mat3 <- matrix(0, nrow = nrow(mat1), ncol = ncol(mat2))


for (i in 1:nrow(mat1)) {
  for (j in 1:ncol(mat2)) {
    sum_val <- 0
    for (k in 1:ncol(mat1)) {
      sum_val <- sum_val + mat1[i, k] * mat2[k, j]
    }
    mat3[i, j] <- sum_val
  }
}
print(mat3)

#3)
plot(1, type="n", xlim=c(0, 5), ylim=c(0, 5))
lines(x = c(1, 2), y = c(5, 0), col = "red", lwd = 2)
lines(x = c(2, 3), y = c(0, 5), col = "blue", lwd = 2)

#4)
#perc <- c(23, 56, 20, 63)
#labels <- c("diyalnist'1", "diyalnist'2", "diyalnist'3", "diyalnist'4")

#piepercent <- round(100 * perc / sum(perc), 1)
#print(piepercent)
#pie(perc, labels = piepercent,
#    main = "chito drito",
#    col = rainbow(length(perc)))
#legend("topright", labels, cex = 1.5, fill = rainbow(length(perc)))