# Document functions from our R script
## GRAPH Courses team
## 2021-04-10

#' Create HTML help files with ROxygen for R functions in provided path.
#' Run this whenever you add a new functions to our functions scripts.
#' There may not be much added benefit over just reading the raw roxygen tags in the R script though.

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(here, remotes)
if (! require("document")) remotes::install_gitlab("fvafrCU/document")

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Main ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

document::document(here::here("global/functions/misc_functions.R"), 
                   check_package = F, 
                   output_directory = here::here("global/functions"))

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Addendum ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## You may need to run the below to install tinytex

# if (file.access("/usr/local/bin", mode = 2) == -1) {
#   tf <- tempfile()
#   cat("#!/bin/bash\nsudo chown -R `whoami`:admin /usr/local/bin\nRscript -e 'tinytex::install_tinytex()'\n", file = tf)
#   Sys.chmod(tf, mode = "0755")
#   system(paste0('osascript -e \'tell application "Terminal" to activate\' -e \'tell application "Terminal" to do script "', tf, '"\''))
# } else {
#   tinytex::install_tinytex()
# }

# See: https://github.com/yihui/tinytex/issues/24

