# FOR THEORY QUIZZES: Use the code below. Function is stored on a github gist.

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Connect to GDrive ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pacman::p_load(googledrive)
# Setup for uploading images and datasets
if (!drive_has_token()) drive_auth(email = "trainingteam@thegraphnetwork.org")
options(gargle_oauth_email = "trainingteam@thegraphnetwork.org")

### Source gist ----
pacman::p_load(devtools)
devtools::source_gist("https://gist.github.com/kendavidn/05c7055e487ef22e5a336a4cb489a937")

# Pandoc
# Set the PATH environment variable for VSCode
Sys.setenv(
  PATH = paste(
    "/Users/kendavid/opt/anaconda3/bin",
    "/opt/homebrew/bin",
    Sys.getenv("PATH"),
    sep = ":"
  )
)


## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Enter quiz information ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Get all quiz files starting with p_mcq in the quizzes folder
quiz_files <- list.files(
  path = here::here("quizzes"),
  pattern = "^p_mcq.*\\.Rmd$",
  full.names = TRUE
)

# Process each quiz file
for (i in 1:length(quiz_files)) {
  i = 15
  print(paste("Processing quiz", i, "of", length(quiz_files), "which is", quiz_files[i]))
  process_theory_quiz(quiz_files[i])
}
