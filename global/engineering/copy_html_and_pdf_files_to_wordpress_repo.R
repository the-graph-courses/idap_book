# Copy staging repo to student repo ----
## GRAPH Courses team
## 2021-03-27

#' Copies internal staging repo to a repo hosted on GitHub pages. Lessons are then embedded in our workspace

# Set language

LANGUAGE = "FR"

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages and functions ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if (!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, here, fs, cli, glue, xfun, parsermd, pagedown)

blue_print <- function(x) cat(cli::bg_blue(cli::col_white(cli::style_bold(x))))


# some tibble print options for the dfs
options(pillar.width = 60) # avoid overflow of tibbles
options(pillar.min_title_chars = 15,
        pillar.max_footer_lines = 2,
        pillar.min_chars = 15)

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Render Rmds to regular HTML ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

current_dir <- here::here()

if (LANGUAGE == "FR") {
  selected_lessons <- 
    c(
      "/FR_ls01_setting_up.Rmd",
      "/FR_ls02_using_rstudio.Rmd",
      "/FR_ls03_coding_basics.Rmd", 
      "/FR_ls04_data_dive_ebola_sierra_leone.Rmd", 
      "/FR_ls05_projects.Rmd",
      "/FR_ls06_rmarkdown.Rmd",
      "/FR_ls07_data_structures.Rmd"
    )
} else if (LANGUAGE == "EN") {
  selected_lessons <- 
    c("/ls01_setting_up.Rmd",
      "/ls02_using_rstudio.Rmd",
      "/ls03_coding_basics.Rmd",
      "/ls04_data_dive_ebola_sierra_leone.Rmd",
      "/ls05_projects.Rmd",
      "/ls06_rmarkdown.Rmd",
      "/ls07_data_structures.Rmd"
    )
}


rmds_to_render <- 
  fs::dir_ls(current_dir, 
             regexp = paste0(selected_lessons, collapse = "|"),
             recurse = T)


# Render documents
for (rmd in rmds_to_render[1:length(rmds_to_render)]) {
  
  blue_print(paste0("Rendering: \n", rmd, 
                    "\n(", which(rmd == rmds_to_render), " of ", length(rmds_to_render), ")"
  ))
  rmarkdown::render(rmd)
}

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Render Rmds to PDF ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for (rmd in rmds_to_render[1:length(rmds_to_render)]) {
  
   if (LANGUAGE == "EN") {
    yaml_to_append <- glue::glue('credits: "This lesson was created by the GRAPH Network,
                               a non-profit headquartered at the University of Geneva Global Health Institute, 
                               in collaboration with the World Health Organization,
                               under a Global Fund 2023 grant to create e-learning modules to build in-country data capacity for epidemiological data analysis"
                               date: "`r format(Sys.Date(), "%B %Y")`"
                               author: "GRAPH Network & WHO, supported by the Global Fund to fight HIV, TB & Malaria"')
   } else if (LANGUAGE == "FR"){
     yaml_to_append <- glue::glue('credits: "Ce cours a été créé par le Réseau GRAPH,
                               une organisation à but non lucratif basée à l’Institut de santé globale de l’Université de Genève,
                               en collaboration avec l’Organisation mondiale de la Santé,
                               dans le cadre d’une subvention du Fonds mondial pour créer des cours afin de renforcer les capacités nationales en matière d’analyse épidémiologique."
                               date: "`r format(Sys.Date(), "%B %Y")`"
                               author: "GRAPH Network & OMS, soutenu par le Fonds Mondial"')
  } 
    
                                 
  
  # duplicate rmd
  duplicate_rmd <- str_replace(rmd, ".Rmd", "-duplicate-for-pagedown.Rmd")
  fs::file_copy(path = rmd, new_path = duplicate_rmd, overwrite = T)
  
  # modify duplicate
  rmd_modified <- 
    read_lines(rmd) %>% 
    str_replace_all("render = reactable_5_rows", "render = head_5_rows")
    
 
  
  # append then write
  write_lines(x = c(rmd_modified,"\n","---", yaml_to_append, "---"), 
                file = duplicate_rmd)
  
  ##  render duplicate
  output_html <- str_replace(rmd, ".Rmd", "-pagedown.html")
  rmarkdown::render(duplicate_rmd, 
                    output_file = output_html, 
                    output_format = "pagedown::html_paged",
                    output_yaml = here("global/style/_output_pagedown.yml")) 
  

  # convert pagedown html to a pdf
  output_pdf <- str_replace(rmd, ".Rmd", ".pdf")
  chrome_print(output_html, 
               output = output_pdf, wait = 10)
  
  # delete duplicate rmd & html
  unlink(duplicate_rmd)
  unlink(output_html)
  
  
}


## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Copy the rendered lessons into wp repo  ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

from <- here::here()
to <- stringr::str_replace(from, "staging", "wp")

# list files to be copied
lesson_names <- basename(rmds_to_render) %>%  tools::file_path_sans_ext()

search_string <- paste0(
  paste0(paste(c(lesson_names),collapse = ".pdf|"), ".pdf"), "|",
  paste0(paste(c(lesson_names),collapse = ".html|"), ".html")
)

lesson_from_folder <- paste0(from, "/lessons")

files_to_copy <- dir_ls(lesson_from_folder)[str_detect(dir_ls(lesson_from_folder), search_string)]
files_to_copy

fs::file_copy(files_to_copy, 
             str_replace(files_to_copy, "staging", "wp"), 
             overwrite = TRUE)

# Delete rendered stuff from the source repo  
file.remove(files_to_copy)
