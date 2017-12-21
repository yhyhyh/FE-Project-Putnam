# FE-Project-Putnam

This is a breif document for the Financial Engineering project sponsored by Putnam. It explains the time series and PBR optimization part, including the introduction of the system structure and the user manuscript.

## System Structure

The back-testing system consists of:
 - The time series modeling (implemented in R),
 - PBR optimization (implemented in MATLAB), 
 - Connecting part (transform the R type covariance matrix into ".mat" file to be imported to MATLAB).

There are three data files we extracted from the raw data which will be used in the back-tests. They are:
 * cov_percent.mat - The covariance matrix for every rebalance dates. Calculated by the time series modules in R and should be transformed into MATLAB format.
 * hist_r_file.mat - Return series of every trading day. Calculated by the time series modules in R and should be transformed into MATLAB format.
 * Hist.mat: The price level data copied from the given file.

In the current version, file "cov_percent.mat" and "hist_r_file.mat" is already prepared to run the PBR or benchmark backtesting. If you want them to be changed, please follow the user manuscript of the time series modules to re-calculate them.

The top function of the MATLAB part is [multi_period.m], which forms the pipeline of backtesting and collects the return series. Other function being called is listed below:
 * [adapted_stats.m] - simple way to calculate returns and covariances
 * [cvx_cv_PBR.m] - (cvar-PBR) model implemented in CVX
 * [cvx_markowitz.m] - traditional markowitz model implemented in CVX
 * [cvx_minvar.m] - strategy minimizing the variance, implemented in CVX
 * [cvx_riskparity.m] - risk-pariry strategy implemented in CVX
 * [cvx_Umin_mv2.m] - decide the lower bound of U
 * [findUstar.m] - use k-fold cross validation to decide the suitable contraint parameter U
 * [metrics.m] - calculate performance metrics
 * [nearestSPD.m] - find nearest positive semi-definite matrix
 * [OOS_PBCV.m] - gradient descent function to find optimal U
 * [stats_wo_kseg.m] - simple way to calculate returns and covariances in k-fold

## User Guide

1. Get R Studio and MATLAB and corresponding CVX package installed. Copy all sourse codes into the same directory.
2. Run the R code to produce return and covariance file
3. Convert the Rdata file to csv file, then mat file
4. Make any changes on the default parameters in the beginning of multi-period.m, run the main function.
5. Take the return series in res_all.csv, paste it into AMDATA.csv with a meaningful title.
6. Run metrics.m to calculate the performance metrics. The output is in metrics.csv file.


   [multi_period.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/multi_period.m>
   [adapted_stats.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/adapted_stats.m>
   [cvx_cv_PBR.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/cvx_cv_PBR.m>
   [cvx_markowitz.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/cvx_markowitz.m>
   [cvx_minvar.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/cvx_minvar.m>
   [cvx_riskparity.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/cvx_riskparity.m>
   [cvx_Umin_mv2.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/cvx_Umin_mv2.m>
   [findUstar.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/findUstar.m>
   [metrics.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/metrics.m>
   [nearestSPD.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/nearestSPD.m>
   [OOS_PBCV.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/OOS_PBCV.m>
   [stats_wo_kseg.m]: <https://github.com/yhyhyh/FE-Project-Putnam/blob/master/stats_wo_kseg.m>
