# FOR THEORY QUIZZES: Use the code below. Function is stored on a github gist. 

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Connect to GDrive ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pacman::p_load(googledrive)
# Setup for uploading images and datasets
if (!drive_has_token()) drive_auth(email = "trainingteam@thegraphnetwork.org")
options(gargle_oauth_email = "trainingteam@thegraphnetwork.org")

### Source gist ----
pacman::p_load(devtools)
devtools::source_gist("https://gist.github.com/kendavidn/05c7055e487ef22e5a336a4cb489a937")


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Enter quiz information ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

quiz_path <- here::here("quizzes/module_c2_mcq.Rmd")

process_theory_quiz(quiz_path)


