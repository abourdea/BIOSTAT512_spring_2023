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

title1 "Model 3: Model without Random Slopes";
proc mixed data=cabg method=reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept / subject=dshospid solution type=un g gcorr ;
run; /*LL=16268.4*/

/*testing inclusion of random intercept*/
title "Model 4: no random effects";
proc mixed data=cabg method=reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
run; /*LL=17014.2*/

title "Test of random intercept";
data test;
  LLFull=16268.4;
  LLRed =17014.2;
  Chi_square=llred-llfull;

  pvalue=0.5*(1-probchi(chi_square,1));
run;
/*p=0, include random intercept in model*/

/*testing different random slopes, comparing to model with only random intercept*/

/*model 5:  random age slope*/
/*fit model*/
title "Model 5: Model with Random Intercepts and Random Slope for age";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept age / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat2;
run; /*LL=16259.8*/

proc print data = eblupsdat2;
run;

title "Test of Random Effects of Random Slope for age";
data test;
  LLFull=16259.8;
  LLRed =16268.4;
  Chi_square=llred-llfull;

  pvalue=1-probchi(chi_square,1);
run;
/*p=0.00336163*/

*Check distribution of the random slopes;
title "Check Distribution of Eblups (Slope for age)";
proc univariate data=eblupsdat2;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="age";
run;

/*model 6:  random hosp_cntrl slope*/
/*fit model*/
title "Model 6: Model with Random Intercepts and Random Slope for control";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept hosp_cntrl / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat3;
run; /*LL=16263.8*/
/*Convergence criteria met but final Hessian is not positive definite.*/

proc print data = eblupsdat3;
run;

title "Test of Random Effects of Random Slope for control";
data test;
  LLFull=16263.8;
  LLRed =16268.4;
  Chi_square=llred-llfull;

  pvalue=1-probchi(chi_square,1);
run;
/*p=0.0319719562*/

*Check distribution of the random slopes;
title "Check Distribution of Eblups (Slope for hosp_cntrl)";
proc univariate data=eblupsdat3;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="hosp_cntrl";
run;

/*model 7:  random hosp_teach slope*/
/*fit model*/
title "Model 7: Model with Random Intercepts and Random Slope for teaching";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept hosp_teach / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat4;
run; /*LL=16267.8*/
/*Convergence criteria met but final Hessian is not positive definite.*/

proc print data = eblupsdat4;
run;

title "Test of Random Effects of Random Slope for hosp_teach";
data test;
  LLFull=16267.8;
  LLRed =16268.4;
  Chi_square=llred-llfull;

  pvalue=1-probchi(chi_square,1);
run;
/*p=0.4385780261*/

*Check distribution of the random slopes;
title "Check Distribution of Eblups (Slope for hosp_teach)";
proc univariate data=eblupsdat4;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="hosp_teach";
run;

/*model 8:  random hospN slope*/
/*fit model*/
title "Model 8: Model with Random Intercepts and Random Slope for hospN";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept hospN / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat5;
run; /*LL=*/
/*WARNING: Did not converge.*/

/*****age was the only option that converged without issue and had a significant p for the LL ratio test*****/