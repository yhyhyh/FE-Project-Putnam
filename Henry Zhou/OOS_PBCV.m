function [sig, A, U_star] = OOS_PBCV(w_mv, mu, cov)
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
    mu_Umin = cvx_Umin_mv2(mu, A, mean(mu));
    Umin = mu_Umin' * A * mu_Umin;
    Umax = w_mv' * A * w_mv;
    
    if (Umax < Umin)
        U_star = Umin;
    else
        U_star = findUstar(Umax, Umin, mu, A, cov);
    end
    
    alpha = (diag(mu4i)/n-(n-3)/(n*(n-1))*(diag(sig).^2)).^0.25;
end
    
    