raw = csvread('AMDATA.csv',1,0);
raw_ret = price2ret(raw);
avg_ret = mean(raw_ret) * 52;
sdv = std(raw_ret) * 52 ^ 0.5;
rf = 0.01975;
sharpe = (avg_ret - rf * ones(1,size(sdv,2))) ./ sdv;
skw = skewness(raw_ret);
kur = kurtosis(raw_ret);
maxdr = maxdrawdown(raw);
ordered = sort(raw_ret,1);
size(ordered)
var = ordered(round(size(raw_ret,1)/5),:);
cvar = mean(ordered(1:round(size(raw_ret,1)/5),:),1);
res = [avg_ret; sdv; sharpe; skw; kur; maxdr; var; cvar];
csvwrite('metrics.csv', res);