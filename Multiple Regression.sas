
libname mydata "/courses/d1406ae5ba27fe300 " access=readonly;
data new;
set mydata.nesarc_pds;
label S3CD3Q13B = "Number of Opioid Abuse Episodes"
S3CD3Q13A = "age at onset of opioid abuse"
S3CD3Q15G = "age at full opioid remission"
S3CD5Q13B = "number of episodes of cannabis abuse"
S3CD9Q13B = "number of episodes of heroin abuse"
S3CD2Q13B = "number of episodes of transquilizer abuse"
S3CD4Q13B = "number of episodes of amphetamine abuse"
S3CD6Q13B = "number of episodes of cocaine abuse"
S3CD7Q13B = "number of episodes of hallucinogen abuse"
S3CD8Q13B = "number of episodes of inhalant abuse"
S3CD1Q13B = "number of episodes of sedative abuse";

if S3cd3Q13B = 99 then S3cd3Q13B =.;
if S3CD3Q13A = 99 then S3CD3Q13A =24; /*age at onset of opioid abuse*/
if S3CD3Q15G = 99 then S3CD3Q15G =.; /*age at full opioid remission*/
if S3CD3Q15G = . then S3CD3Q15G = AGE;
if S3CD5Q13B = 99 then S3CD5Q13B =1; /*number of episodes of cannabis abuse*/
if S3CD5Q13B = . then S3CD5Q13B = 0;
if S3CD9Q13B = 99 then S3CD9Q13B =1; /*number of episodes of heroin abuse*/
if S3CD9Q13B = . then S3CD9Q13B = 0;
if S3CD1Q13B = 99 then S3CD1Q13B =1; /*number of episodes of sedative abuse*/
if S3CD1Q13B = . then S3CD1Q13B = 0;
if S3CD2Q13B = 99 then S3CD2Q13B =1; /*number of episodes of transquilizer abuse*/
if S3CD2Q13B = . then S3CD2Q13B = 0;
if S3CD4Q13B = 99 then S3CD4Q13B =1; /*number of episodes of amphetamine abuse*/
if S3CD4Q13B = . then S3CD4Q13B = 0;
if S3CD6Q13B = 99 then S3CD6Q13B =1; /*number of episodes of cocaine abuse*/
if S3CD6Q13B = . then S3CD6Q13B = 0;
if S3CD7Q13B = 99 then S3CD7Q13B =1; /*number of episodes of hallucinogen abuse*/
if S3CD7Q13B = . then S3CD7Q13B = 0;
if S3CD8Q13B = 99 then S3CD8Q13B =1; /*number of episodes of inhalant abuse*/
if S3CD8Q13B = . then S3CD8Q13B = 0;
if S3CQ12A9 = 9 then S3CQ12A9 = .;
if S2BQ1A27 = 9 then S2BQ1A27 = .;
if S3DQ1 = 9 then S3DQ1 = .;
if S3CQ12A9 = 1 or S2BQ1A27 = 1 or S3DQ1 = 1 then ouiarrest_treat = 1;
if S3CQ12A9 = 2 and S2BQ1A27 = 2 and S3DQ1 = 2 then ouiarrest_treat = 0;
if S3CQ12A9 = 1 or S2BQ1A27 = 1 then ouiarrest = 1;
if S3CQ12A9 = 2 and S2BQ1A27 = 2 then ouiarrest= 0;
if S3DQ1 = 2 then treat = 0;
if S3DQ1 = 1 then treat = 1;
if S3BQ1A9A = 1 then heroinlife = 1;
if S3BQ1A9A = 2 then heroinlife = 0;
if S3BQ1A5 = 1 then cannabislife = 1;
if S3BQ1A5 = 2 then cannabislife = 0;
if S3BQ1A6 = 1 then crackcokelife = 1;
if S3BQ1A6 = 2 then crackcokelife = 0;

/*only individuals with at least one opioid abuse episode*/
if S3CD3Q13A GT 0;
run;

proc freq;
tables S3cd3Q13B S3CD3Q13A S3CD5Q13B S3CD9Q13B S3CD1Q13B S3CD2Q13B S3CD4Q13B S3CD6Q13B S3CD7Q13B S3CD8Q13B;
run;

proc means;
var S3CD3Q13A S3CD5Q13B S3CD9Q13B S3CD1Q13B S3CD2Q13B S3CD4Q13B S3CD6Q13B S3CD7Q13B S3CD8Q13B;
run;

/*centering the quantitative explanatory variables*/
data new2;
set new;
age_onset_c = S3CD3Q13A - 23.9536424;
num_ep_cannabis_c = S3CD5Q13B - 2.1810155;
num_ep_heroin_c = S3CD9Q13B - 0.3774834;
num_ep_sedatives_c = S3CD1Q13B - 0.8410596;
num_ep_tranq_c = S3CD2Q13B - 0.6799117;
num_ep_amphet_c = S3CD4Q13B - 0.8145695;
num_ep_cocaine_c = S3CD6Q13B - 1.1545254;
num_ep_halluc_c = S3CD7Q13B - 0.9448124;
num_ep_inhalant_c = S3CD8Q13B - 0.2075055;
duration = S3CD3Q15G - S3CD3Q13A;
run;

proc freq;
tables duration;
run;

proc means;
var duration;
run;

/*centering duration*/
data new3;
set new2;
duration_c = duration -12.9655870;
run;

proc glm data =new3; model S3CD3Q13B =ouiarrest_treat duration_c num_ep_heroin_c num_ep_sedatives_c/solution clparm;
run;

proc glm PLOTS (unpack)=all;
model S3CD3Q13B =ouiarrest_treat duration_c num_ep_heroin_c num_ep_sedatives_c/solution clparm;
output residual=res student=stdres out=results;
run;

proc gplot;
label stdres = "Standardized Residual" IDNUM="IDNUM";
plot stdres*IDNUM/vref=0;
run;

proc reg plots=partial;
model S3CD3Q13B =ouiarrest_treat duration_c num_ep_heroin_c num_ep_sedatives_c/partial;
run;