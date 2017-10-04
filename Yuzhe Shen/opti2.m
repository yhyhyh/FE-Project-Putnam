function [w] =  opti2(alpha,Q,v,Sigma,yeta)

size_input=size(alpha);
if size_input(1)==1
    alpha=alpha';
end

n = size(alpha,1);
e = ones(n,1);

Sigma_root=sqrtm(Sigma);

kappa = sqrt(chi2inv(1-yeta,n));    
    cvx_begin quiet

        variables w(n)
        maximize (alpha'*w-kappa*norm(Sigma_root*w))
        subject to
                    e' * w == 1
                    w >= 0
                    w'* Q * w <= v
    cvx_end
end