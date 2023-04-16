data hosp;
set cabg2;
by dshospid;
if first.dshospid;
run;

/*patient age - L1*/
proc univariate data=cabg2;
var age;
histogram age/normal;
run;

/*race - L1*/
proc sgplot data=cabg2;
vbar race;
run;

/*hospital control - L2*/
proc sgplot data=hosp;
vbar hosp_cntrl;
run;


/*age by los - L1*/
proc sgplot data=cabg2;
vbox age /category=los_c;
run;

/*sex by los- L1*/
proc sgplot data=cabg2;
vbox log_los /category=female;
run;

/*charlson score by los- L1*/
proc sgplot data=cabg2;
vbox wcharlsum /category=los_c;
run;

/*elixhauser by los- L1*/
proc sgplot data=cabg2;
vbox log_los /category=cm_obese;
run;

/*hospital control by los- L2*/
proc sgplot data=hosp;
vbox log_los /category=hosp_cntrl;
run;

/*teaching status by los- L2*/
proc sgplot data=hosp;
vbox log_los /category=hosp_teach;
run;
