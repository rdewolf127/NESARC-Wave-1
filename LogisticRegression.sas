libname mydata "/courses/d1406ae5ba27fe300 " access=readonly;
data new; 
set mydata.nesarc_pds;
label 
S3CD3Q13A = "age at onset of opioid abuse"
S3CD5Q13B = "number of episodes of cannabis abuse"
S3CD9Q13B = "number of episodes of heroin abuse"
S3CD2Q13B = "number of episodes of transquilizer abuse"
S3CD4Q13B = "number of episodes of amphetamine abuse"
S3CD6Q13B = "number of episodes of cocaine abuse"
S3CD7Q13B = "number of episodes of hallucinogen abuse"
S3CD8Q13B = "number of episodes of inhalant abuse"
S3CD1Q13B = "number of episodes of sedative abuse";

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
if S1Q2311 = 9 then S1Q2311 = .; /*arrested in the last 12 months*/
if S1Q2311 = 2 then S1Q2311 = 0;
if sex = 2 then sex = 0;/*male or female*/
if ccs = 1 or ccs = 2 then msa = 1;else msa = 0;


/*create opioid abuse variable*/
if S3CD3Q13A GT 0 then opioidabuse = 1; else opioidabuse = 0;

/*create sedative abuse variable*/
if S3CD1Q13A GT 0 then sedabuse =1; else sedabuse = 0;
run;

proc means;
var S3CD3Q13A;
where S3CD3Q13A < 99; 
run;

data new2;
set new;
if S3CD3Q13A = 99 then S3CD3Q13A = 24; /*use the results from the proc means*/

proc means;
var S3CD5Q13B S3CD9Q13B S3CD1Q13B S3CD2Q13B S3CD4Q13B S3CD6Q13B S3CD7Q13B S3CD8Q13B;
run;

/*centering the quantitative explanatory variables - use the results from the proc means*/
data new3;
set new2;
num_ep_cannabis_c = S3CD5Q13B - .1625554;
num_ep_heroin_c = S3CD9Q13B - 0.0111155;
num_ep_sedatives_c = S3CD1Q13B - 0.0142018;
num_ep_tranq_c = S3CD2Q13B - 0.0146892;
num_ep_amphet_c = S3CD4Q13B - 0.0317685;
num_ep_cocaine_c = S3CD6Q13B - .0656487;
num_ep_halluc_c = S3CD7Q13B - 0.0266401;
num_ep_inhalant_c = S3CD8Q13B - 0.0044787;
run;

proc logistic descending data =new3; 
model S1Q2311 = opioidabuse sedabuse sex msa/
selection=stepwise ridging=none maxiter=500 slentry=.1 slstay=.15;
run;



