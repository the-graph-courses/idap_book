# Create bookdown repo ----
## GRAPH Courses team
## 2022-06-19

#' 
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, 
               here, 
               fs)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Copy custom css into repo  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# DO NOT RERUN. Will overwrite edited CSS
# files <- c("default-fonts", "default-page", "default")
# from <- pagedown:::pkg_resource(paste0("css/", files, ".css"))
# 
# target_folders <- here("bookdown/lessons/css")
# to <- paste(target_folders, c("custom-fonts.css", "custom-page.css", "custom.css"), sep = "/")
# file.copy(from = from, to = to)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##    ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# list files to be copied
all_files <- list.files(from, full.names = TRUE)

# files to copy
files_to_copy_search_string <- paste(c("ch0",
                                       "global"),
                                     collapse = "|")

# note that this list contains only top level files
files_to_copy <- all_files[str_detect(all_files, files_to_copy_search_string)]


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Copy, then delete extraneous things  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

file.copy(from = files_to_copy, 
          to = to, 
          recursive = TRUE) # `recursive = TRUE` makes sure you catch nested files

# there are a bunch files in the copied folders that we do not want students to have, delete these
all_copied_dirs <- fs::dir_ls(to, type = "directory", recurse = T)
dirs_to_delete <- all_copied_dirs[str_ends(all_copied_dirs, "/quizzes|/recordings|/global/engineering|global/trash")]


all_copied_files <- fs::dir_ls(to, type = "file", recurse = T)
files_to_delete <- all_copied_files[str_ends(all_copied_files, ".docx")]

fs::file_delete(files_to_delete)

# finally delete empty folders with terminal command (as at 2022-03-17, this doesn't work perfectly)
system2(command = "find",
        args    = c(to, "-empty", "-type d", "-delete"))




