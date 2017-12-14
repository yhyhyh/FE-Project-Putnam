library(fitdistrplus)
q1 <- raw$benchmark
ret_rate <- diff(q1) / q1[-length(q1)]
ret_rate <- ret_rate[!is.na(ret_rate)]
hist(ret_rate,breaks=100,xlim=c(-0.06,0.06),ylim=c(0,30))

q1 <- raw$CVaR.w.o.div
ret_rate <- diff(q1) / q1[-length(q1)]
ret_rate <- ret_rate[!is.na(ret_rate)]
hist(ret_rate,breaks=100,xlim=c(-0.06,0.06),ylim=c(0,30))

q1 <- raw$CVaR.with.div
ret_rate <- diff(q1) / q1[-length(q1)]
ret_rate <- ret_rate[!is.na(ret_rate)]
hist(ret_rate,breaks=100,xlim=c(-0.06,0.06),ylim=c(0,30))