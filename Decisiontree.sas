LIBNAME mydata "/courses/d1406ae5ba27fe300 " access=readonly;

DATA new; set mydata.nesarc_pds;
label 
S3CD3Q13A = "age at onset of opioid abuse";

/*create opioid abuse variable*/
if S3CD3Q13A GT 0 then opioidabuse = 1; else opioidabuse = 2;

/*create explanatory variables*/
if S3CD1Q13A GT 0 then sedabuse =1; else sedabuse = 2;
if S3CD2Q13A GT 0 then tranqabuse =1; else tranqabuse = 2;
if S3CD4Q13A GT 0 then amphetabuse =1; else amphetabuse = 2;
if S3CD5Q13A GT 0 then cannabisabuse =1; else cannabisabuse = 2;
if S3CD6Q13A GT 0 then cocaineabuse =1; else cocaineabuse = 2;
if S3CD7Q13A GT 0 then hallucabuse =1; else hallucabuse = 2;
if S3CD8Q13A GT 0 then inhalantabuse =1; else inhalantabuse = 2;
if S3CD9Q13A GT 0 then heroinabuse =1; else heroinabuse = 2;
if S2BQ3A >0 then alcoholabuse = 1;else alcoholabuse = 2;
if S3AQ10D >0 then nicdep = 1; else nicdep=2;
if S4AQ4A16 = 1 then suicideatt = 1; else suicideatt = 2;
if S4aq6a >0 then majordep = 1; else majordep = 2;
if ccs = 1 or ccs = 2 then msa = 1;else msa = 2;
if s1q234 = 1 then fired = 1; else fired = 2;
if s1q238 = 1 then divorced = 1; else divorced = 2;
if s1q2310 = 1 then financialiss = 1; else financialiss = 2;
if buildtyp = 99 then buildtype = .;
if S1Q9A = . then S1Q9a = 15;/*industry*/
if S1Q9b = . then S1Q9b = 15; /*occupation*/
if S1Q9c = . then S1Q9c = 15; /*type of employment*/
hispanic = S1Q1C;
americanindian = S1Q1D1;
asian = S1Q1D2;
black =  S1Q1D3;
hawaiian = S1Q1D4;
white = S1Q1D5;
highestgrade = s1Q6a;
privatehealth = s1q14c4;
householdincome = s1Q12a;
if S3CD5Q13B = 99 then S3CD5Q13B =1; /*number of episodes of cannabis abuse*/
if S3CD5Q13B = . then S3CD5Q13B = 0;
num_ep_cannabis = S3CD5Q13B;
if S3CD9Q13B = 99 then S3CD9Q13B =1; /*number of episodes of heroin abuse*/
if S3CD9Q13B = . then S3CD9Q13B = 0;
num_ep_heroin = S3CD9Q13B;
if S3CD1Q13B = 99 then S3CD1Q13B =1; /*number of episodes of sedative abuse*/
if S3CD1Q13B = . then S3CD1Q13B = 0;
num_ep_sed = S3CD1Q13B; 
if S3CD2Q13B = 99 then S3CD2Q13B =1; /*number of episodes of transquilizer abuse*/
if S3CD2Q13B = . then S3CD2Q13B = 0;
num_ep_tranq = S3CD2Q13B;
if S3CD4Q13B = 99 then S3CD4Q13B =1; /*number of episodes of amphetamine abuse*/
if S3CD4Q13B = . then S3CD4Q13B = 0;
num_ep_amphet = S3CD4Q13B;
if S3CD6Q13B = 99 then S3CD6Q13B =1; /*number of episodes of cocaine abuse*/
if S3CD6Q13B = . then S3CD6Q13B = 0;
num_ep_cocaine = S3CD6Q13B;
if S3CD7Q13B = 99 then S3CD7Q13B =1; /*number of episodes of hallucinogen abuse*/
if S3CD7Q13B = . then S3CD7Q13B = 0;
num_ep_halluc = S3CD7Q13B;
if S3CD8Q13B = 99 then S3CD8Q13B =1; /*number of episodes of inhalant abuse*/
if S3CD8Q13B = . then S3CD8Q13B = 0;
num_ep_inhalant = S3CD8Q13B;
run;

ods graphics on;
proc hpsplit seed=12345;
class opioidabuse sedabuse tranqabuse cannabisabuse cocaineabuse hallucabuse
inhalantabuse heroinabuse alcoholabuse nicdep suicideatt majordep fired divorced
financialiss sex msa cendiv buildtyp spouse s1q9a s1q9b s1q9c
hispanic americanindian asian black hawaiian white privatehealth;

model opioidabuse =sedabuse tranqabuse cannabisabuse cocaineabuse sex hallucabuse
inhalantabuse heroinabuse alcoholabuse nicdep suicideatt majordep fired divorced
financialiss sex msa CENDIV buildtyp spouse s1q9a s1q9b s1q9c
hispanic americanindian asian black hawaiian white privatehealth 
numpers CHLD0_17 nonrel householdincome num_ep_sed num_ep_tranq num_ep_cannabis 
num_ep_cocaine num_ep_halluc num_ep_heroin num_ep_inhalant num_ep_amphet;

grow entropy;
prune costcomplexity;
   
RUN;