# Lesson Utility Functions
## GRAPH Courses team
## 2022-09-10

#' Functions used for lesson Rmds

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, htmltools, png)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Functions ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### mute ----

#' Source script very quietly
#'
#' @param x script to be sourced
#'
#' @return nothing
#'
.mute <- function(x) {
  invisible(suppressMessages(capture.output(source(x))))
}

### print_image ----

#' Print image to R graphic device.
#'  
#' Sometimes more wieldy than `knitr::include_graphics`.
#'
#' @param img_path 
#'
#' @return nothing
#'
#' @examples
#' 
.print_image <-
  function(img_path) {
    img <- png::readPNG(here::here(img_path))
    grid::grid.raster(img)
  }

### reactable_print ----

#' Pretty print data frames  with reactable
#'
#' @param df 
#' @param nrows 
.reactable_print <- function(df, nrows){
  df %>% 
    reactable::reactable(defaultPageSize = nrows, 
                         striped = TRUE,
                         highlight = TRUE,
                         resizable = TRUE,
                         defaultColDef = reactable::colDef(align = "left", 
                                                           html = TRUE, 
                                                           class = "border-left", 
                                                           na = "NA"), 
                         wrap = FALSE,
                         bordered = TRUE,
                         theme = reactable::reactableTheme(stripedColor = "#f2f7f7", 
                                                           cellPadding = "2px 5px 2px 5px", 
                                                           borderColor = "#e1f2f2", 
                                                           borderWidth = "1.5px"))
}   

# the "options" argument is required by knitr
.reactable_5_rows <- function(df, options) df %>% .reactable_print(5) %>% knitr::knit_print()
.reactable_10_rows <- function(df, options) df %>% .reactable_print(10) %>% knitr::knit_print()

# regular print
.head_10_rows <- function(df, options) df %>% head(10) %>% knitr::knit_print()
.head_5_rows <- function(df, options) df %>% head(5) %>% knitr::knit_print()


### tgc_license ----


#' Print the GRAPH Courses license
#'
#' @return HTML text and license image
.tgc_license <- function(){
  htmltools::HTML(
    paste0(
      "This work is licensed under the <a href = 'https://creativecommons.org/licenses/by-sa/4.0/'> Creative Commons Attribution Share Alike</a> license. ",
      '<a class="license" rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">
    <img alt="Creative Commons License" src="https://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a>')
  )
  
}

### tgc_contributors_list ----

#' Print list of contributors
#'
#' @param ids IDs of contributors
#' @param csv_path Path to source csv
#' @return HTML output for contributors
.tgc_contributors_list <- function(ids, csv_path = here::here("global/contributors/tgc_contributors.csv")){
  ## accepts a vector of ids. Please use the same id as the nickname on our platform
  
  ## import df and arrange it in the order in which the ids were provided. 
  tgc_contributors <- 
    readr::read_csv(csv_path) %>%  
    mutate(id = factor(id, levels = ids)) %>% 
    arrange(id)
  
  ## which contributors?
  rows <- which(tgc_contributors$id %in% ids)
  
  ## conent for HTML elements
  image_paths <- here::here(tgc_contributors$image_path[rows])
  links <- tgc_contributors$link[rows]
  names <- toupper(tgc_contributors$name[rows])
  labels <- tgc_contributors$label[rows]
  taglines <- ifelse(is.na((tgc_contributors$tagline[rows])), "", 
                     tgc_contributors$tagline[rows])
  
  ## paste contributor info inside HTML decorations
  list_elements <-glue::glue("<li><img src= {image_paths} width='50px' height='50px' />
                             <name><a href='{links}' target='_blank'>{names} </a> </name> <br>
                             <label>{labels}</label>
                             <p>{taglines}</p></li>")
  
  ## the CSS for the user-profile-details class should be defined somewhere
  out <- htmltools::HTML(paste0("<div class='user-profile-details'><ul>",
                                list_elements,
                                "</ul></div>"))
  out
}