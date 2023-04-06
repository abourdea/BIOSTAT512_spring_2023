/*************************************************
Title: 3.Fixed_effects
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

proc contents data = cabg;
run;

/*only including random intercept in model*/

/*null model
between/intercept=0.02593
within/error=0.2678
ICC=0.02593/(0.02593+0.2678)=8.83%
about 9% of the total variability in los is between hospital; 
91% of total variability in los is within hospital*/

/*model 2: adding level 1 variables*/
title "model 2 - L1 vars";
proc mixed data=cabg covtest method=ml;
  class dshospid female cm_obese pay1 race;
  model log_los = age wcharlsum female cm_obese pay1 race / solution chisq ddfm=sat;
  random intercept / subject=dshospid solution type=un g gcorr ;
run;

/*level 1 R^2 calculation*/
/*between/intercept=0.01978
within/error=0.2147
R^2 level 1=(0.2678-0.2147)/0.2678=19.8%
19.8% of level 1's variance is explained by adding these variables*/

/*H0: level 1 vars=0; H1: at least one var does not=0*/
title "null model for LR test";
proc mixed data=cabg covtest method=ml;
  class dshospid id female cm_obese pay1 race;
  model log_los = / solution chisq ddfm=sat;
  random intercept / subject=dshospid solution type=un g gcorr ;
run;

data lrtest;
LLfull=16155.7;
LLred=18936.6;
Chi_square=llred-llfull;
pval=1-probchi(chi_square,6);
run;
/*model is made significantly better including these vars*/

/*model 3: adding level 2 vars*/
title "model 3 - L2 vars";
proc mixed data=cabg method=ml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg/ddfm=sat solution;
  random intercept / subject=dshospid type=un;
run; /*LL:16138.2*/

/*level 2 R^2 calculation*/
/*between/intercept=0.01686
within/error=0.2147
R^2 level 2=(0.01978-0.01686)/0.01978=14.8%
14.8% of level 2's variance is explained by adding these variables*/


/*H0: level 2 vars=0; H1: at least one var does not=0*/
data lrtest;
LLfull=16138.2;
LLred=16155.7;
Chi_square=llred-llfull;
pval=1-probchi(chi_square,3);
run;
/*model is made significantly better including these vars*/

/*model 4: interactions*/
title "model 4 - L1 interactions";
proc mixed data=cabg method=ml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg age*female female*race/ddfm=sat solution;
  random intercept / subject=dshospid type=un;
run;

/*R^2 calculation*/
/*between/intercept=0.01682
within/error=0.2146
R^2 level 1=(0.2147-0.2146)/0.2147=0.05%%
0.05% of level 1's variance is explained by adding these interactions*/

/*H0: level 2 vars=0; H1: at least one var does not=0*/
data lrtest;
LLfull=16133.6;
LLred=16138.2;
Chi_square=llred-llfull;
pval=1-probchi(chi_square,2);
run;
/*model is not made significantly better including these vars according to LR test; age*female barely
significant, female*race not significant*/

/*try adding interaction btwn wcharlsum and obese based on plots*/
/*model 5: wcharlsum*obese*/
title "model 5 - add interaction btwn wcharlsum and obese";
proc mixed data=cabg method=ml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN wcharlsum*cm_obese/ddfm=sat solution;
  random intercept / subject=dshospid type=un;
run;

/*H0: interaction=0; H1: interaction not=0*/
data lrtest;
LLfull=16137.5;
LLred=16138.2;
Chi_square=llred-llfull;
pval=1-probchi(chi_square,2);
run; /*not significant, exclude*/

/* Model 3 (model with L2 var added, no interactions) is the best model. Move forward with model 3 to random effects testing. */
