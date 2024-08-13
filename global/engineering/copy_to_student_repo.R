# Copy staging repo to student repo ----
## Kene David Nwosu
## 2021-03-27

#' Copies internal staging repo to the outward-facing student repo. 
#' The outward-facing repo will be made available to students for download.
#' The copy procedure below is aimed at only copying over the files that the students actually need.
#' If you have ideas for simplifying the script, please suggest them! Start a merge request.

# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  Load packages ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# if(!require(pacman)) install.packages("pacman")
# pacman::p_load(tidyverse, 
#                here, 
#                fs)
# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  Establish paths  ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# from <- here()
# 
# to   <- gsub("_staging", "", here()) # the repo you are copying to, "intro-to-data-analysis-with-r" 
# 
# # should be located in the same parent directory as the staging repo, from which this script is run
# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  Remove all folders in target repo ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# fs::dir_ls(path = to, type = "directory") %>% 
#   fs::dir_delete()
# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  List top level files and directories  ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# # list files to be copied
# all_files <- list.files(from, full.names = TRUE)
# 
# # files to copy
# files_to_copy_search_string <- paste(c("global", "lessons", "data", "data_prep", "slides"),
#                                      collapse = "|")
# 
# # note that this list contains only top level files
# files_to_copy <- all_files[str_detect(all_files, files_to_copy_search_string)]
# 
# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  Copy, then delete extraneous things  ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# file.copy(from = files_to_copy, 
#           to = to, 
#           recursive = TRUE) # `recursive = TRUE` makes sure you catch nested files
# 
# # there are a bunch files in the copied folders that we do not want students to have, delete these
# 
# 
# # dirs to delete
# all_copied_dirs <- fs::dir_ls(to, type = "directory", recurse = T)
# dirs_to_delete_search_string <- paste(c("data_prep", "/quizzes", "/recordings", 
#                                         "/global/engineering", "global/trash", 
#                                         "global/templates", "/old"),
#                                      collapse = "|")
# dirs_to_delete <- all_copied_dirs[str_ends(all_copied_dirs, dirs_to_delete_search_string)]
# unlink(dirs_to_delete, recursive = T)
# 
# 
# # files to delete
# all_copied_files <- fs::dir_ls(to, type = "file", recurse = T)
# files_to_delete_search_string <- paste(c(".docx", "-TEACHER", 
#                                          "_TEACHER",
#                                          "-GITIGNORE", 
#                                         ".html", 
#                                         "chXX",
#                                         "r_foundations_staging.Rproj",
#                                         ".pptx"
#                                         ),
#                                       collapse = "|")
# files_to_delete <- all_copied_files[str_ends(all_copied_files, files_to_delete_search_string)]
# unlink(files_to_delete, recursive = T)
# 
# 
# # finally delete empty folders with terminal command (as at 2022-03-17, this doesn't work perfectly)
# system2(command = "find",
#         args    = c(to, "-empty", "-type d", "-delete"))
# 
# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  Rearrange and sanitize student repo  ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# 
# rmds_to_sanitize <- fs::dir_ls(to, 
#              regexp = "*.Rmd$",
#              recurse = T) %>%
#   as_tibble() %>% 
#   filter(!str_detect(value, "/snippets")) %>% 
#   pull(1)
# 
# 
# name <- basename(rmds_to_sanitize) %>% tools::file_path_sans_ext()
# 
# # create a folder in the target for each repo
# fs::dir_create(path = paste0(to, "/", "foundations_", name))
# 
# # create a Rproj file in each for each repo
# fs::file_copy(path = rep(paste0(from, "/r_foundations_staging.Rproj"), length(name)) , 
#               new_path = paste0(to, "/foundations_", name, "/foundations_",   name, ".Rproj"), overwrite = T)
# 
# # create a folder for images, functions and data in each target repo
# fs::dir_create(path = paste0(to, "/", "foundations_", name, "/data"))
# fs::dir_create(path = paste0(to, "/", "foundations_", name, "/autograder"))
# fs::dir_create(path = paste0(to, "/", "foundations_", name, "/images"))
# # copy global folder into each repo 
# fs::dir_copy(rep(paste0(to, "/global"), length(name)) , 
#              paste0(to, "/", "foundations_", name, "/global"), overwrite = T)
# 
# 
# # rename paths as needed in rmds
# for (rmd in rmds_to_sanitize){
# 
#   ith_rmd_name <- basename(rmd) %>% tools::file_path_sans_ext()
#   
#   xfun::gsub_dir(dir = to, 
#                pattern = paste0("lessons/", ith_rmd_name, "_autograder.R"), 
#                replacement = paste0("autograder/", ith_rmd_name, "_autograder.R"), 
#                ext = c("Rmd", "R"))
# 
# }
# 
# 
# # copy autograders into target folders
# file.copy(from = paste0(to, "/lessons/", name, "_autograder.R"),
#           to = paste0(to,  "/foundations_", name, "/autograder/", name, "_autograder.R"), 
#           overwrite = T)
# 
# # copy Rmds into target folders
# file.copy(from = paste0(to, "/lessons/", name, ".Rmd"),
#           to = paste0(to,  "/foundations_", name, "/", name, ".Rmd"), 
#           overwrite = T)
# 
# # copy images used in each Rmd into target folders
# for (rmd in rmds_to_sanitize) {
#   
#   rmd_base_name <- basename(rmd) %>% tools::file_path_sans_ext()
#   
#   all_lines <- read_lines(rmd)
#   
#   images_used <-
#     str_extract(all_lines, "(images/[^)]+)") %>%
#     tibble() %>%
#     drop_na()
#   
#   source <- paste0(to, "/lessons/", images_used$.)
#   
#   target <- paste0(to, "/foundations_", rmd_base_name, "/", images_used$.)
#   
#   file.copy(source, target, overwrite = T)
#   
# }
# 
# # copy datasets used in each Rmd into target folders
# for (rmd in rmds_to_sanitize) {
#   
#   rmd_base_name <- basename(rmd) %>% tools::file_path_sans_ext()
#   
#   all_lines <- read_lines(rmd)
#   
#   datasets_used <-
#     str_extract(all_lines, "(data/[^)]+)") %>%
#     str_remove_all("'") %>% 
#     str_remove_all('"') %>% 
#     tibble(value = .) %>%
#     drop_na()
# 
#   source <- paste0(to, "/", datasets_used$value)
#   
#   target <- paste0(to, "/foundations_", rmd_base_name, "/", datasets_used$value)
#   
#   file.copy(source, target, overwrite = T)
#   
# }
# 
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##  Delete global, data, lessons original files  ----
# ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# fs::dir_delete(paste0(to, "/", c("global", "lessons", "data")))


# Copy staging repo to student repo ----
## Kene David Nwosu
## 2021-03-27

#' Copies internal staging repo to the outward-facing student repo. 
#' The outward-facing repo will be made available to students for download.
#' The copy procedure below is aimed at only copying over the files that the students actually need.
#' If you have ideas for simplifying the script, please suggest them! Start a merge request.


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, 
               here, 
               fs)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Establish paths  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

from <- here()

to   <- gsub("_staging", "", here()) # the repo you are copying to, "intro-to-data-analysis-with-r" 

# should be located in the same parent directory as the staging repo, from which this script is run

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Remove all folders in target repo ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fs::dir_ls(path = to, type = "directory") %>% 
  fs::dir_delete()

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  List top level files and directories  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# list files to be copied
all_files <- list.files(from, full.names = TRUE)

# files to copy
files_to_copy_search_string <- paste(c("global", "lessons", "data", "data_prep", "slides"),
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


# dirs to delete
all_copied_dirs <- fs::dir_ls(to, type = "directory", recurse = T)
dirs_to_delete_search_string <- paste(c("data_prep", "/quizzes", "/recordings", 
                                        "/global/engineering", "global/trash", 
                                        "global/templates", "/old"),
                                      collapse = "|")
dirs_to_delete <- all_copied_dirs[str_ends(all_copied_dirs, dirs_to_delete_search_string)]
unlink(dirs_to_delete, recursive = T)


# files to delete
all_copied_files <- fs::dir_ls(to, type = "file", recurse = T)
files_to_delete_search_string <- paste(c(".docx", "-TEACHER", 
                                         "_TEACHER",
                                         "-GITIGNORE", 
                                         "-STAGING", 
                                         "french", 
                                         "duplicate-for-pagedown", 
                                         "duplicate-for-pagedown", 
                                         ".html", 
                                         "chXX",
                                         "r_foundations_staging.Rproj",
                                         ".pptx"
),
collapse = "|")
files_to_delete <- all_copied_files[str_detect(all_copied_files, files_to_delete_search_string)]
unlink(files_to_delete, recursive = T)


# finally delete empty folders with terminal command (as at 2022-03-17, this doesn't work perfectly)
system2(command = "find",
        args    = c(to, "-empty", "-type d", "-delete"))


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Rearrange and sanitize student repo  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


rmds_to_sanitize <- fs::dir_ls(to, 
                               regexp = "*.Rmd$",
                               recurse = T) %>%
  as_tibble() %>% 
  filter(!str_detect(value, "/snippets")) %>%
  filter(!str_detect(value, "/docs")) %>% 
  pull(1)


name <- basename(rmds_to_sanitize) %>% tools::file_path_sans_ext()

# create a folder in the target for each repo
fs::dir_create(path = paste0(to, "/", "foundations_", name))

# create a Rproj file in each for each repo
fs::file_copy(path = rep(paste0(from, "/r_foundations_staging.Rproj"), length(name)) , 
              new_path = paste0(to, "/foundations_", name, "/foundations_",   name, ".Rproj"), overwrite = T)

# create a folder for images, functions and data in each target repo
fs::dir_create(path = paste0(to, "/", "foundations_", name, "/data"))
fs::dir_create(path = paste0(to, "/", "foundations_", name, "/autograder"))
fs::dir_create(path = paste0(to, "/", "foundations_", name, "/images"))
# copy global folder into each repo 
fs::dir_copy(rep(paste0(to, "/global"), length(name)) , 
             paste0(to, "/", "foundations_", name, "/global"), overwrite = T)


# rename paths as needed in rmds
for (rmd in rmds_to_sanitize){
  
  ith_rmd_name <- basename(rmd) %>% tools::file_path_sans_ext()
  
  xfun::gsub_dir(dir = to, 
                 pattern = paste0("lessons/", ith_rmd_name, "_autograder.R"), 
                 replacement = paste0("autograder/", ith_rmd_name, "_autograder.R"), 
                 ext = c("Rmd", "R"))
  
}


# copy autograders into target folders
file.copy(from = paste0(to, "/lessons/", name, "_autograder.R"),
          to = paste0(to,  "/foundations_", name, "/autograder/", name, "_autograder.R"), 
          overwrite = T)

# copy Rmds into target folders
file.copy(from = paste0(to, "/lessons/", name, ".Rmd"),
          to = paste0(to,  "/foundations_", name, "/", name, ".Rmd"), 
          overwrite = T)

# copy images used in each Rmd into target folders
for (rmd in rmds_to_sanitize) {
  
  rmd_base_name <- basename(rmd) %>% tools::file_path_sans_ext()
  
  all_lines <- read_lines(rmd)
  
  images_used <-
    str_extract(all_lines, "(images/[^)]+)") %>%
    tibble() %>%
    drop_na()
  
  source <- paste0(to, "/lessons/", images_used$.)
  
  target <- paste0(to, "/foundations_", rmd_base_name, "/", images_used$.)
  
  file.copy(source, target, overwrite = T)
  
}

# copy datasets used in each Rmd into target folders
for (rmd in rmds_to_sanitize) {
  
  rmd_base_name <- basename(rmd) %>% tools::file_path_sans_ext()
  
  all_lines <- read_lines(rmd)
  
  datasets_used <-
    str_extract(all_lines, "(data/[^)]+)") %>%
    str_remove_all("'") %>% 
    str_remove_all('"') %>% 
    tibble(value = .) %>%
    drop_na()
  
  source <- paste0(to, "/", datasets_used$value)
  
  target <- paste0(to, "/foundations_", rmd_base_name, "/", datasets_used$value)
  
  file.copy(source, target, overwrite = T)
  
}

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Delete global, data, lessons original files  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fs::dir_delete(paste0(to, "/", c("global", "lessons", "data")))



## finally delete empty folders with terminal command (as at 2022-03-17, this does not seem to delete everything)
system2(
  command = "find",
  args = c(to, "-empty", "-type d", "-delete")
)


