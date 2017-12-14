
function [x0,x] =  cvx_markowitz(mu0,mu,V,sigma,xx0,xx,trans_cost);

n = length(mu);
U = chol(V);

    cvx_begin quiet
    
        variables x0 x(n) y(n) total_trans_cost
              
        minimize(calc(x,V,n))
        
        subject to
                   
                    x0 + sum(x) + total_trans_cost == 1;
                    x == xx + y;
                    trans_cost * sum(abs(y)) <= total_trans_cost;
                    x0 == 0;
                    x >= 0;                               
                    
    cvx_end

    
end 


function sum = calc(x,V,n) 
    sum = 0;
    A = V*x;
    s=(x'*V*x);
    for i=1:n
        sum = sum + (x(i)-s)*(x(i)-s);
    end
end    
    
    
    
    
    