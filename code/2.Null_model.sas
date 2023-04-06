/*************************************************
Title: 2.Null_model
Authors: Thea Bourdeau, Yifan Hu, Mengdi Ji, Grace Joachim, Danielle Smith, Hannah Van Wyk 
Date: 4.6.2023
*************************************************/

/*setup*/
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";
ods graphics on  / attrpriority = none;
ods trace on;

/*filepaths*/
%let user = abourdea;
%put &user;

libname dropbox "C:\Users\&user\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\data";

/*load dataset with formats etc. from DropBox*/
data cabg;
set dropbox.cabg_fmt;
run;

/*model 1: null model*/
/*fit model*/
title "Model 1: Null Model or Intercept Only Model";
title2 "AKA Variance Components Model";
proc mixed data = cabg covtest cl method=reml PLOTS(MAXPOINTS=100000);
  class dshospid;
  model log_los = / solution ddfm=sat;
  random int / subject=dshospid solution;
  ods output solutionR = eblupsdat1;
run;

/*histogram and qqplot of eblups for random intercept*/
ods graphics on;
ods listing;
proc univariate data=eblupsdat1;
  where effect="Intercept";
  var estimate;
  histogram / normal kernel;
  qqplot/ normal(mu=est sigma=est);
run;