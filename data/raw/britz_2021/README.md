External Validation of a Mobile Clinical Decision Support System for Diarrhea Etiology Prediction
in Children: A Multicenter Study in Bangladesh and Mali

This prospective observational study aimed to develop and externally validate the accuracy of a mobile software application (“App”) for the prediction of viral-only etiology of acute diarrhea in children 0-59 months in Bangladesh and Mali using a previously derived and internally validated model from Brintz, Ben J., et al. "A modular approach to integrating multiple data sources into real-time clinical prediction for pediatric diarrhea." Elife 10 (2021): e63009.

Please contact Ben Brintz at ben.brintz@hsc.utah.edu for information regarding analyses. All analyses were conducted in R version 3.6.2. 

Annotated code (Phase_1_elife.R) and files necessary to complete the analysis are provided at https://github.com/LeungLab/DiaPR_Phase1. 

All human subjects are de-identified and use only a study id. 

Files/Variables of interest: 

DiaPRData2020.01.01.csv and base_smartphone.csv contain the CRF information from both Bangladesh and Mali. 
ID, Code_Patient: Study ID
AdmitDate,Date_Inclusion: Date of admission
AgeMonths,Age-mois: Age of patient
Form 2::MUAC1,FORM 3::MUAC2, MUAC1, MUAC2: MUAC cm
Form 2::bloodstoolreported1.1,Form 3::bloodstoolreported2.1,Sang-Selle1: bloody stool yes/no
Form 2::vomit1.1,Vomissement1: vomit yes/no 
Form 2::breastfeeding1.1,Allaitement1: breastfeeding none/partial/exclusive
Gender,Sexe: Male or Female 
DiarrheaDays,Jours_Diarrhee: Number of days with diarrhea
DiarrheaHours,Heure_Diarrhee: Number of hours with diarrhea
DiarrheaEpisodes,Nombre_Selle: Number of episdoes of diarrhea
Form 4::MotherEducation,Educ_Mere: Mother's education level
Form 4::FatherEducation,Educ_Pere: Father's education level 
Form 4::PeopleAtHome,Pers_menage: Number of people living at home

dlbg with AFEs.csv and Mali_Afe.csv contain the TAC data needed to define etiology
ID: Study ID
All variables that end with _afe: used to establish etiology


dhaka_weather.csv and Mali_weather.csv contain weather data needed for weather component of model 
temp: temperature(celsius)
rain: precipitation(inches) 
