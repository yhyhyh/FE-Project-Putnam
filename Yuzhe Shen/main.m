cd('/Users/shenyz/Documents/Cornell/Fall 2017/courses/CFEM project/Robust');
[mu,V]=stats(data,2,50,0.01,1)

%% Robust

n = size(data,1);
burn_in = 200;
num_samples = 50;


for i = burn_in+1:n-num_samples
   rets = data(1:i,2:end);
   [mu,V]=stats(rets,i-num_samples+1,num_samples,0.01,1);
   [mu2,Q]=stats(rets,2,num_samples,0.001,0);
 
   Robust_w(i+1,:) = opti2(mu,Q,0.5,V,0.05);
   Robust_return(i+1) = data(i+1,2:end)*Robust_w(i+1,:)';
   i,
end

% weight700: opti
% weight700_2: cvx_p (containing borrowing and lending)
Robust_return(isnan(Robust_return))=0;
cumsum_Robust = cumprod(Robust_return/100+1);


%% MV

n = size(data,1);
burn_in = 200;
num_samples = 50;
r = 0.1;

for i = burn_in+1:n-num_samples
   rets = data(1:i,2:end);
   [mu,V]=stats(rets,i-num_samples+1,num_samples,0.01,1);
 
   MV_w(i+1,:) = opti(mu,V,r);
   MV_return(i+1) = data(i+1,2:end)*MV_w(i+1,:)';
   i,
end

% weight700: opti
% weight700_2: cvx_p (containing borrowing and lending)
MV_return(isnan(MV_return))=0;
cumsum_MV = cumprod(MV_return/100+1);


%%
close all;
plot(cumsum_MV,'b');
hold on;
plot(cumsum_Robust,'r');