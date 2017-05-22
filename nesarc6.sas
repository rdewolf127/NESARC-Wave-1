libname mydata "/courses/d1406ae5ba27fe300 " access=readonly;
data new; set mydata.nesarc_pds;
keep IDNUM S3CD3Q13B S3CD3Q13A S4AQ7 majordepression opioidabuse agegroup;
label	IDNUM = "ID Number"
		S3CD3Q13B = "Number of Opioid Abuse Episodes"
		S3CD3Q13A = "Age at Onset of Opioid Abuse"
		S4AQ7 = "Number of Episodes of Major Depression"
		majordepression = "Presence of Major Depression"
		agegroup = "Age Group"
		opioidabuse = "Presence of Opioid Abuse";

	
/*proc univariate data=new;
var S3CD3Q13B S4AQ7;
run;*/
	
/*change unknown responses to mode (based on results from proc univariate*/
array mode (2) S3CD3Q13B S4AQ7;
do i = 1 to 2;
	if mode(i) = 99 then mode(i) = 1;
end;

/*proc means; data=new mean;
var S3CD3Q13A;
run;*/

/*change unknown responses to mean (based on results from proc means*/
if S3CD3Q13A = 99 then S3CD3Q13A = 24;

if S3CD3Q13A <= 18 then agegroup = 0;
if S3CD3Q13A >= 19 then agegroup = 1;

/*collapse number major depression episodes into T or F*/
if S4AQ7 ge 1 and S4AQ7 le 99 then majordepression = 1;
if S4AQ7 = . then majordepression = 0;

/*set missing major depression episode values to 0*/
if S4AQ7 = . then S4AQ7 = 0;

/*collapse number opioid abuse episodes into T or F*/
if S3CD3Q13B ge 1 and S3CD3Q13B le 99 then opioidabuse = 1;
if S3CD3Q13B = . then opioidabuse = 0;

/*Subset to only adults who began abusing opioids as adults*/
if S3CD3Q13A GT 0;
if AGE GE 18;
run;

/*run frequency tables for all variables*/
proc freq; tables S3CD3Q13B S3CD3Q13A S4AQ7 majordepression opioidabuse agegroup;
run;

/*get the mean of number of major depression episodes (quantitative explanatory variable) for centering*/
proc means data=new mean;
var S4AQ7;
run;

/*center number of major depression episodes around the mean*/
data new2;
set new;
mS4AQ7 = S4AQ7 - 4.2145749;
mS3CD3Q13A = S3CD3Q13A -24;
run;

/*validate the mean centering*/
proc means data=new2 mean;
var mS4AQ7;
run;

/*run the linear regression*/
proc glm data =new2; model S3CD3Q13B =agegroup/solution;
run;

