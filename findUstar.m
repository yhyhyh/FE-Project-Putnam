function U_star = findUstar(U_max, U_min, mu, V, A)
    div = 3;
    sharpe_max = -100;
    U_star = U_min;
    for i = 0:div
        U = U_min + (U_max - U_min) / div * i;
        x = cvx_mv_PBR2(mu, V, A, mean(mu), U^0.5);
        sharpe = (mu' * x) / (mu' * V * mu)^0.5;
        if (sharpe > sharpe_max)
            sharpe_max = sharpe;
            U_star = U;
        end
    end
end