/*************************************************
Title: 1c.Descriptive_L2
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

/*one obs per hospital - 119 hospitals*/
data hosp;
set cabg;
by dshospid;
if first.dshospid;
run;

ods html file = "C:\Users\&user\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\output\descriptive\1c.Descriptive_L2.html";

/*categorical var - teaching status & ownership*/
title "Hospital ownership";
proc freq data = hosp;
table hosp_cntrl/list missing nocum;
run;

title "Hospital teaching status";
proc freq data = hosp;
table hosp_teach/list missing nocum;
run;

/*continuous var - volume*/
title "Hospital volume";
proc univariate data = hosp;
var hospN;
hist hospN / normal;
run;
title "";

/*get mean LOS by hospital*/
proc sql;
	create table mean_los_by_site as
	select distinct dshospid
	, mean(los) as mean_los
	from cabg
	group by dshospid
	order by dshospid;
quit;

/*Distribution of mean LOS*/
title "Distribution of mean LOS by hospital";
proc univariate data = mean_los_by_site;
var mean_los;
histogram mean_los / normal;
label mean_los = "Mean LOS by hospital";
run;
	
ods html close;	
	