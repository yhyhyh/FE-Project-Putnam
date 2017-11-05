%--------------------------------------------
% The main entrance of back-testing system
%--------------------------------------------

function multi_period

    load Hist.mat; 
    load hist_r_file.mat;
    Price = csvread('data_v2.csv',1,1);
    rf_hist = Price(:,1);
    risk_free_rate = price2ret(Price(:,1));
    asset_selector = [2,3,4,6,7,11:14,16,17];
    Price = Price(:, asset_selector);
    hist_r = hist_r(:, asset_selector);
    n = size(Price,2);
    e = ones(n,1);
    horizon = 5;
    start = 526;
    number_rebalances = 6;
    number_of_samples = 100;
    sample_frequency = 1;
    r_w_f_o_y_e = .4;
    allowable_risk = 1;
    trans_cost = 0;
    wealth = 10000;
    x0 = .3;
    x = (.7/n)*e;
    rf = (rf_hist(start+horizon*number_rebalances) - rf_hist(start)) / rf_hist(start);

    benchmark_x0 = x0;  
    benchmark_x = x; 
    rate_of_decay = 1 - r_w_f_o_y_e^(sample_frequency/52);
    initial_wealth = wealth;
    benchmark_wealth = wealth;	

    rebalance_dates = start + horizon*(0:number_rebalances-1);

    hist_benchmark = zeros(1,length(rebalance_dates));
    hist_mvo = zeros(1,length(rebalance_dates));
    acc_cost1 = zeros(1,length(rebalance_dates));
    acc_cost2 = zeros(1,length(rebalance_dates));
    
    wealth = 10000;
    x0 = .3;
    x = (.7/n)*e;
       
    for i = 1:length(rebalance_dates)
    %for i = 1:1

        trade_date = rebalance_dates(i);

        [mu,V] = adapted_stats(Price,trade_date, ...
                horizon,sample_frequency,number_of_samples,rate_of_decay);
        mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;

        benchmark_risk = sqrt(e'*V*e)/(n+1);
        sigma = allowable_risk*benchmark_risk; 

        xx0 = x0;
        xx = x;
        %V = nearestSPD(V);
        [x0,x] =  cvx_markowitz(mu0,mu,V,sigma,xx0,xx,trans_cost);
        %[x0,x] = solve_mv_PBR(x, mu, V);
        [sig, A, U_star] = OOS_PBCV(x, mu, V);
        %U_star_list = ones(5);
        Nofk = 3;
        for k=1:1:Nofk
            [mu,V] = stats_wo_kseg(Price,trade_date, k, horizon, ...
                sample_frequency,number_of_samples,rate_of_decay);
            [temp0, temp1, U_star_l] = OOS_PBCV(x, mu, V);
            U_star = U_star + U_star_l;
        end
        U_star = U_star / Nofk;
        
        
        % changes made here
        %[x0,x] = cvx_mv_PBR2(mu,V,A,mean(mu),U_star^0.5);
        x = cvx_cv_PBR(trade_date, V, hist_r, U_star^0.5);
        
        
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

    fprintf('your final wealth %f\n',wealth);
    plot(hist_mvo); hold on
    tot_ret = (hist_mvo(end) - hist_mvo(1)) / hist_mvo(1);
    std(price2ret(hist_mvo))
    (tot_ret - rf) / std(price2ret(hist_mvo))
    skewness(price2ret(hist_mvo))
    kurtosis(price2ret(hist_mvo))
    maxdrawdown(hist_mvo)
   
    benchmark_x0 = x0;  
    benchmark_x = x; 
    rate_of_decay = 1 - r_w_f_o_y_e^(sample_frequency/52);
    initial_wealth = wealth;
    benchmark_wealth = wealth;	

    rebalance_dates = start + horizon*(0:number_rebalances-1);

    hist_benchmark = zeros(1,length(rebalance_dates));
    hist_mvo = zeros(1,length(rebalance_dates));
    acc_cost1 = zeros(1,length(rebalance_dates));
    acc_cost2 = zeros(1,length(rebalance_dates));
    
    wealth = 10000;
    x0 = .3;
    x = (.7/n)*e;
       
    for i = 1:length(rebalance_dates)
    %for i = 1:1

        trade_date = rebalance_dates(i);

        [mu,V] = adapted_stats(Price,trade_date, ...
                horizon,sample_frequency,number_of_samples,rate_of_decay);
        mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;

        benchmark_risk = sqrt(e'*V*e)/(n+1);
        sigma = allowable_risk*benchmark_risk; 

        xx0 = x0;
        xx = x;
        %V = nearestSPD(V);
        [x0,x] =  cvx_markowitz(mu0,mu,V,sigma,xx0,xx,trans_cost);
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
    tot_ret = (hist_mvo(end) - hist_mvo(1)) / hist_mvo(1);
    std(price2ret(hist_mvo))
    (tot_ret - rf) / std(price2ret(hist_mvo))
    skewness(price2ret(hist_mvo))
    kurtosis(price2ret(hist_mvo))
    maxdrawdown(hist_mvo)
end
