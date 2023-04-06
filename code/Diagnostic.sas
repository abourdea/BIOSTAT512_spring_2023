
/*Diagnostic-check for distribution of random intercept*/
ods trace on;
ods graphics;
title1 "LMM: Final Model";
proc mixed data=b512.cabg2 method=ml ;
class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN/ddfm=sat solution;
  random intercept / subject=dshospid solution type=un g gcorr;
  ods output solutionR = Eblups_final;
run;
ods trace off;
title "Distribution of Random Intercepts";
proc univariate data=eblups_final;
 var estimate;
 histogram;
 qqplot/ normal(mu=est sigma=est);
 where effect="Intercept";
run;
/* residual normality and homescedascity*/
ods graphics on;
title1 "LMM5: Final Model";
proc mixed data=b512.cabg2 method = ml PLOTS(MAXPOINTS=100000);;
 class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
 model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN/ddfm=sat solution residual;
random intercept / subject=dshospid solution type=un g gcorr;
 ods output solutionR = Eblups_data;
run;
ods graphics off;

