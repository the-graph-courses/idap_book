pacman::p_load(here, parsermd, tidyverse,  fs)

# Function to convert headers down one level

convert_headers <- function(line) {
  if (length(line) > 0 && str_detect(line, "^#+ ")) {
    return(str_replace(line, "^#", "##"))
  } else {
    return(line)
  }
}
# Function to replace render command
replace_render <- function(line) {
  line %>% 
    str_replace_all("render = reactable_5_rows", "render = head_5_rows") %>% 
    # 10 rows
    str_replace_all("render = reactable_10_rows", "render = head_10_rows")
}

# Function to convert custom divs to Quarto callouts with titles
convert_callouts <- function(line) {
  line <- str_replace_all(line, "::: r-practice", "::: {.callout-tip title='Practice'}")
  line <- str_replace_all(line, "::: practice", "::: {.callout-tip title='Practice'}")
  line <- str_replace_all(line, "::: watch-out", "::: {.callout-caution title='Watch Out'}")
  line <- str_replace_all(line, "::: key-point", "::: {.callout-note title='Key Point'}")
  line <- str_replace_all(line, "::: side-note", "::: {.callout-note title='Side Note'}")
  line <- str_replace_all(line, "::: pro-tip", "::: {.callout-note title='Pro Tip'}")
  line <- str_replace_all(line, "::: vocab", "::: {.callout-note title='Vocab'}")
  line <- str_replace_all(line, "::: reminder", "::: {.callout-note title='Reminder'}")
  line <- str_replace_all(line, "::: recap", "::: {.callout-note title='Recap'}")
  line <- str_replace_all(line, "::: rstudio-cloud", "::: {.callout-note title='RStudio Cloud'}")
  line <- str_replace_all(line, "::: challenge", "::: {.callout-note title='Challenge'}")
  line <- str_replace_all(line, "::: error", "::: {.callout-caution title='Caution'}")
  return(line)
}

remove_contributors <- function(line) {
  purrr::keep(line, ~!str_detect(., "(#|##) Contributors")) %>%
    purrr::keep(~!str_detect(., "team members contributed to this lesson")) %>% 
    purrr::keep(~!str_detect(., "tgc_contributors_list"))
  
}


# Function to replace heading like "Lesson notes | Coding basics" with "Coding basics"
replace_title <- function(line) {
  line %>% 
    str_remove_all("Lesson notes \\| ") %>% 
    str_remove_all("Lesson Notes \\| ")
}

### Import R foundations things ----

parent_folder <- dirname(here())
r_foundations_folder <- paste0(parent_folder, "/r_foundations_staging")

# Copy all the lessons
rmd_files <- list.files( paste0(r_foundations_folder, "/lessons"), 
                         pattern = "^ls[0-9]{2}.*\\.Rmd$", full.names = TRUE)
file.copy(rmd_files, paste0(here(), "/foundations_", basename(rmd_files)), overwrite = TRUE)

# Copy images
images_folder <- paste0(r_foundations_folder, "/lessons/images")
image_files <- list.files(images_folder, full.names = TRUE)
file.copy(image_files, paste0(here(), "/images"), overwrite = TRUE)

# Copy data
data_folder <- paste0(r_foundations_folder, "/data")
data_files <- list.files(data_folder, full.names = TRUE)
file.copy(data_files, paste0(here(), "/data"), overwrite = TRUE)

### Import Data untangled things ----
data_untangled_folder <- paste0(parent_folder, "/data_untangled_staging")

# Copy all the lessons
rmd_files <- 
  list.files(paste0(data_untangled_folder, "/lessons"), 
             pattern = "^ls[0-9]{2}.*\\.Rmd$", full.names = TRUE) %>% 
  # drop files containing "_TEACHER" or "VIDEO_CODE_ALONG"
  keep(~!str_detect(basename(.), "_TEACHER|VIDEO_CODE_ALONG"))

file.copy(rmd_files, paste0(here(), "/untangled_", basename(rmd_files)), overwrite = TRUE)

# Copy images
images_folder <- paste0(data_untangled_folder, "/lessons/images")
image_files <- list.files(images_folder, full.names = TRUE)
file.copy(image_files, paste0(here(), "/images"), overwrite = TRUE)

# Copy data
data_folder <- paste0(data_untangled_folder, "/data")
data_files <- list.files(data_folder, full.names = TRUE)
file.copy(data_files, paste0(here(), "/data"), overwrite = TRUE)

# Copy autograders
# R scripts starting with ls_ and ending in _autograder
autograder_files <- list.files(paste0(data_untangled_folder, "/lessons"), 
                               pattern = "^ls[0-9]{2}.*_autograder\\.R$", full.names = TRUE)
# create lessons folder if it doesn't exist
dir.create(paste0(here(), "/lessons"), showWarnings = FALSE)
file.copy(autograder_files, paste0(here(), "/lessons"), overwrite = TRUE)


### Import Data Viz things ----
data_on_display_folder <- paste0(parent_folder, "/data_on_display_staging")

# Copy all the lessons
rmd_files <- 
  list.files(paste0(data_on_display_folder, "/lessons"), 
             pattern = "^ls[0-9]{2}.*\\.Rmd$", full.names = TRUE) %>% 
  # drop files containing "_TEACHER" or "VIDEO_CODE_ALONG"
  keep(~!str_detect(basename(.), "_TEACHER|VIDEO_CODE_ALONG"))

file.copy(rmd_files, paste0(here(), "/data_on_display_", basename(rmd_files)), overwrite = TRUE)

# Copy images
images_folder <- paste0(data_on_display_folder, "/lessons/images")
image_files <- list.files(images_folder, full.names = TRUE)
file.copy(image_files, paste0(here(), "/images"), overwrite = TRUE)

# Copy data (for data viz, there are two folders called clean and raw. Copy the entire folders over)
data_folder <- paste0(data_on_display_folder, "/data")

# Get the list of all directories and subdirectories
data_folders <- fs::dir_ls(data_folder, recurse = TRUE, type = "directory")

# Function to copy each directory
copy_dir <- function(src_dir) {
  # Construct the relative path of the source directory
  rel_path <- fs::path_rel(src_dir, data_folder)
  # Construct the target directory path by appending the relative path
  target_dir <- fs::path(here(), "data", rel_path)
  # Ensure the target directory exists
  fs::dir_create(target_dir)
  # Copy the contents of the source directory to the target directory
  fs::file_copy(fs::dir_ls(src_dir, type = "file"), target_dir, overwrite = TRUE)
}

# Apply the function to each directory
walk(data_folders, copy_dir)


# Copy autograders
# R scripts starting with ls_ and ending in _autograder
autograder_files <- list.files(paste0(data_on_display_folder, "/lessons"), 
                               pattern = "^ls[0-9]{2}.*_autograder\\.R$", full.names = TRUE)
# create lessons folder if it doesn't exist
dir.create(paste0(here(), "/lessons"), showWarnings = FALSE)
file.copy(autograder_files, paste0(here(), "/lessons"), overwrite = TRUE)


# List rmd files to be processed
rmds_to_process <- list.files(here(), pattern = "ls[0-9]{2}.*\\.Rmd$", full.names = TRUE)

# Process each file
for (file_path in rmds_to_process) {

  # Read lines
  content <- readLines(file_path)
  
  # Remove Contributors sections
  content <- sapply(content, remove_contributors)
  
  # Convert headers
  content <- sapply(content, convert_headers)
  
  # Convert divs to callouts
  content <- sapply(content, convert_callouts)
  
  # Replace render command
  content <- sapply(content, replace_render)
  
  # Replace titles
  content <- sapply(content, replace_title)
  
  final_content <- unlist(content)  # Ensure final_content is a character vector
  
  # Write the modified content back to the original file, but as a qmd file QUARTO
  quarto_file_path <- str_replace(file_path, ".Rmd", ".qmd")
  writeLines(final_content, quarto_file_path)
  
  # Delete the original Rmd file
  file.remove(file_path)
}

