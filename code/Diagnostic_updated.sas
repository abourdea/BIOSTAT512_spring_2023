
/*Final model: Model three with age as random slope*/
title "Model 5: Model with Random Intercepts and Random Slope for age";
proc mixed data = cabg method = reml;
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution chisq ddfm=sat;
  random intercept age / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat2;
ods trace off;
title "Distribution of Random Intercepts";
proc univariate data=eblups_final;
 var estimate;
 histogram/ normal kernel;
 qqplot/ normal(mu=est sigma=est);
 where effect="Intercept";
run;
title "Check Distribution of random slope";
proc univariate data=eblupsdat2;
  var estimate;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  where effect="age";
run;
/* residual normality and homescedascity*/
ods graphics on;
title1 "LMM5: Final Model with age as random slop";
proc mixed data = cabg method = ml PLOTS(MAXPOINTS=100000);
  class dshospid id female cm_obese pay1 race hosp_cntrl hosp_teach;
  model log_los = age wcharlsum female cm_obese pay1 race hosp_cntrl hosp_teach hospN prop_cabg / solution residual chisq ddfm=sat;
  random intercept age / subject=dshospid solution type=un g gcorr ;
  ods output solutionR = eblupsdat2;
run;
ods graphics off;

