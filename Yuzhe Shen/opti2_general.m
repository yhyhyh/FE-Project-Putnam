function [w] =  opti2_general(alpha,Q,v,Sigma,x,yeta,type_input,b)
size_input=size(alpha);
if size_input(1)==1
    alpha=alpha';
end

n = size(alpha,1);
e = ones(n,1);

kappa = sqrt(x(ceil(length(x)*(1-yeta)))); 
Sigma_root=sqrtm(Sigma);

if type_input == 1
    z = 0;
elseif type_input == 2
    z = b;
else
end

k=1;

if type_input==3 
    D = pinv(Sigma_root);
    cvx_begin quiet

        variables w(n)
        
        expression z(n)
        z = (1/(e'*D*Sigma*D'*e))* (e'* D * Sigma * w) * D' * e;
        
        maximize (alpha'*w-kappa*norm(Sigma_root*(w-z)))
        subject to
                    e'* w == 1
                    w >= 0
                    abs(w)<=k
                    (w-z)'* Q * (w-z) <= v
    cvx_end
elseif type_input==4
    D = pinv(Sigma);
    cvx_begin quiet

        variables w(n)
        
        expression z(n)
        z = (1/(e'*D*Sigma*D'*e))* (e'* D * Sigma * w) * D' * e;
        
        maximize (alpha'*w-kappa*norm(Sigma_root*(w-z)))
        subject to
                    e'* w == 1
                    w >= 0
                    abs(w)<=k
                    (w-z)'* Q * (w-z) <= v
    cvx_end
else
    cvx_begin quiet

        variables w(n)
        
        maximize (alpha'*w-kappa*norm(Sigma_root*(w-z)))
        subject to
                    sum(w) == 1
                    w >= 0
                    abs(w)<=k
                    (w-z)'* Q * (w-z) <= v
    cvx_end   
end
end