%--------------------------------------------
% The main entrance of back-testing system
%--------------------------------------------

function multi_period

    load Hist.mat; 
    Price = csvread('data_v2.csv',1,1);
    Price = Price(:, 11:14);
    n = size(Price,2);
    e = ones(n,1);
    horizon = 4;
    start = 400;
    number_rebalances = 100;
    number_of_samples = 100;
    sample_frequency = 2;
    r_w_f_o_y_e = .4;
    allowable_risk = 1;
    trans_cost = 0;
    wealth = 10000;
    x0 = .3;
    x = (.7/n)*e;

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
        [x0,x] = solve_mv_PBR(x, mu, V);
        acc_cost2(i) = acc_cost2(max(1,i-1))-x0-sum(x)+1;
        
        %wealth = wealth*(x0 + sum(x));
        x
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
    std(price2ret(hist_mvo))

end
