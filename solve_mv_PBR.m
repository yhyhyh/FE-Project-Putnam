function solve_mv_PBR(w_mv, mu, cov)
    n = length(mu);
    mu4i = (mu-mean(mu)).^4;
    alpha = (mu4i/n-(n-3)/(n*(n-1))*(diag(cov).^2)).^0.25;
    beta = -(ones(1,n)*pinv(cov)*alpha)/(ones(1,n)*pinv(cov)*ones(n,1));
    alpha
    beta
    beta1 = (alpha'*pinv(cov)*mu)*(mu'*pinv(cov)*ones(n,1));
    beta1 = beta1-(alpha'*pinv(cov)*ones(n,1))*(mu'*pinv(cov)*mu);
    div = (ones(1,n)*pinv(cov)*ones(n,1))*(mu'*pinv(cov)*mu);
    div = div-(mu'*pinv(cov)*ones(n,1));
    beta1 = beta1/div;
    
end
    
    