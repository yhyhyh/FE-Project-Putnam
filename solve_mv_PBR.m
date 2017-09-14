function [x0,x] = solve_mv_PBR(w_mv, mu, cov)
    n = length(mu);
    mu4i = ones(n,n);
    sig = mu4i;
    for i = 1:n
        for j = 1:n
            sig(i,j) = sum((mu-mu(i)).*(mu-mu(j)))/n;
            mu4i(i,j) = sum((mu-mu(i)).^2.*(mu-mu(j)).^2)/n;
        end
    end
    Q2 = (mu4i-sig.^2)/n+(sig.^2+diag(sig)*diag(sig)')/(n*(n-1));
    A = nearestSPD(Q2);
    sig = nearestSPD(sig);
    [x0,x] = cvx_mv_PBR2(0,mu,sig,A,mean(mu),10);
    alpha = (diag(mu4i)/n-(n-3)/(n*(n-1))*(diag(sig).^2)).^0.25;
    %beta = -(ones(1,n)*pinv(cov)*alpha)/(ones(1,n)*pinv(cov)*ones(n,1));
end
    
    