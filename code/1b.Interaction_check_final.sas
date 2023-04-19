/*************************************************
Title: 1b.Interaction_check
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

ods html file = "C:\Users\&user\Dropbox (University of Michigan)\BIOSTAT512_Final_Project\output\descriptive\1b.Interaction_check.html";

/*scatterplot of log_los vs. age by gender*/
title "regressions of log_los vs. age by gender";
proc sgplot data=cabg;
reg y=log_los x=age / group=female;
run;

/*cluster boxplots of log_los vs. race by gender*/
title "cluster boxplots of log_los vs. race by gender";
proc sgpanel data=cabg;
panelby female;
vbox log_los / category=race;
run;

/*scatterplot of log_los vs. wcharlsum by cm_obese*/
title "regressions of log_los vs. wcharlsum by cm_obese";
proc sgplot data=cabg;
reg y=log_los x=wcharlsum  / group=cm_obese;
run;

/*scatterplot of log_los vs. age by race*/
/*title "regressions of log_los vs. age by race";
proc sgplot data=cabg;
reg y=log_los x=age / group=race;
run;*/

/*scatterplot of log_los vs. wcharlsum by gender*/
/*title "regressions of log_los vs. wcharlsum by gender";
proc sgplot data=cabg;
reg y=log_los x=wcharlsum  / group=female;
run;*/

/*scatterplot of log_los vs. wcharlsum by race*/
/*title "regressions of log_los vs. wcharlsum by race";
proc sgplot data=cabg;
reg y=log_los x=wcharlsum  / group=race;
run;*/

/*scatterplot of log_los vs. cm_obese by race*/
/*title "regressions of log_los vs. race by cm_obese";
proc sgplot data=cabg;
reg y=log_los x=race / group=cm_obese;
run;*/

/*scatterplot of log_los vs. age by cm_obese*/
/*title "regressions of log_los vs. age by cm_obese";
proc sgplot data=cabg;
reg y=log_los x=age / group=cm_obese;
run;*/

ods html close;