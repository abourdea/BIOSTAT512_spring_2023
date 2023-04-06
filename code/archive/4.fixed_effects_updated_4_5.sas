/*same code as in descriptive file*/

libname b512 "/home/u58566978/b512/project";

data cabg; set b512.cabg; run;

proc contents data=cabg; run;

/*formats for vars*/
proc format;
value hosp_cntrl	1="government, nonfederal" 
					2="nongovernment, nonprofit"
					3="investor owned, for profit";
value hosp_teach	1="teaching"
					2="nonteaching";
value female		0="male"
					1="female";
value cm_obese		0="not present"
					1="present";
value pay			1="medicare"
					2="medicaid"
					3="private inc. HMO"
					4="self pay"
					5="no charge"
					6="other";
value race			1="white"
					2="black"
					3="hispanic"
					4="asian or pacific islander"
					5="native american"
					6="other";
run;

data cabg; set cabg;
format 	hosp_cntrl hosp_cntrl.
		hosp_teach hosp_teach.
		female female.
		cm_obese cm_obese.
		pay1 pay.
		race race.;
run;

/*changing dshospid to numeric var*/
data cabg; set cabg;
   new = input(dshospid, 8.);
   drop dshospid;
   rename new=dshospid;
run;

/*natural log of outcome los*/
data cabg;
set cabg;
log_los=log(los);
run;

data b512.cabg2; set cabg; run;

/*************************************new code*************************************/

/*model 1: null model*/
/*fit model*/
title "Model 1: Null Model or Intercept Only Model";
title2 "AKA Variance Components Model";
proc mixed data=b512.cabg2 covtest cl method=reml PLOTS(MAXPOINTS=100000);
  class dshospid;
  model log_los = / solution ddfm=sat;
  random int / subject=dshospid solution;
  ods output solutionR = eblupsdat1;
run;

/*model 2:  random effects*/
/*fit model*/
title "Model 2: Model with Random Intercepts and Random Slopes";
proc mixed data=b512.cabg2 method=reml;
  class dshospid id hosp_cntrl hosp_teach female cm_obese pay1 race;
  model log_los = hospN age wcharlsum hosp_cntrl hosp_teach female cm_obese pay1 race / solution chisq ddfm=sat;
  random intercept age / subject=dshospid solution type=un g gcorr ;
run;

title1 "Model 3: Model without Random Slopes";
proc mixed data=b512.cabg2 method=reml;
  class dshospid id hosp_cntrl hosp_teach female cm_obese pay1 race;
  model log_los = hospN wcharlsum hosp_cntrl hosp_teach female cm_obese pay1 race / solution chisq ddfm=sat;
  random intercept / subject=dshospid solution type=un g gcorr ;
run;

title "Test of Radom Effects of Random Slopes";
data test;
  LLFull=16263.1;
  LLRed =16433.0;
  Chi_square=llred-llfull;

  pvalue=1-probchi(chi_square,1);
run;

/*************************************Grace's code*************************************/
/*only including random intercept in model*/

/*model 4: adding level 1 variables*/
title "model 4 - L1 vars";
proc mixed data=b512.cabg2 covtest method=ml;
  class dshospid id female cm_obese pay1 race;
  model log_los = age wcharlsum female cm_obese pay1 race / solution chisq ddfm=sat;
  random intercept / subject=dshospid solution type=un g gcorr ;
run;

/*null model
between/intercept=0.02593
within/error=0.2678
ICC=0.02593/(0.02593+0.2678)=8.83%
about 9% of the total variability in los is between hospital; 
91% of total variability in los is within hospital*/


/*level 1 R^2 calculation*/
/*between/intercept=0.01978
within/error=0.2147
R^2 level 1=(0.2678-0.2147)/0.2678=19.8%
19.8% of level 1's variance is explained by adding these variables*/

/*H0: level 1 vars=0; H1: at least one var does not=0*/
title "null model for LR test";
proc mixed data=b512.cabg2 covtest method=ml;
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

/*model 5: adding level 2 vars*/
title "model 5 - L2 vars";
proc mixed data=b512.cabg2 method=ml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN/ddfm=sat solution;
  random intercept / subject=dshospid type=un;
run;

/*level 2 R^2 calculation*/
/*between/intercept=0.01686
within/error=0.2147
R^2 level 2=(0.01978-0.01686)/0.01978=14.8%
8.8% of level 2's variance is explained by adding these variables*/


/*H0: level 2 vars=0; H1: at least one var does not=0*/
data lrtest;
LLfull=16138.8;
LLred=16155.72;
Chi_square=llred-llfull;
pval=1-probchi(chi_square,3);
run;
/*model is made significantly better including these vars*/

/*model 6: interactions*/
title "model 6 - L1 interactions";
proc mixed data=b512.cabg2 method=ml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN age*female female*race/ddfm=sat solution;
  random intercept / subject=dshospid type=un;
run;

/*R^2 calculation*/
/*between/intercept=0.01681
within/error=0.2146
R^2 level 1=(0.2147-0.2146)/0.2147=0.05%%
0.05% of level 1's variance is explained by adding these interactions*/

/*H0: level 2 vars=0; H1: at least one var does not=0*/
data lrtest;
LLfull=16133.6;
LLred=16138.8;
Chi_square=llred-llfull;
pval=1-probchi(chi_square,2);
run;
/*model is not made significantly better including these vars according to LR test; age*female barely
significant, female*race not significant*/