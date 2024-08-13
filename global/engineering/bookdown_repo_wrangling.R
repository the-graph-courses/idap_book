# Bookdown repo wrangling 
## GRAPH Courses team
## 2022-06-19

#' Misc tasks on bookdown repo

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, xml2, here)


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  Copy custom css into repo  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# DO NOT RERUN. Will overwrite edited CSS
files <- c("default-fonts", "default-page", "default")
from <- pagedown:::pkg_resource(paste0("css/", files, ".css"))

target_folders <- here("global/style")
to <- paste(target_folders, c("custom-fonts.css", "custom-page.css", "custom.css"), sep = "/")
file.copy(from = from, to = to)

files <- c("crc-page", "crc")
from <- pagedown:::pkg_resource(paste0("css/", files, ".css"))

target_folders <- here("bookdown/lessons/style")
to <- paste(target_folders, c("tgc_crc_page.css", "tgc_crc.css"), sep = "/")
file.copy(from = from, to = to)



##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Copy template into repo ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
file.copy(
  pagedown:::pkg_resource("html", "paged.html"), 
  here("bookdown/lessons/style/custom_template.html")
)
