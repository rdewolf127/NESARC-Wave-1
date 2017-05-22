libname mydata "/courses/d1406ae5ba27fe300 " access=readonly;

data new; set mydata.nesarc_pds;
/*keep IDNUM S1Q10A S3CD3Q13B S3CD3Q13CR AGE opioidabuselife;*/
label S3CD3Q13B = "Number of opioid abuse episodes"
	  S1Q10A = "Income";

/*create did not work for pay industry category*/
if S1Q9A = . then S1Q9A = 15;

/*define opioid abusers based on those with at least 1 opioid abuse event*/
if S3CD3Q13B NE . then opioidabuselife = 1;
if S3CD3Q13B = . then opioidabuselife = 0;

/*change industry numbers to characters*/
S1Q9A = STRIP(PUT(S1Q9A, 8.));

/*subset the data to only adults*/
if AGE GE 18;
if opioidabuselife = 1;
if S3CD3Q13B LE 50;
run;

proc sort; by IDNUM;

/*run frequency tables on opioid episodes and industry*/
proc freq; tables S3CD3Q13B S1Q10A;
run;

/*run pearson correlation*/
PROC corr; VAR S3CD3Q13B S1Q10A;
RUN;

proc gplot; plot S3CD3Q13B*S1Q10A; 

