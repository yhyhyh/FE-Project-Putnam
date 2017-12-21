library(tseries)
library(fBasics)
library(rmgarch)
library(rugarch)
library(fGarch)
library(xts)
library(MASS)

#--function to get the order
fitt <- function(re)
{
  p=0
  q=0
  bestp=0
  bestq=0
  minBIC=Inf
  for (p in 1:5){
    for (q in 1:5) {
      model= arima(re, order = c(p, 1, q), optim.control =list(maxit = 1000))
      bic=AIC(model,k = log(length(re)))
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
#--

#extract processed data. Daily and weekly
putnam_ts <- read.csv("E:/putnam project/data/data3.csv", header = TRUE)
putnam_daily <- read.csv("E:/putnam project/data/data1.csv", header = TRUE)
#--ARIMA
temp <- as.numeric(putnam_ts[,2])
order = fitt(temp)
AR_order = order[1]
MA_order = order[2]
t_fit = arima(temp, order = c(AR_order,1,MA_order))
#residual check for the first series
acf(residuals(t_fit))
acf(residuals(t_fit))
qqnorm(residuals(t_fit))
qqline(residuals(t_fit))
#fit all series
for (i in 2:length(putnam_ts)){
  temp <- as.numeric(putnam_ts[,i])
  order = fitt(temp)
  AR_order = order[1]
  MA_order = order[2]
  t_fit = arima(tbill, order = c(AR_order,1,MA_order))
}
#--ARIMA
temp <- as.numeric(putnam_ts[,2])
order = fitt(temp)
AR_order = order[1]
MA_order = order[2]
t_fit = arima(temp, order = c(AR_order,1,MA_order))
#square return ARIMA fit: Global Term Asset
temp <- as.numeric(putnam_ts[,2])
temp = temp^2
order = fitt(temp)
AR_order_square = order[1]
MA_order_square = order[2]
#ARIMA+GARCH(GARCH residual fit) with normal innovation distribution
arma.garch.norm1111 <- ugarchspec(mean.model=list(armaOrder=c(AR_order,MA_order)), 
                                  variance.model=list(model='sGARCH',garchOrder=c(AR_order_square,MA_order_square)), 
                                  distribution.model = "norm")
putnam.garch.norm1111 <- ugarchfit(data = putnam_ts[,2], spec = arma.garch.norm1111)
resi = residuals(putnam.garch.norm1111, standardize=TRUE)
acf(resi)
acf(resi^2)
qqnorm(resi)
qqline(resi)
#ARIMA+GARCH(GARCH residual fit) with student-t innovation distribution
arma.garch.norm1111 <- ugarchspec(mean.model=list(armaOrder=c(AR_order,MA_order)), 
                                  variance.model=list(model='sGARCH',garchOrder=c(AR_order_square,MA_order_square)), 
                                  distribution.model = "std")
putnam.garch.norm1111 <- ugarchfit(data = putnam_ts[,2], spec = arma.garch.norm1111)
resi = residuals(putnam.garch.norm1111, standardize=TRUE)
acf(resi)
acf(resi^2)
qqnorm(resi)
qqline(resi)
#-----variance forecast_only GARCH 
for (i in 2:length(putnam_ts)){
  fit =  putnam_ts[,i]
  arma.garch.norm1111.t <- ugarchspec(mean.model=list(armaOrder=c(1,1)), 
                                      variance.model=list(garchOrder=c(1,1)), 
                                      distribution.model = "std")
  putnam.arma.garch.norm1111.t <- ugarchfit(data = fit, spec = arma.garch.norm1111.t)
  predic = ugarchforecast(putnam.arma.garch.norm1111.t, n.ahead=1)
  print(predic)
  Gfit = garchFit(formula = ~garch(1,1),data = fit, trace=FALSE,cond.dist="std")
  
  omega = Gfit@fit$matcoef[1,1]
  alpha = Gfit@fit$matcoef[2,1]
  beta = Gfit@fit$matcoef[3,1]
  
  sigma2 = omega + alpha * fit[length(fit)]^2 + beta*Gfit@h.t[length(Gfit@h.t)]
  print(sigma2)
}
#------
data_ts = putnam_ts[1:length(putnam_ts[,2]),2:length(putnam_ts)]
# symm DCC
garch11.spec = ugarchspec(mean.model = list(armaOrder = c(0,0)), 
                          variance.model = list(garchOrder = c(1,1), 
                                                model = "sGARCH"), distribution.model = "std")
# dcc specification - GARCH(1,1) for conditional correlations
dcc.garch11.spec = dccspec(uspec = multispec( replicate(length(data_ts), garch11.spec) ), dccOrder = c(1,1), distribution = "mvnorm",)
dcc.fit = dccfit(dcc.garch11.spec, data = data_ts, fit.control=list(scale=TRUE))
r1=rcov(dcc.fit)
r0=rcor(dcc.fit, type="R")
# symm DCC with copula
garch11.spec = ugarchspec(mean.model = list(armaOrder = c(0,0)), 
                          variance.model = list(garchOrder = c(1,1), 
                                                model = "sGARCH"), distribution.model = "std")
test_spec = cgarchspec(multispec( replicate(length(data_ts), garch11.spec) ), dccOrder = c(1,1),,asymmetric = False)
test_aa = cgarchfit(test_spec,data_ts)
r1 = rcov(test_aa)
r0 = rcor(test_aa)
# asymm DCC with copula
garch11.spec = ugarchspec(mean.model = list(armaOrder = c(0,0)), 
                          variance.model = list(garchOrder = c(1,1), 
                                                model = "sGARCH"), distribution.model = "std")
test_spec = cgarchspec(multispec(replicate(length(data_ts), garch11.spec) ), dccOrder = c(1,1),,asymmetric = True)
test_aa = cgarchfit(test_spec,data_ts)
r1 = rcov(test_aa)
r0 = rcor(test_aa)
#---write to csv
lst = list()
now = 0
num_row = length(data_ts)
num_col = num_row
tot = num_row * num_col
for (i in 1:length(data_ts[,2]))
{
  now = 1+tot*(i-1)
  lst[[i]] = matrix(r1[now:(now+tot-1)],nrow=num_row,ncol=num_col)
}
#write to RData
save(lst,file = "E:/putnam project/data/final/matrix_cov_percent.RData")
#write to csv
lapply(lst, function(x) write.table( data.frame(x), 'E:/putnam project/data/final/matrix_data.csv'  , append= T, sep=',' ))
