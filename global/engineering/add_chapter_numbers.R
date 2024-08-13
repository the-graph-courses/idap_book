# Add chapter numbers to lesson file names
## GRAPH Courses team
## 2022-04-12

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, here, fs, xfun)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Main ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


chapter_folders <- 
  fs::dir_ls(type = "dir") %>% 
  .[str_detect(., "chapter_")] %>% 
  sort()

# Rename chapter folders 
chapter_names_from <- paste0(here(chapter_folders))
chapter_names_to <- str_remove_all(chapter_names_from, "apter_")
file_move(chapter_names_from, chapter_names_to)

# Refresh names
chapter_folders_new <- 
  fs::dir_ls(type = "dir") %>% 
  .[str_detect(., "ch\\d\\d")] %>% 
  sort()

# Enumerate chapters and lessons
chapter_numbers <- c(1:6, 99) %>% str_pad(width = 2, pad = "0")
lesson_numbers <- 1:7 %>% str_pad(width = 2, pad = "0") # assuming lesson 7 is highest lesson number


# Main renaming loop
for (i in 1:length(chapter_folders_new)){
  
  
  lessons_path <- paste0(here(chapter_folders_new[i]), "/", "lessons")
  
  # Identify files to rename
  names_to_change <-  
    fs::dir_ls(lessons_path) %>% 
    basename() %>% 
    .[str_starts(., "\\d\\d_[:alpha:]")] 
  
  new_names <- paste0("ch", chapter_numbers[i], "_", "ls", names_to_change) 
  
  # rename files
  files_from <- paste0(here(chapter_folders_new[i]), "/lessons/", names_to_change)
  files_to <- paste0(here(chapter_folders_new[i]), "/lessons/", new_names)
  file_move(files_from, files_to)
  
  
  # Change path strings in scripts from e.g. 01_select to e.g. ch04_ls01_select
  path_string_from <- paste0("/", lesson_numbers, "_") 
  path_string_to <- paste0("ch", chapter_numbers[i], "_", "ls", lesson_numbers ) %>% paste0("/", ., "_")
  
  for (j in 1:length(path_string_from)){

    gsub_dir(dir = lessons_path, 
             pattern = path_string_from[j], 
             replacement = path_string_to[j], 
             ext = c("Rmd", "R"))
    
  }
  
  # Change path strings in scripts from e.g. chapter_01 to e.g. ch01
    gsub_dir(dir = lessons_path, 
             pattern = "chapter_" , 
             replacement = "ch", 
             ext = c("Rmd", "R"))
    
  
}
  
