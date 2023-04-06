/*************************************************
Title: 1.Descriptive
Authors: Thea Bourdeau, Yifan Hu, Mengdi Ji, Grace Joachim, Danielle Smith, Hannah Van Wyk 
Date: 3.22.2023
*************************************************/

/*setup*/
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";
ods graphics on  / attrpriority = none;
ods trace on;

/*filepaths*/
%let user = abourdea;
%put &user;

libname dropbox "C:\Users\&user\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\data";

/*formats*/
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

/*import data*/
data cabg;
set dropbox.cabg;
/*add formats*/
format 	hosp_cntrl hosp_cntrl.
		hosp_teach hosp_teach.
		female female.
		cm_obese cm_obese.
		pay1 pay.
		race race.;
/*make dhospid numeric*/
new = input(dshospid, 8.);
   drop dshospid;
   rename new=dshospid;
/*binary variabe for median LOS*/
if 2 <= los <= 8 then los_c=0;
else los_c = 1;
/*log-transform LOS for later modeling*/
log_los = log(los);
run;

/*look at data*/
proc contents data = cabg;
run;

/*check distribution of outcome PRE log transformation*/
title "Check Distribution of los (Outcome, pre-transformation)";
proc univariate data=cabg;
  var los;
  histogram / normal;
  qqplot / normal(mu=est sigma=est);
run;

/*check the distribution of log transformed outcome*/
title "Check Distribution of log_los (Outcome)";
proc univariate data=cabg;
  var log_los;
  histogram / normal;
  qqplot / normal(mu=est sigma=est);
run;

/*macros for descriptive analytics*/
/*full dataset*/
ods html file = "C:\Users\abourdea\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\output\descriptive\descriptive_anlaytics_26MAR2023.html";

/*categorical*/
%macro cat(var);
proc freq data = cabg;
tables &var;
run;
%mend;

/*numeric*/
%macro num(var);
proc means data = cabg;
var &var;
run;
%mend;

/*hosp level*/
%cat(hosp_cntrl);
%cat(hosp_teach);
%num(hospN);
%num(dshospid);

/*patient level*/
%num(id);
%num(age);
%cat(female);
%num(los);
%num(wcharlsum);
%cat(cm_obese);
%cat(pay1);
%cat(race);

ods html close;

/*by los*/
ods html file = "C:\Users\abourdea\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\output\descriptive\descriptive_by_los_28MAR2023.html";

/*categorical vars*/
%macro cat2(var);
proc freq data = cabg;
tables &var*los_c/nopercent norow;
run;
%mend;

/*numeric vars*/
%macro num2(var);
proc means data = cabg;
var &var;
class los_c;
run;
%mend;

/*hosp level*/
%cat2(hosp_cntrl);
%cat2(hosp_teach);
%num2(hospN);
%num2(dshospid);

/*patient level*/
%num2(id);
%num2(age);
%cat2(female);
%num2(los);
%num2(wcharlsum);
%cat2(cm_obese);
%cat2(pay1);
%cat2(race);

ods html close;

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

/*output processed dataset to DropBox*/
/*data dropbox.cabg_fmt;
set cabg;
run;*/


