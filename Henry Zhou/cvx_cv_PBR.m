function w = cvx_cv_PBR(n,V,hist_r,U)

noa = size(hist_r,2);
U = chol(V);
b = 0.95;
r = hist_r(1:n, :);

cvx_begin quiet
    
    variables a w(noa) z
    
    dual variable yz;
              
    minimize(a + (1/(n*(1-b))) * sum(w' * r'))
        
    subject to

                sum(w) == 1;
                w >= 0;
                %(1/(n*(1-b).^2)) * z' * findOmega(noa) * z <= U;
                z >= 0;
                yz : z >= - w' * r'- a;
                (1/n) * w' * V * w <= U
                                        
cvx_end

yz
end

function Omega = findOmega(n) 
    
    Omega = (1/(n-1))*(eye(n)-1/n*ones(n,n));
     
end