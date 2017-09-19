library(tseries)
library(xts)
library(forecast)

putnam_ts <- read.csv("trial1.csv", header = TRUE)
tbill <- as.numeric(putnam_ts$T.Bill)
global <- as.numeric(putnam_ts$Global.Term)
us <- as.numeric(putnam_ts$US.Term)
t_fit = arima(tbill, order = c(fitt(tbill)[1],1,fitt(tbill)[2]))
global_fit = arima(global, order = c(fitt(global)[1],1,fitt(global)[2]))
us_fit = arima(us, order = c(fitt(us)[1],1,fitt(us)[2]))
t_fit
global_fit
us_fit
acf(residuals(t_fit))
acf(residuals(global_fit))
qqnorm(residuals(global_fit))
qqline(residuals(global_fit))
acf(residuals(us_fit))
#------
fitt <- function(re)
{
p=0
q=0
bestp=0
bestq=0
minBIC=Inf
for (p in 1:2){
  for (q in 1:2) {
    model= arima(re, order = c(p, 0, q))
    bic=AIC(model,k = log(length(nik_re_log)))
    if(bic<minBIC){
      bestp=p
      bestq=q
      minBIC=bic
    }
    #print(p)
    #print(q)
    #print(bic)
    #print(AIC(model))
  }
}
r <- c(bestp,bestq)
return (r)
}
#----arma garch

#arma(1,1)garch(1,1)
arma.garch.norm1111 <- ugarchspec(mean.model=list(armaOrder=c(1,1)), 
                                  variance.model=list(garchOrder=c(1,1)))
lognik.arma.garch.norm1111 <- ugarchfit(data = fitt, spec = arma.garch.norm1111)
show(lognik.arma.garch.norm1111)
res1111 = residuals(lognik.arma.garch.norm1111, standardize=FALSE)
res1111.std = residuals(lognik.arma.garch.norm1111, standardize=TRUE)
par(mfrow=c(2,3))
plot(res1111)
acf(res1111)
acf(res1111^2)
plot(res1111.std)
acf(res1111.std)
acf(res1111.std^2)
jb.norm.test(res1111)
qqnorm(res1111)
qqline(res1111)

