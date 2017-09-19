function [x0,x] = cvx_mv_PBR2(mu0,mu,V,A,r,sqrtU)

n = length(mu);
U = chol(V);

    cvx_begin quiet
    
        variables x0 x(n)
              
        maximize(-norm(U * x))
        
        subject to
                    mu' * x >= r;
                    sum(x) == 1;
                    x >= 0;
                    x' * A * x <= sqrtU;
    cvx_end