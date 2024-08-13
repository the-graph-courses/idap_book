# Copy global and template folders ----
## GRAPH Courses team
## Initiated 2021-05-25

#' Copy global and template folders from the IDAR course repos to all others. 
#' Target repos must be located in the same parent directory as the intro-to-data-analysis-with-r-staging repo, from which this script is run

#### load packages ----
if (!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, here, fs)

#### identify repos ----
from <- here()
to <- paste(dirname(from),
            c("data_untangled_staging",
              "data_on_display_staging",
              "intro-to-epigraphhub-staging"), sep = "/")

#### copy folders ----
folders_to_copy <- dir_ls(from, regexp = ".ch99|.global") %>% basename()

for (i in folders_to_copy) {
  dir_source <- paste(from, i, sep = "/")
  dir_target <- paste(to, i, sep = "/")
  
  dir_copy(path = rep(dir_source, 3),
           new_path = dir_target,
           overwrite = T)
}
