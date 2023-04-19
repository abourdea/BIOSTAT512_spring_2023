/*************************************************
Title: 5.Diagnostic_update
Authors: Thea Bourdeau, Yifan Hu, Mengdi Ji, Grace Joachim, Danielle Smith, Hannah Van Wyk 
Date: 4.8.2023
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

/*Calculate proportion CABG by hospital*/
proc sql;
	create table cabg_prop_by_hosp as select distinct
	dshospid
	, count(id) as sum_cabg
	, calculated sum_cabg / hospN as prop_cabg
	from cabg
	group by dshospid;
quit;

/*merge to main dataset*/
proc sql;
	create table cabg as select
	a.*
	, b.sum_cabg
	, b.prop_cabg
	from cabg a left join cabg_prop_by_hosp b
	on a.dshospid = b.dshospid;
quit;

ods html file = "C:\Users\&user\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\output\modeling process\diagnostics_4.12.2023.html";

/*fit model*/
title "Final model";
proc mixed data = cabg method = reml plots(maxpoints=100000)=residualpanel;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept age wcharlsum / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblups_final;
run;
ods trace off;

title "Distribution of Random Intercepts";
proc univariate data=eblups_final;
 var estimate;
 histogram/ normal kernel;
 qqplot/ normal(mu=est sigma=est);
 where effect="Intercept";
run;

/*model 5:  random age slope*/
/*fit model*/
title "Model 5: Model with Random Intercepts and Random Slope for age";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept age / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat2;
run; /*LL=16259.8*/

*Check distribution of the random slopes;
title "Check Distribution of Eblups (Slope for age)";
proc univariate data=eblupsdat2;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="age";
run;

/*model 7:  random wcharlsum slope*/
/*fit model*/
title "Model 7: Model with Random Intercepts and Random Slope for Charlson score";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept wcharlsum / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat4;
run; /*LL=16219.7*/

*Check distribution of the random slopes;
title "Check Distribution of Eblups (Slope for Charlson score)";
proc univariate data=eblupsdat4;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="wcharlsum";
run;

ods html close;
