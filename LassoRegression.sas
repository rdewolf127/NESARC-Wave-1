LIBNAME mydata "/courses/d1406ae5ba27fe300 " access=readonly;

DATA new; set mydata.nesarc_pds;
label 
S3CD3Q13A = "age at onset of opioid abuse";

/*create num_ep_opioidabuse variable*/
if S3CD3Q13B <99 then num_ep_opioidabuse = S3CD3Q13B;
if S3CD3Q13B = 99 then num_ep_opioidabuse = .;
if num_ep_opioidabuse = . then num_ep_opioidabuse = 0;

/*manage explanatory variables*/
if S3CD1Q13A GT 0 then sedabuse =1; else sedabuse = 0;
if S3CD2Q13A GT 0 then tranqabuse =1; else tranqabuse = 0;
if S3CD4Q13A GT 0 then amphetabuse =1; else amphetabuse = 0;
if S3CD5Q13A GT 0 then cannabisabuse =1; else cannabisabuse = 0;
if S3CD6Q13A GT 0 then cocaineabuse =1; else cocaineabuse = 0;
if S3CD7Q13A GT 0 then hallucabuse =1; else hallucabuse = 0;
if S3CD8Q13A GT 0 then inhalantabuse =1; else inhalantabuse = 0;
if S3CD9Q13A GT 0 then heroinabuse =1; else heroinabuse = 0;
if S2BQ3A >0 then alcoholabuse = 1;else alcoholabuse = 0;
if S3AQ10D >0 then nicdep = 1; else nicdep=0;
if S4AQ4A16 = 1 then suicideatt = 1; else suicideatt = 0;
if S4aq6a >0 then majordep = 1; else majordep = 0;
if ccs = 1 or ccs = 2 then msa = 1;else msa = 0;
if sex = 2 then sex =0; 
if spouse = 2 then spouse =0;
if s1q234 = 1 then fired = 1; else fired = 0;
if s1q238 = 1 then divorced = 1; else divorced = 0;
if s1q2310 = 1 then financialiss = 1; else financialiss = 0;
if S1Q1C = 1 then hispanic = 1; else hispanic =0;
if S1Q1D1 = 1 then americanindian = 1; else americanindian = 0; 
if S1Q1D2 = 1 then asian = 1; else asian =0;
if S1Q1D3 = 1 then black = 1; else black =0;
if S1Q1D4 = 1 then hawaiian = 1;else hawaiian =0;
if S1Q1D5 = 1 then white = 1; else white =0;
householdincome = s1Q12a;
if S3CD5Q13B = 99 then S3CD5Q13B =1; 
if S3CD5Q13B = . then S3CD5Q13B = 0;
num_ep_cannabis = S3CD5Q13B;
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

/*subset to only respondents with history of opioid abuse*/
if num_ep_opioidabuse >0;
run;

proc standard data = new out =new2 mean=0 std=1;
var numpers CHLD0_17 nonrel householdincome num_ep_tranq num_ep_cannabis
num_ep_cocaine num_ep_halluc num_ep_heroin num_ep_inhalant num_ep_amphet
num_ep_sed;
run;

ods graphics on;

* Split data randomly into test and training data;
proc surveyselect data=new2 out=traintest seed = 123
 samprate=0.7 method=srs outall;
run;   

* lasso multiple regression with lars algorithm k=10 fold validation;
proc glmselect data=traintest plots=all seed=23;
     partition ROLE=selected(train='1' test='0');
     model num_ep_opioidabuse = sedabuse tranqabuse cannabisabuse cocaineabuse hallucabuse
inhalantabuse heroinabuse alcoholabuse nicdep suicideatt majordep fired divorced
financialiss sex msa spouse 
hispanic americanindian asian black hawaiian white 
numpers CHLD0_17 nonrel householdincome num_ep_tranq num_ep_cannabis
num_ep_cocaine num_ep_halluc num_ep_heroin num_ep_inhalant num_ep_amphet
num_ep_sed
/selection=lar(choose=cv stop=none) cvmethod=random(10);
run;



