% PURPOSE: main program of Assignment1 for OPT for Financial Engineering 
% Cornell MFE major; Prof. Renegar 
% ----------------------------------------------------------
% written by:
% Yuzhe Shen, ys779@cornell.edu
% Renxuan Liu, rl682@cornell.edu
% Zhenghong Li, zl553@cornell.edu
% ORIE Cornell University
%------------------------------------------------------------

%%

function [mu,V] = stats(rets,start_date,num_samples,rate_of_decay,rolling_window)
    % it?s cumbersome to code with long names, so let?s abbreviate:
    S_R = rets; s_d = start_date; n_s = num_samples; r_o_d = rate_of_decay;
    
    % now it is time to construct the weight
    if rolling_window == 1
        n_s = n_s;
    else
        n_s = length(S_R)-1;
    end
    w = (1/(1-r_o_d)).^ [1:n_s];
    
    w=w./sum(w);
    mu=S_R(s_d:s_d+n_s-1,:)' * w';
    V=S_R(s_d:s_d+n_s-1,:)' * diag(w) * S_R(s_d:s_d+n_s-1,:) - mu * mu';
end
