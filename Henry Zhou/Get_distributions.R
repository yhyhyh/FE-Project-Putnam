library(fitdistrplus)
q1 <- raw$benchmark
ret_rate <- diff(q1) / q1[-length(q1)]
ret_rate <- ret_rate[!is.na(ret_rate)]
hist(ret_rate,breaks=100)