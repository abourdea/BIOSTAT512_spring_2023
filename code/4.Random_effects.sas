/*************************************************
Title: 2.Null_model
Authors: Thea Bourdeau, Yifan Hu, Mengdi Ji, Grace Joachim, Danielle Smith, Hannah Van Wyk 
Date: 4.5.2023
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

/*FINAL MODEL FROM FIXED EFFECTS: model 3: adding level 2 vars*/
/* title "model 3 - L2 vars"; */
/* proc mixed data=cabg method=ml; */
/*   class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach; */
/*   model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg/ddfm=sat solution; */
/*   random intercept / subject=dshospid type=un; */
/* run; */

/*model 2:  random effects*/
/*fit model*/
title "Model 2: Model with Random Intercepts and Random Slopes";
proc mixed data = cabg method = reml;
  class dshospid hosp_cntrl hosp_teach female cm_obese pay1 race;
  model log_los = hospN age wcharlsum hosp_cntrl hosp_teach female cm_obese pay1 race / solution chisq ddfm=sat;
  random intercept age / subject=id solution type=un g gcorr ;
  ods output solutionR = eblupsdat2;
run;

proc print data = eblupsdat2;
run;

title1 "Model 3: Model without Random Slopes";
proc mixed data=b512.cabg method=reml;
  class dshospid id hosp_cntrl hosp_teach female cm_obese pay1 race;
  model log_los = hospN wcharlsum hosp_cntrl hosp_teach female cm_obese pay1 race / solution chisq ddfm=sat;
  random intercept / subject=id solution type=un g gcorr ;
run;

title "Test of Radom Effects of Random Slopes";
data test;
  LLFull=16557.4;
  LLRed =16734.1;
  Chi_square=llred-llfull;

  pvalue=1-probchi(chi_square,1);
run;

*Check distribution of the random slopes;
title "Check Distribution of Eblups (Slopes)";
proc univariate data=eblupsdat2;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="age";
run;
