

**************************************************************************************************************
DATA MANAGEMENT
**************************************************************************************************************;

data new;
set nesarc_pds;
householdincome = s1Q12a;
if S3CD5Q13B = 99 then S3CD5Q13B =1; 
if S3CD5Q13B = . then S3CD5Q13B = 0;
num_ep_cannabis = S3CD5Q13B;
if S3AQ10E  = 99 then S3AQ10E  =1; 
if S3AQ10E  = . then S3AQ10E  = 0;
num_ep_nicdep = S3AQ10E;
if S2BQ3B  = 99 then S2BQ3B =1;
if S2BQ3B = . then S2BQ3B  = 0;
num_ep_alcohol = S2BQ3B;
if S3CD9Q13B = 99 then S3CD9Q13B =1; 
if S3CD9Q13B = . then S3CD9Q13B = 0;
num_ep_heroin = S3CD9Q13B;
if S3CD1Q13B = 99 then S3CD1Q13B =1; 
if S3CD1Q13B = . then S3CD1Q13B = 0;
num_ep_sed = S3CD1Q13B; 
if S3CD2Q13B = 99 then S3CD2Q13B =1; 
if S3CD2Q13B = . then S3CD2Q13B = 0;
num_ep_tranq = S3CD2Q13B;
if S3CD4Q13B = 99 then S3CD4Q13B =1;
if S3CD4Q13B = . then S3CD4Q13B = 0;
num_ep_amphet = S3CD4Q13B;
if S3CD6Q13B = 99 then S3CD6Q13B =1; 
if S3CD6Q13B = . then S3CD6Q13B = 0;
num_ep_cocaine = S3CD6Q13B;
if S3CD7Q13B = 99 then S3CD7Q13B =1; 
if S3CD7Q13B = . then S3CD7Q13B = 0;
num_ep_halluc = S3CD7Q13B;
if S3CD8Q13B = 99 then S3CD8Q13B =1; 
if S3CD8Q13B = . then S3CD8Q13B = 0;
num_ep_inhalant = S3CD8Q13B;
if S3CD3Q13B = 99 then S3CD3Q13B =1; 
if S3CD3Q13B = . then S3CD3Q13B = 0;
num_ep_opioid = S3CD8Q13B;
if S1Q14B = . then S1Q14B = 0;
foodstampincome = S1Q14B;
if S1Q16 = 9 then S1Q16 = 0;
selfhealthrating = S1Q16;
if NBS3 = 99 then NBS3 = .;
painscale = NBS3;
if NBS4 = 99 then NBS4 = .;
genhealthscale = NBS4;
if NBS8 = 99 then NBS8 =.;
mentalhealthscale = NBS8 ;
if S4AQ7 = 99 then S4AQ7 =1; 
if S4AQ7 = . then S4AQ7 = 0;
num_ep_majordep = S4AQ7;
if S4CQ6A = 99 then S4CQ6A =1; 
if S4CQ6A = . then S4CQ6A = 0;
num_ep_dysthymia = S4CQ6A;
if S5Q9 = 99 then S5Q9 =1; 
if S5Q9 = . then S5Q9 = 0;
num_ep_mania = S5Q9;
if S6Q13 = 99 then S6Q13 =1; 
if S6Q13 = . then S6Q13 = 0;
num_ep_panic = S6Q13;
if S7Q17C = 99 then S7Q17C =1; 
if S7Q17C = . then S7Q17C = 0;
num_ep_socialphobia = S7Q17C;
if S8Q14C  = 99 then S8Q14C  =1; 
if S8Q14C  = . then S8Q14C  = 0;
num_ep_specificphobia = S8Q14C;
if S9Q7   = 99 then S9Q7   =1; 
if S9Q7   = . then S9Q7   = 0;
num_ep_genanxiety = S9Q7 ;
if  S12Q3E = 99 then S12Q3E =1; 
if  S12Q3E = . then  S12Q3E = 0;
num_ep_pathgamble =  S12Q3E;

idnum=_n_;

keep idnum mentalhealthscale num_ep_cannabis num_ep_heroin num_ep_sed num_ep_tranq num_ep_amphet
num_ep_cocaine num_ep_halluc num_ep_inhalant num_ep_opioid num_ep_alcohol num_ep_nicdep
num_ep_majordep num_ep_dysthymia num_ep_mania num_ep_panic num_ep_socialphobia num_ep_specificphobia num_ep_genanxiety num_ep_pathgamble;

run;

proc sql;
drop table clust1 ;
create table clust1 as
select * from new;
quit;

data clust;
set clust1;
if cmiss(of _all_) then delete;
run;

ods graphics on;


* Split data randomly into test and training data;
proc surveyselect data=clust out=traintest seed = 123
 samprate=0.7 method=srs outall;
run;   

data clus_train;
set traintest;
if selected=1;
run;

data clus_test;
set traintest;
if selected=0;
run;

* standardize the clustering variables to have a mean of 0 and standard deviation of 1;
proc standard data=clus_train out=clustvar mean=0 std=1; 
var num_ep_cannabis num_ep_heroin num_ep_sed num_ep_tranq num_ep_amphet
num_ep_cocaine num_ep_halluc num_ep_inhalant num_ep_opioid num_ep_alcohol num_ep_nicdep
num_ep_majordep num_ep_dysthymia num_ep_mania num_ep_panic num_ep_socialphobia num_ep_specificphobia num_ep_genanxiety num_ep_pathgamble;
run; 

%macro kmean(K);

proc fastclus data=clustvar out=outdata&K. outstat=cluststat&K. maxclusters= &K. maxiter=300;
var num_ep_cannabis num_ep_heroin num_ep_sed num_ep_tranq num_ep_amphet
num_ep_cocaine num_ep_halluc num_ep_inhalant num_ep_opioid num_ep_alcohol num_ep_nicdep
num_ep_majordep num_ep_dysthymia num_ep_mania num_ep_panic num_ep_socialphobia num_ep_specificphobia num_ep_genanxiety num_ep_pathgamble;
run;

%mend;

%kmean(1);
%kmean(2);
%kmean(3);
%kmean(4);
%kmean(5);
%kmean(6);
%kmean(7);
%kmean(8);
%kmean(9);

* extract r-square values from each cluster solution and then merge them to plot elbow curve;
data clus1;
set cluststat1;
nclust=1;

if _type_='RSQ';

keep nclust over_all;
run;

data clus2;
set cluststat2;
nclust=2;

if _type_='RSQ';

keep nclust over_all;
run;

data clus3;
set cluststat3;
nclust=3;

if _type_='RSQ';

keep nclust over_all;
run;

data clus4;
set cluststat4;
nclust=4;

if _type_='RSQ';

keep nclust over_all;
run;
data clus5;
set cluststat5;
nclust=5;

if _type_='RSQ';

keep nclust over_all;
run;
data clus6;
set cluststat6;
nclust=6;

if _type_='RSQ';

keep nclust over_all;
run;
data clus7;
set cluststat7;
nclust=7;

if _type_='RSQ';

keep nclust over_all;
run;
data clus8;
set cluststat8;
nclust=8;

if _type_='RSQ';

keep nclust over_all;
run;
data clus9;
set cluststat9;
nclust=9;

if _type_='RSQ';

keep nclust over_all;
run;

data clusrsquare;
set clus1 clus2 clus3 clus4 clus5 clus6 clus7 clus8 clus9;
run;

* plot elbow curve using r-square values;
symbol1 color=blue interpol=join;
proc gplot data=clusrsquare;
 plot over_all*nclust;
 run;

*****************************************************************************************
further examine cluster solution for the number of clusters suggested by the elbow curve
*****************************************************************************************

* plot clusters for 3 cluster solution;
proc candisc data=outdata3 out=clustcan;
class cluster;
var num_ep_cannabis num_ep_heroin num_ep_sed num_ep_tranq num_ep_amphet
num_ep_cocaine num_ep_halluc num_ep_inhalant num_ep_opioid num_ep_alcohol num_ep_nicdep
num_ep_majordep num_ep_dysthymia num_ep_mania num_ep_panic num_ep_socialphobia num_ep_specificphobia num_ep_genanxiety num_ep_pathgamble;
run;


proc sgplot data=clustcan;
scatter y=can2 x=can1 / group=cluster;
run;

* validate clusters on mentalhealthscale;

* first merge clustering variable and assignment data with mentalhealthscale data;
data mentalhealth_data;
set clus_train;
keep idnum mentalhealthscale;
run;

proc sort data=outdata3;
by idnum;
run;

proc sort data=mentalhealth_data;
by idnum;
run;

data merged;
merge outdata3 mentalhealth_data;
by idnum;
run;

proc sort data=merged;
by cluster;
run;

proc means data=merged;
var mentalhealthscale;
by cluster;
run;

proc anova data=merged;
class cluster;
model mentalhealthscale = cluster;
means cluster/tukey;
run;
 
