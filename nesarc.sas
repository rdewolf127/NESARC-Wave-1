libname mydata "/courses/d1406ae5ba27fe300 " access=readonly;
data new; set mydata.nesarc_pds;
keep AGE agegroup S1Q9A S1Q9B S1Q20 workinterfere S3CD3Q13A opioidage S3CD3Q13B opioidabuse opioidabusetop10 S3CQ12A9 S4AQ7 majordepression S9Q7 genanxiety opioidabuseclean;
label AGE = "Age"
      agegroup = "Age"
      S1Q9A="Business or Industry"
      S1Q9B="Occupation"
      S1Q20="Pain Interfered with normal work(last 4 weeks)"
      workinterfere =="Pain Interfered with normal work(last 4 weeks)"  
      S3CD3Q13A="Age At Onset of Opioid Abuse"
      opioidage = "Age At Onset of Opioid Abuse"  
      S3CD3Q13B="Number of episodes of opioid abuse"
      opioidabuse="At least 1 opioid abuse episode"
      opioidabusetop10="5 or more episodes of opioid abuse"
      S3CQ12A9="Arrested due to opioid use"
      S4AQ7="Number of episodes of major depression"
      majordepression="At least 1 major depression episode"
      S9Q7 ="Number of episodes of generalized anxiety disorder"
      genanxiety = "At least 1 generalized anxiety episode";

/*change unknown responses to missing value category*/
array missing (2) S1Q20 S3CQ12A9;
do i = 1 to 2;
	if missing(i) = 9 then missing(i) = .;
end;

/*change unknown responses to mode (based on results from proc univariate*/
array mode (3) S3CD3Q13B S4AQ7 S9Q7;
do i = 1 to 3;
	if mode(i) = 99 then mode(i) = 1;
end;

/*change unknown responses to mean* (based on results from proc univariate*/
array mean_ (1) S3CD3Q13A;
do i = 1 to 1;
	if mean_(i) = 99 then mean_(i) = 24;
end;

/*change missing category to did not work for pay*/
array newcat (2) S1Q9a S1Q9b;
do i = 1 to 2;
	if newcat(i) = . then newcat(i) = 15;
end;

/*Filter to only adults who began abusing opioids as adults*/
if S3CD3Q13A GT 0;
if AGE GE 18;

/*bin current age of respondents*/
if Age le 29 then agegroup = "1 - 18 to 29";
if Age ge 30 and age le 39 then agegroup = "2 - 30 to 39";
if age ge 40 and age le 49 then agegroup = "3 - 40 to 49";
if age ge 50 and age le 59 then agegroup = "4 - 50 to 59";
if age ge 60 then agegroup="5 - 60+";

/*bin age of opioid abuse onset*/
if S3CD3Q13A le 17 then opioidage = 18;
if S3CD3Q13A ge 18 and S3BD3Q2A le 29 then opioidage = 29;
if S3CD3Q13A ge 30 and S3BD3Q2A le 39 then opioidage = 39;
if S3CD3Q13A ge 40 and S3BD3Q2A le 49 then opioidage = 49;
if S3CD3Q13A ge 50 and S3BD3Q2A le 59 then opioidage = 59;
if S3CD3Q13A ge 60 then opioidage=60;

/*collapse work interference into T or F*/
if S1Q20 = 1 then workinterfere = 0;
if S1Q20 = 2 or S1Q20 = 3 or S1Q20 = 4 or S1Q20=5 then workinterfere = 1;

/*change no response for opioid arrest from 2 to 0 for charting*/
if S3CQ12A9 = 2 then S3CQ12A9 = 0;

/*collapse number of generalized anxiety disorder episodes into T or F*/
if S9Q7 ge 1 and S9Q7 le 99 then genanxiety = 1;
if S9Q7 = . then genanxiety = 0;

/*collapse number major depression episodes into T or F*/
if S4AQ7 ge 1 and S4AQ7 le 99 then majordepression = 1;
if S4AQ7 = . then majordepression = 0;

/*collapse number opioid abuse episodes into T or F*/
if S3CD3Q13B ge 1 and S3CD3Q13B le 98 then opioidabuse = 1;
if S3CD3Q13B = . then opioidabuse = 0;

/*parse opioid abusers with ge 5 episode as a T or F*/
if S3CD3Q13B ge 5 and S3CD3Q13B le 98 then opioidabusetop10 = 1;
if S3CD3Q13B = . or S3CD3Q13B le 4 then opioidabusetop10 = 0;

/*create opioid episode group without 98 outlier*/
if S3CD3Q13B ge 1 and S3CD3Q13B le 97 then opioidabuseclean = 1;
if S3CD3Q13B = . then opioidabuseclean = 0;
run;

/*frequency tables*/
proc freq; tables agegroup S1Q9A S1Q9B S1Q20 workinterfere opioidage S3CD3Q13A S3CD3Q13B opioidabuse opioidabusetop10 S3CQ12A9 S4AQ7 majordepression S9Q7 genanxiety;
run;
/*summary statistics*/
proc univariate; var S3CD3Q13B S4AQ7 S9Q7;
run;

proc univariate; var S3CD3Q13A;
where S3CD3Q13A LE 98;
run;

goptions reset=all;

/*univariate charts*/
proc gchart;vbar S3CD3Q13B/ type=pct;
proc gchart;vbar S4AQ7/ type=pct;
proc gchart;vbar S9Q7/ type=pct;
proc gchart;vbar S1Q9A/discrete type=pct raxis=axis1 maxis=axis2;
axis1 label=(angle=90 '% of respondents');
axis2 value=(angle=45 "Agriculture" "Mining" "Construction" "Manufacturing" "Transportation/Comm/Util" "Wholsale Trade" "Retail Trade" "Finance/Ins/RealEstate" "Business/Repair Svc" "PersonalSvc" "Entertain/Rec" "Professional/Related" "Public Admin" "ArmedSvc" "NoPaidWork/FamBus");
proc gchart;vbar S1Q9B/discrete type=pct raxis=axis1 maxis=axis2;
axis1 label=(angle=90 '% of respondents');
axis2 value=(angle=45 "Exec/Admin/Mgr" "Professional Specialty" "Technical/RelatedSupport" "Sales" "AdminSupport/Clerical" "Private Household" "ProtectiveSvc" "OtherSvc" "Farming/Forestry/Fishing" "Precision/Production/Craft/Repair" "Operators/Fabricators/Laborers" "Transportation/MaterialMoving" "Handlers/EquipCleaner/Laborer" "Military" "NoPaidWork/FamBus");

/*bivariate charts*/
proc gchart; vbar S1Q9A/discrete type=sum sumvar=opioidabuseclean raxis=axis1 maxis=axis2;
axis1 label=(angle=90 '# of opioid episodes');
axis2 value=(angle=45 "Agriculture" "Mining" "Construction" "Manufacturing" "Transportation/Comm/Util" "Wholsale Trade" "Retail Trade" "Finance/Ins/RealEstate" "Business/Repair Svc" "PersonalSvc" "Entertain/Rec" "Professional/Related" "Public Admin" "ArmedSvc" "NoPaidWork/FamBus");
run;
proc gchart; vbar S1Q9B/discrete type=sum sumvar=opioidabuseclean raxis=axis1 maxis=axis2;
axis1 label=(angle=90 '# of opioid episodes');
axis2 value=(angle=45 "Exec/Admin/Mgr" "Professional Specialty" "Technical/RelatedSupport" "Sales" "AdminSupport/Clerical" "Private Household" "ProtectiveSvc" "OtherSvc" "Farming/Forestry/Fishing" "Precision/Production/Craft/Repair" "Operators/Fabricators/Laborers" "Transportation/MaterialMoving" "Handlers/EquipCleaner/Laborer" "Military" "NoPaidWork/FamBus");
run;
proc gchart; vbar S1Q9A/discrete type=mean sumvar=opioidabusetop10;
proc gchart; vbar S1Q9B/discrete type=mean sumvar=opioidabusetop10;
proc gchart; vbar S1Q9A/discrete type=mean sumvar=workinterfere;
proc gchart; vbar S1Q9B/discrete type=mean sumvar=workinterfere; 
proc gchart; vbar S1Q9A/discrete type=mean sumvar=S3CQ12A9;
proc gchart; vbar S1Q9B/discrete type=mean sumvar=S3CQ12A9;
proc gchart; vbar S1Q9A/discrete type=mean sumvar=majordepression;
proc gchart; vbar S1Q9B/discrete type=mean sumvar=majordepression;
proc gchart; vbar S1Q9A/discrete type=mean sumvar=genanxiety;
proc gchart; vbar S1Q9B/discrete type=mean sumvar=genanxiety;
proc gchart; vbar opioidabuse/discrete type=mean sumvar=majordepression;
proc gchart; vbar opioidabuse/discrete type=mean sumvar=genanxiety;
proc gchart; vbar opioidabuse/discrete type=mean sumvar=S3CQ12A9;
proc gchart; vbar opioidabuse/discrete type=mean sumvar=workinterfere;
proc gplot; plot S3CD3Q13B*S4AQ7; 
proc gplot; plot S3CD3Q13B*S9Q7;

data new_all; set mydata.nesarc_pds;
label AGE = "Age"
      agegroup = "Age"
      S1Q9A="Business or Industry"
      S1Q9B="Occupation"
      S1Q20="Pain Interfered with normal work(last 4 weeks)"
      workinterfere =="Pain Interfered with normal work(last 4 weeks)"  
      S3CD3Q13A="Age At Onset of Opioid Abuse"
      opioidage = "Age At Onset of Opioid Abuse"  
      S3CD3Q13B="Number of episodes of opioid abuse"
      opioidabuse="At least 1 opioid abuse episode"
      opioidabusetop10="5 or more episodes of opioid abuse"
      S3CQ12A9="Arrested due to opioid use"
      S4AQ7="Number of episodes of major depression"
      majordepression="At least 1 major depression episode"
      S9Q7 ="Number of episodes of generalized anxiety disorder"
      genanxiety = "At least 1 generalized anxiety episode";

/*change unknown responses to missing value category or replace with mode*/
if S1Q20 = 9 then S1Q20 = .;
if S3CD3Q13B = 99 then S3CD3Q13B = 1;/*replacing unknown value with the mode*/
if S3CQ12A9 = 9 then S3CQ12A9 =.;
if S4AQ7 = 99 then S4AQ7 =1;/*replacing unknown value with the mode*/
if S9Q7 = 99 then S9Q7 =1;/*replacing unknown value with the mode*/

/*change missing category to did not work for pay*/
if S1Q9a = . then S1Q9a = 15 ;
if S1Q9b = . then S1Q9b = 15 ;

/*Filter to only adults*/
if age ge 18;

/*frequency tables*/
proc freq; tables S3CD3Q13A S1Q9A S1Q9B; 
run;

/*univariate charts*/
proc gchart;vbar S1Q9A/discrete type=pct raxis=axis1 maxis=axis2;
axis1 label=(angle=90 '% of respondents');
axis2 value=(angle=45 "Agriculture" "Mining" "Construction" "Manufacturing" "Transportation/Comm/Util" "Wholsale Trade" "Retail Trade" "Finance/Ins/RealEstate" "Business/Repair Svc" "PersonalSvc" "Entertain/Rec" "Professional/Related" "Public Admin" "ArmedSvc" "NoPaidWork/FamBus");
proc gchart;vbar S1Q9B/discrete type=pct raxis=axis1 maxis=axis2;
axis1 label=(angle=90 '% of respondents');
axis2 value=(angle=45 "Exec/Admin/Mgr" "Professional Specialty" "Technical/RelatedSupport" "Sales" "AdminSupport/Clerical" "Private Household" "ProtectiveSvc" "OtherSvc" "Farming/Forestry/Fishing" "Precision/Production/Craft/Repair" "Operators/Fabricators/Laborers" "Transportation/MaterialMoving" "Handlers/EquipCleaner/Laborer" "Military" "NoPaidWork/FamBus");
run;
