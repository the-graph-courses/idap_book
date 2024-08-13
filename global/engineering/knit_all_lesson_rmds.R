# Knit Rmds for all lessons ----
## GRAPH Courses team
## 2021-06-27

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages and functions ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (!require(pacman)) install.packages("pacman")
pacman::p_load(xfun, fs, cli, tidyverse)


blue_print <- function(x) cat(cli::bg_blue(cli::col_white(cli::style_bold(x))))
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Re-render in staging repo if necessary  ----
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Filter files for rendering
rmds_to_render <- 
  fs::dir_ls(xfun::from_root(), 
             regexp = "ch\\d\\d_ls\\d\\d_.*Rmd$",
             recurse = T) %>%
  as_tibble() %>% 
  filter(str_detect(value, "/lessons/")) %>% 
  filter(!str_detect(str_to_lower(value), "ch99|ls99|/old/")) %>% 
  filter(!str_detect(str_to_lower(value), "-copy|-paste")) %>% 
  filter(!str_detect(str_to_lower(value), "/bookdown/")) %>% 
  filter(!str_starts(value, "bookdown/")) %>% 
  dplyr::pull(1)

# batched re-rendering in case of errors
for (rmd in rmds_to_render[8]) {
  blue_print(paste0("Rendering: \n", rmd, 
                    "\n(", which(rmd == rmds_to_render), " of ", length(rmds_to_render), ")"
  ))
  rmarkdown::render(rmd)
}
