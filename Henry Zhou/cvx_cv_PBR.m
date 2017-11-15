
function w = cvx_cv_PBR(n,V,R,b,U)
% R is matrix of historical returns, each row corresponding to a sample date
% b represents the desired confidence, between .5 and 1, with closer to 1 being more confident
% U1 is a number chosen by the user -- the model has a constraint restricting attention only
%      to portfolios w for which the variance of its CVaR does not exceed U1.
% U2 is a number chosen by the user -- the model has a constraint restricting attention only
%      to portfolios w whose variance does not exceed U2.
% V is the sample covariance matrix

noa = size(R,2);
Omega = (1/(n-1))*(eye(n)-(1/n)*ones(n,n));
r = R(1:n, :);
r_now = R(n,:);
r_mean = mean(r_now);

cvx_begin quiet
    
    variables a w(noa) z(n)
              
    minimize(a + (1/(n*(1-b)))*sum(z))
        
    subject to

                sum(w) == 1;
                (1/(n*(1-b)^2))*z'*nearest(Omega)*z <= U;
                r_now * w >= r_mean;
                z >= 0;
                z >= -r * w - a;
                %(1/n)*w'*V*w <= U;
                w >= 0
                %w <= 0.2
                               
cvx_end                               
