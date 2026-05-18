#1)
a <- as.integer(readline())
faktorialchik <- function(i = 3) {
  if (i <= 1) {
    1
  } else {
    i * faktorialchik(i - 1)
  }
}
b <- faktorialchik(a)
print(b)
#2)
glob <- readline()
net_fantazii <- function() {
  glob <- "qq"
  loc <- readline()
  cat("local 'glob': ", glob, "\n")
  cat("local 'loc': ", loc, "\n")
}
net_fantazii()
cat("global 'glob': ", glob, "\n")
#3)
for (i in 1:20) {
  if (i %% 2 == 0) {
    print(i)
  } else {
    next
  }
  if (i == 10) {
    print("Ssssssttttttttttttoooooooooooooooooooooooooppppppppppppp")
    break
  }
}
#4)
num1 <- as.integer(readline())
num2 <- as.integer(readline())
num3 <- as.integer(readline())

comparator <- function(a, b, c) {
  if (a == b && b == c) {
    return("normas vse rovno")
  }
  nums <- c(a, b, c)
  max_val <- max(nums)
  cat("Greatest number:", max_val, "\n")
  if (a == b) {
    print("num1 i num2 rovno")
  }
  if (a == c) {
    print("num1 i num3 rovno")
  }
  if (b == c) {
    print("num2 i num3 rovno")
  }
  #return(invisible(max_val))
}

comparator(num1, num2, num3)