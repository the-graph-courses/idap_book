# Author Hawa
## Workshop exercise 1: Catching errors

# For each question, there is some code with an error
# Either the code doesn't run, or it does something incorrectly
# Your task is to find and fix the error
# The 1st person in the pair should screenshare and answer questions 1 & 2
# Then the 2nd person in the pair should screenshare and answer 3 & 4
# (If there are three people, you can do 2-1-1 or similar)
# When a person is screensharing, they are the "scribe"
# The person watching the scribe is the "reviewer". 
# Reviewer(s) should offer comments/help if/when the scribe is stuck or writes problematic code.


# GOOD LUCK!


#  Question 1 ----
# This code tries to calculate a person's BMI, but does so incorrectly. 
# Try to correct it.

jenny_height_cm <- 150/100
jenny_weight_kg <- 60
jenny_bmi <- jenny_weight_kg/jenny_height_cm^2
jenny_bmi


#  Question 2 ----
# This code is supposed to create some variable tabulations with the `table()` function
# The dataset is a measles patient linelist from the {outbreaks} package 
# Counts are by gender, complications and class
if(!require(pacman)) install.packages("pacman")
pacman::p_load(outbreaks)

table(measles_hagelloch_1861$gender)
table(measles_hagelloch_1861$complications)
table(measles_hagelloch_1861$class)


#  Question 3 ----
# This code is supposed to read in a dataset from the web
# It uses the `read_csv()` function from the {readr} package 
# The file is at https://tinyurl.com/diabetes-china
# The code then tries to view the first 5 rows from the dataset
# It has errors that mean it does not run. 

pacman::p_load(readr)
read_csv<-("https://tinyurl.com/diabetes-china")
diabetes_china <- read.csv("https://tinyurl.com/diabetes-china")
head( n= 5, x = diabetes_china)


#  Question 4 ----
# The commands below paste dataset columns together to make sentences like
# "on ____-__-__, xxx cases were reported"
# The first command works but the second command has issues. Try to remedy these.

paste("On",
      zika_yap_2007$onset_date,
      zika_yap_2007$value,
      "case(s) were reported in Yap")
paste("On",
      zika_sanandres_2015$cases,
      zika_sanandres_2015$date,
      "case(s) were reported in San Andres")

