/* ============================================================
   Nike Stock Time Series Analysis
   Author: Braulio Manriquez

   Objective:
   Analyze Nike monthly stock prices and log returns using
   time series methods, including stationarity testing and
   ARIMA/ARMA model estimation.

   Methods:
   - Import monthly stock data
   - Convert date variable to SAS date format
   - Plot closing prices and log returns
   - Test stationarity using ADF test
   - Estimate AR(1), MA(1), and ARMA(1,1) models
   ============================================================ */


/* Import Excel data */
proc import datafile="data/Nike_first_day_each_month.xlsx"
    out=work.nike_raw
    dbms=xlsx
    replace;
    sheet="in";
    getnames=yes;
run;


/* Clean and format date variable */
data work.nike_ts;
    set work.nike_raw;

    Date_only = scan(Date, 1, ' ');
    SAS_Date = input(Date_only, yymmdd10.);
    format SAS_Date yymmdd10.;

    keep SAS_Date Close Open High Low Volume ticker;
    rename SAS_Date = Date;
run;


/* Plot Nike monthly closing price */
proc sgplot data=work.nike_ts;
    series x=Date y=Close;
    xaxis type=time;
    title "Nike Monthly Closing Price";
run;


/* Calculate log closing price and monthly log returns */
data work.nike_ts;
    set work.nike_ts;

    log_close = log(Close);
    log_return = log(Close) - log(lag(Close));
run;


/* Plot Nike monthly log returns */
proc sgplot data=work.nike_ts;
    series x=Date y=log_return;
    xaxis type=time;
    title "Nike Monthly Log Returns";
run;


/* Test stationarity of log returns using ADF test */
proc arima data=work.nike_ts;
    identify var=log_return nlag=24 stationarity=(adf=(0,1,2,3)) scan;
    title "ADF Test for Nike Monthly Log Returns";
run;
quit;


/* Estimate AR(1), MA(1), and ARMA(1,1) models */
proc arima data=work.nike_ts;
    identify var=log_return nlag=24 scan;

    estimate p=1;
    estimate q=1;
    estimate p=1 q=1;

    title "ARIMA/ARMA Model Estimation for Nike Monthly Log Returns";
run;
quit;
