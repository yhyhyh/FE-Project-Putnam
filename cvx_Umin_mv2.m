function x =  cvx_Umin_mv2(mu,V,r);

n = length(mu);

    cvx_begin quiet
    
        variables x(n)
              
        maximize(-mu' * V * mu)
        
        subject to
                    sum(x)== 1
                    mu' * x >= r
                    x >= 0                    
    cvx_end

