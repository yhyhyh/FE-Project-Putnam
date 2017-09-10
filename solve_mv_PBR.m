function solve_mv_PBR(w_mv, mu, cov)
    n = length(mu);
    mu4i = ones(n,1);
    sig = mu4i;
    for i = 1:n
        mu4i(i) = sum((mu-mu(i)).^4)/n;
        sig(i) = sum((mu-mu(i)).^2)/n;
    end
    alpha = (mu4i/n-(n-3)/(n*(n-1))*(sig.^2)).^0.25;
    %alpha = (n-3)/(n*(n-1))*(diag(cov).^2);
    beta = -(ones(1,n)*pinv(cov)*alpha)/(ones(1,n)*pinv(cov)*ones(n,1));
    alpha
end
    
    