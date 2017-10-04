function [x] =  opti(mu,V,r)

size_input=size(mu);
if size_input(1)==1
    mu=mu';
end

n = size(mu,1);
e = ones(n,1);

U = cholcov(V);    
    cvx_begin quiet

        variables x(n)
        minimize(norm(U*x))
        subject to
                    mu'*x >= r
                    sum(x) == 1
                    x>=-0.5
%                     abs(x) <= 0.5
    cvx_end
end
