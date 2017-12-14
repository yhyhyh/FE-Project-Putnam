
function [x0,x] =  cvx_minvar(mu0,mu,V,sigma,xx0,xx,trans_cost);

n = length(mu);
U = chol(V);
R = 1.4*mean(mu);

    cvx_begin quiet
    
        variables x0 x(n) y(n) total_trans_cost
              
        minimize(norm(U * x))
        
        subject to
                   
                    %norm(U * x) <= sigma;
                    mu' * x >= R
                    x0 + sum(x) + total_trans_cost == 1;
                    x == xx + y;
                    trans_cost * sum(abs(y)) <= total_trans_cost;
                    x0 == 0;
                    x >= 0;
                    
                    
    cvx_end