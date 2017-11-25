%--------------------------------------------
% The main entrance of back-testing system
%--------------------------------------------

function multi_period(Price)
    load hist_r_file.mat;
    load Hist.mat;
    rf_hist = hist_r(:,1);
    risk_free_rate = zeros(3833,1);
    asset_selector = 2:17;
    Price = Price(:, asset_selector);
    hist_r = hist_r(:, asset_selector);
    n = size(hist_r,2);
    e = ones(n,1);
    horizon = 5;
    start = 100;
    number_rebalances = 746;
    number_of_samples = 50;
    sample_frequency = 1;
    r_w_f_o_y_e = .4;
    allowable_risk = 1.5;
    trans_cost = 0;
    wealth = 100;
    x0 = .3;
    x = (.7/n)*e;
    rf = (rf_hist(start+horizon*number_rebalances) - rf_hist(start)) / rf_hist(start);

    benchmark_x0 = x0;  
    benchmark_x = x; 
    rate_of_decay = 1 - r_w_f_o_y_e^(sample_frequency/52);
    initial_wealth = wealth;
    benchmark_wealth = wealth;	

    rebalance_dates = start + horizon*(0:number_rebalances-1);
    csvwrite('rebalance_dates.csv',rebalance_dates);

    hist_benchmark = zeros(1,length(rebalance_dates));
    hist_mvo = zeros(1,length(rebalance_dates));
    acc_cost1 = zeros(1,length(rebalance_dates));
    acc_cost2 = zeros(1,length(rebalance_dates));
    
    wealth = 100;
    x0 = .3;
    x = (.7/n)*e;
       
    for i = 1:length(rebalance_dates)

        trade_date = rebalance_dates(i);

        [mu,V] = adapted_stats(Price,trade_date, ...
                horizon,sample_frequency,number_of_samples,rate_of_decay);
        mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;

        benchmark_risk = sqrt(e'*V*e)/(n+1);
        sigma = allowable_risk*benchmark_risk; 

        xx0 = x0;
        xx = x;
        V = nearestSPD(V);
        [x0,x] =  cvx_markowitz(mu0,mu,V,sigma,xx0,xx,trans_cost);
        %[x0,x] = solve_mv_PBR(x, mu, V);
        [sig, A, U_star] = OOS_PBCV(x, mu, V);
        %U_star_list = ones(5);
        Nofk = 2;
        for k=1:1:Nofk
            [mu,V] = stats_wo_kseg(Price,trade_date, k, horizon, ...
                sample_frequency,number_of_samples,rate_of_decay);
            [temp0, temp1, U_star_l] = OOS_PBCV(x, mu, V);
            U_star = U_star + U_star_l;
        end
        U_star = U_star / Nofk;
        
        V = nearestSPD(V);
        % changes made here
        %[x0,x] = cvx_mv_PBR2(mu,V,A,mean(mu),U_star^0.5);
        x = cvx_cv_PBR(trade_date, V, hist_r, 0.95, U_star^0.5);
        x
        sum(x)
         
        acc_cost2(i) = acc_cost2(max(1,i-1))-x0-sum(x)+1;
        
        %wealth = wealth*(x0 + sum(x));
        total = x0 + sum(x);	
        x0 = x0/total;
        x = x/total;
        returns = (Price(trade_date+horizon-1,:)-Price(trade_date-1,:))...
            ./Price(trade_date-1,:);

        multiplier = 1 + mu0*x0 + returns*x;	
        wealth = multiplier*wealth;
        fprintf('%d %f\n',i,wealth);
        hist_mvo(i) = wealth;
        if (wealth <= 0)
            break;
        end

        x0 = (1+mu0)*x0/multiplier;
        x = x.*(1+returns)'/multiplier;
    end
    
    metrics = [];
    fprintf('your final wealth %f\n',wealth);
    plot(hist_mvo); hold on
    res_all = hist_mvo;
    tot_ret = (hist_mvo(end) - hist_mvo(1)) / hist_mvo(1);
    std(price2ret(hist_mvo))
    NofDay = size(hist_r,1);
    sharpe = (tot_ret - rf)/ (NofDay / 252) / ...
        (std(price2ret(hist_mvo)) * sqrt(252));
    skw = skewness(price2ret(hist_mvo));
    kur = kurtosis(price2ret(hist_mvo));
    metrics = [metrics; [sharpe, skw, kur, maxdrawdown(hist_mvo)]];
   

    rate_of_decay = 1 - r_w_f_o_y_e^(sample_frequency/52);
    rebalance_dates = start + horizon*(0:number_rebalances-1);

    hist_mvo = zeros(1,length(rebalance_dates));
    acc_cost2 = zeros(1,length(rebalance_dates));
    
    wealth = 100;
    x0 = .3;
    x = (.7/n)*e;
       
    for i = 1:length(rebalance_dates)

        trade_date = rebalance_dates(i);

        [mu,V] = adapted_stats(Price,trade_date, ...
                horizon,sample_frequency,number_of_samples,rate_of_decay);
        mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;

        benchmark_risk = sqrt(e'*V*e)/(n+1);
        sigma = allowable_risk*benchmark_risk; 

        xx0 = x0;
        xx = x;
        %V = nearestSPD(V);
        %[x0,x] =  cvx_markowitz(mu0,mu,V,sigma,xx0,xx,trans_cost);
        x = 1.0 / n * e;
        acc_cost2(i) = acc_cost2(max(1,i-1))-x0-sum(x)+1;
        
        %wealth = wealth*(x0 + sum(x));
        total = x0 + sum(x);	
        x0 = x0/total;
        x = x/total;
        returns = (Price(trade_date+horizon-1,:)-Price(trade_date-1,:))...
            ./Price(trade_date-1,:);

        multiplier = 1 + mu0*x0 + returns*x;	
        wealth = multiplier*wealth;
        wealth
        hist_mvo(i) = wealth;
        if (wealth <= 0)
            break;
        end

        x0 = (1+mu0)*x0/multiplier;
        x = x.*(1+returns)'/multiplier;
    end
    
    fprintf('your mvo wealth %f\n',wealth);
    plot(hist_mvo); 
    legend('CV PBR','Benchmark');
    tot_ret = (hist_mvo(end) - hist_mvo(1)) / hist_mvo(1);
    std(price2ret(hist_mvo))
    NofDay = size(hist_r,1);
    sharpe = (tot_ret - rf)/ (NofDay / 50) / ...
        (std(price2ret(hist_mvo)) * sqrt(50));
    skw = skewness(price2ret(hist_mvo));
    kur =  kurtosis(price2ret(hist_mvo));
    
    metrics = [metrics; [sharpe, skw, kur, maxdrawdown(hist_mvo)]];
    metrics
    %maxdrawdown(hist_mvo)
    res_all = [res_all; hist_mvo];
    csvwrite('res_all.csv',res_all');
   
end
