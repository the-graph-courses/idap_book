# Miscellaneous Functions
## GRAPH Courses team
## 2021-10-10

#' Misc functions used across scripts

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Load packages ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, htmltools, parsermd, DT, reactable,
               png, openxlsx, htmlTable)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Quiz utilities ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#' Upload a file to the GRAPH Courses Google Drive
#' 
#' 
#' By default, each time this function is used, it will upload a *new* copy of the object in question, not overwrite the previous copies. 
#' This is facilitated by the `uuid::UUIDgenerate()` function. If you wish to overwrite old objects, use `identifier = "SOME_FIXED_ID"`. 
#' Your files will then be uploaded as "CHUNK_NAME-SOME_FIXED_ID". Or you could use `identifier = NULL`.
#' Be careful with this though. If there is some object already on the Drive called e.g. "mydat", 
#' and two years later, you use this function with `identified = "mydat"`, you will overwrite that old dataset, and may break some quiz that references it.
#' 
#' Note also that you need to run `googledrive::drive_auth(email = "YOUR_EMAIL")` in an interactive session before using this.
#' 
#' This function is also built to be taken in by knitr to automatically upload images generated in a chunk and return the embedding link. 
#' To set this up, pass this function to the `upload.fun` argument of `knitr$opts_chunk`
#' 
#'
#' @param file Full path to file to be uploaded
#' @param gdrive_dir Directory on our Google Drive to put the image 
#' @param role,type See `googledrive::drive_share`
#' @param identifier string to suffix the filename with, to permit uniqueness (and avoid overwriting) on our GDrive. Set to NULL to overwrite.
#'
#' @return A link to the now shared file on Google drive. If file is an image, the embed link is returned.
#' 
#' @note 
#' 
#' 
#' @import googledrive, stringr, UUID
#'
#' @examples
#'
gdrive_upload <- function(file,
                          object_type = "image",
                          gdrive_dir = "quizzes/images/",
                          identifier = uuid::UUIDgenerate(),
                          role = "reader",
                          type = "anyone") {
  
  if (object_type == "data" && (is.null(gdrive_dir) || gdrive_dir == "quizzes/images/" )) gdrive_dir <- "quizzes/data/"
  
  # rename file before uploading. To provide unique id to prevent conflicts
  base_name <- basename(file) |> tools::file_path_sans_ext()
  extension <- tools::file_ext(file)
  file_unique <- paste(paste0(c(base_name, identifier), collapse = "-"), 
                       extension, sep = ".")
  
  
  # Upload to GDrive
  gdrive_file_path <- paste0(gdrive_dir, file_unique)
  
  googledrive::drive_upload(file,
                            path = gdrive_dir,
                            name = file_unique,
                            overwrite = T)
  
  # Grant viewing permission
  googledrive::drive_share(gdrive_file_path, role = role, type = type)
  
  # If image, modify link for embedding
  if (object_type == "image"){
    out <-  
      googledrive::drive_link(gdrive_file_path) |>
      # Should look like https://drive.google.com/uc?export=view&id=1JYUC9RSRtICiL9hDYXevpmZWdXPZwd6D
      stringr::str_remove("/view\\?usp=drivesdk") |>
      stringr::str_replace("file/d/", "uc?export=view&id=") 
    
    return(out)
  }
  
  # for other object types, return normal viewing link
  return(googledrive::drive_link(gdrive_file_path))
  
}


#' Insert a code chunk containing code for importing a dataset
#'
#' @param gdrive_link Google Drive link (for viewing) returned from the `gdrive_upload` function
#' @param data_name Character string. The name of the dataset that the student should use
#'
#' @return Code chunk for Rmd
#' 
#' @note The chunk where this function is used should have echo = F and results = "asis" as chunk options.
#'
#' @examples 
#' gdrive_import_chunk("https://drive.google.com/file/d/11QgvNvAjDGXK8KprgxJ-kZp5qRDgUVpt/view?usp=drivesdk", "ebola_dat_raw")
#' 
gdrive_import_chunk <- function(gdrive_link, data_name, format) {
  
  # Parse link for data-reading chunk
  id <- gdrive_link |>  dirname() |>  basename() # google file ID
  gdrive_download_link <- sprintf("https://docs.google.com/uc?id=%s&export=download", id)
  
  cat('```  \n')
  cat('if(!require(pacman)) install.packages("pacman")')
  cat('   \n')
  cat('pacman::p_load(rio)')
  cat('   \n')
  cat(data_name, ' <- import("', gdrive_download_link, '",\n format = "', format, '",\n setclass = "tibble")', sep = '')
  cat('  \n```')
  
}


#' Export and upload object, and provide students with download button or import code to read it in
#'
#' @param x object to be exported
#' @param filename name of the file
#' @param format 
#' @param message
#' @param which
#' @param identifier string to suffix the filename with, to permit uniqueness (and avoid overwriting) on our GDrive. Set to NULL to overwrite.
#'
#' @return
#' @export
#'
#' @examples
upload_and_link <-
  function(x,
           filename = "quiz-data",
           format = "csv",
           which = "both", 
           identifier = uuid::UUIDgenerate(), 
           gdrive_dir = NULL) {
    
    name_and_ext <- paste0(filename, ".", format)
    
    # export data to temp directory
    file <- paste0(tempdir(), "/", name_and_ext)
    
    rio::export(x, file = file, format = format)
    
    # upload data and get link
    gdrive_link <- gdrive_upload(file, object_type = "data", identifier = identifier, gdrive_dir = gdrive_dir)
    
    
    if (which %in% c("both", "download")) 
      cat(paste0("Click [**here**]", "(", gdrive_link, "){target='_blank'}", " to view and download the data."))
    
    if (which %in% c("both", "read")) {
      cat(paste0(" Or import it directly into R with the code below:\n")) ## phrasing here is stupid for the "read" argument value. Should remove the "or". 
      cat(gdrive_import_chunk(gdrive_link, filename, format))
    }
    
    
  }


#' Read seeded HTML quiz outputs into data frame for eventual upload
#' 
#' This function was created to work with this plugin: https://wooninjas.com/downloads/learndash-quiz-import-export/
#' Since the plugin uses Excel files, the HTML quiz file has to be under 25KB (to fit into an Excel cell)
#' Hence images and data cannot be encoded within the file. 
#' You would need to use the {gdrive_upload} functions instead to upload data.
#'
#' @param seeds Seeds iterated over to create quiz resamplings
#' @param quiz_path Absolute path to the quiz
#' @param quiz_title User-facing title for quiz. E.g. "4.2.2 Data quiz: Ebola in Sierra Leone"
#' @param course_id Normally a 5-digit numeric ID obtained from the table on the LearnDash LMS > Courses page
#' @param lesson_id Normally a 5-digit numeric ID obtained from the table on the LearnDash LMS > Lessons page
#'
#' @return Data frame
#'
#' @examples 
#' # See template chapter for example
quiz_html_to_tab <-
  function(num_labels,
           quiz_folder,
           quiz_title, 
           quiz_name = basename(quiz_folder)) {
    
    
    
    
    # create empty data frame
    col_names <- c("Quiz title", "Quiz content", "Question", "Category", "Title", "Total point", "Show points in box", "Different points for each answer",
                   "Answer 1", "Point 1", "Answer", "Answer points diff modus activated", "Question text", "Message with correct answer", "Message with incorrect answer",
                   "Hint", "Materials", "Certificate awarded for", "Passing percentage", "Course", "Lesson or topic", "Certificate")
    my_quiz <- data.frame(matrix(ncol = length(col_names), nrow = 0))
    colnames(my_quiz) <- col_names
    
    
    
    # populate data frame with quiz questions
    for (i in 1:length(num_labels)) {
      
      # names
      question_name <- paste0(quiz_name, "_", num_labels[i])
      # read in quiz text
      quiz_html <- readLines(paste0(quiz_folder, "/", num_labels[i], ".html")) |> paste0(collapse = "\n")
      
      # # read in quiz explanations if they exist
      # quiz_html <- readLines(paste0(quiz_folder, "/", num_labels[i], ".html")) |> paste0(collapse = "\n")
      # 
      # 
      # 
      # Count braces
      count_open_braces <- sum(gregexpr("{", quiz_html, fixed=TRUE)[[1]] > 0)
      count_closed_braces <- sum(gregexpr("}", quiz_html, fixed=TRUE)[[1]] > 0)
      if(count_open_braces != count_closed_braces) stop(paste0("HTML for ", num_labels[i], " contains unmatched braces."))
      
      
      # plug into table
      my_quiz[i, "Quiz title"] <- quiz_title
      my_quiz[i, "Question"] <- "cloze_answer"
      my_quiz[i, "Category"] <- quiz_name
      my_quiz[i, "Title"] <- question_name
      my_quiz[i, "Show points in box"] <- "yes"
      my_quiz[i, "Total point"] <- count_open_braces
      my_quiz[i, "Different points for each answer"] <- "yes"
      my_quiz[i, "Answer points diff modus activated"] <- "yes"
      my_quiz[i, "Question text"] <- "<span> </span>"
      my_quiz[i, "Answer"] <- quiz_html
      my_quiz[i, "Passing percentage"] <- 60
      # my_quiz[i, "Course"] <- course_id
      # my_quiz[i, "Lesson or topic"] <- lesson_id
      
    }
    
    return(tibble::as_tibble(my_quiz))
    
  }



#' Internal. Parse quiz into separate data frames
#'
#' @param rmd_file Path to Rmd rile to be parsed
#'
#' @return List of data frames, with each data frame contaiting an element of the rmd quiz
rmd_to_df_list <- function(rmd_file){
  
  
  # Read in and parse rmd
  quiz_lines_raw <- readr::read_lines(rmd_file)
  parsed_rmd <- 
    parse_rmd(rmd_file) %>% 
    as_tibble() %>% 
    mutate(sec_h2 = str_to_lower(sec_h2), 
           label = str_to_lower(label))
  
  # Check for start of quiz
  if(!any(str_detect(parsed_rmd$sec_h2, "question-1"))) stop("Could not find start of quiz, '## Question-1'. Are you using the correct syntax?")
  
  # Check for duplicate heading
  sec_h2 <- parsed_rmd %>% filter(type == "rmd_heading") %>% pull(sec_h2)
  if(any(duplicated(sec_h2))) stop(paste("found duplicate headers:", paste(sec_h2[duplicated(sec_h2)], collapse = " ") ))
  
  # Dissect Rmd sections
  yaml <- parsed_rmd %>% filter(type == "rmd_yaml_list") 
  setup <- parsed_rmd %>%  filter(label == "setup")
  prologue <- parsed_rmd %>% filter(sec_h2 == "prologue")
  epilogue <- parsed_rmd %>%  filter(label == "epilogue")
  
  questions_and_explanations <- 
    parsed_rmd %>% 
    separate(col = "sec_h2", 
             into = c("element", "set", "version"), 
             sep = "-", 
             remove = F, fill = "right") %>% 
    mutate(set = str_pad(set, width = 2, pad = "0"), 
           version = str_pad(version, width = 2, pad = "0")) %>% 
    mutate(set_version = paste0(set, "_", version)) 
  
  questions <- questions_and_explanations %>% filter(element == "question")
  explanations <- questions_and_explanations %>% filter(element == "explanation")
  
  # Return
  quiz_df_list <- list(yaml = yaml, setup = setup, prologue = prologue, questions = questions, 
                       epilogue = epilogue, explanations = explanations)
  
  return(quiz_df_list)
}

reshuffle_stratified_theory_quiz <- 
  function(rmd_file, n_reshufflings){
    
    # rmd to list of data frames
    quiz_df_list <- rmd_file %>% rmd_to_df_list()
    yaml <- quiz_df_list$yaml %>% as_document()
    setup <- quiz_df_list$setup %>% as_document()
    prologue <- quiz_df_list$prologue  %>% as_document()
    questions <- quiz_df_list$questions
    epilogue <- quiz_df_list$epilogue %>% as_document()
    explanations <- quiz_df_list$explanations
    
    
    # Check for start of quiz
    if(!any(str_detect(questions$sec_h2, "question-1-1"))) stop("Could not find start of quiz, '## Question-1-1'. Are you using the correct syntax?")
    
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Main sampling protocol 
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    # Number of possible unique question combos
    possible_unique <- 
      questions %>% 
      distinct(set_version, .keep_all = T) %>% 
      mutate(set = as.integer(set), version = as.integer(version)) %>% 
      group_by(set) %>% 
      count() %>% 
      pull(n) %>% 
      prod()
    
    # Sample (there is definitely a more efficient way to do this "sampling". I leave to the statisticians)
    set_and_version_df <- questions %>% select(set, version, set_version) %>% distinct() 
    
    # What is a reasonable number of iterations to take to maximize dissimilarity across quiz tries?
    # I picked 30 * the total number of questions versions.
    reshufflings_of_set_and_version <- list()
    for(i in 1:(30*length(set_and_version_df))){
      
      reshufflings_of_set_and_version[[i]] <- 
        set_and_version_df %>% 
        group_by(set) %>% 
        slice_sample(n = 1) %>% 
        ungroup()
    }
    
    final_unique_reshufflings <- unique(reshufflings_of_set_and_version) %>% sample() %>% head(n_reshufflings)
    
    # Report on sampling procedure
    print(paste0("Your quiz has ", possible_unique, " possible unique question combinations. ", 
                 "You have asked for a sample of ", n_reshufflings, ". ", 
                 "Now returning ", length(final_unique_reshufflings), " unique quizzes."))
    
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Rejoin chosen samples with questions and explanations df
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    reshuffled_questions <- list()
    for (i in 1:length(final_unique_reshufflings)){
      reshuffled_questions[[i]] <- 
        final_unique_reshufflings[[i]] %>% 
        left_join(questions, by = c("set", "version", "set_version")) %>% 
        select(sec_h2, type, label, ast) %>% 
        filter(!is.na(sec_h2))
      
      class(reshuffled_questions[[i]]) <- c("rmd_tibble", "tbl_df", "tbl", "data.frame")  # otherwise, parsermd will not accept it
    }
    
    if (nrow(explanations) > 0){
      
      reshuffled_explanations <- list()
      for (i in 1:length(final_unique_reshufflings)){
        reshuffled_explanations[[i]] <- 
          final_unique_reshufflings[[i]] %>% 
          left_join(explanations, by = c("set", "version", "set_version")) %>% 
          select(sec_h2, type, label, ast) %>% 
          filter(!is.na(sec_h2))
        
        class(reshuffled_explanations[[i]]) <- c("rmd_tibble", "tbl_df", "tbl", "data.frame")  # otherwise, parsermd will not accept it
      }
    }
    
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Output resulting Rmds 
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    for (i in 1:length(reshuffled_questions)){
      
      # remove evidence of sampling from questions. Could be done more efficiently with better regex
      # also would be better to do this to the `questions` object *before* it gets joined with each of the reshufflings
      reshuffled_question_lines <- reshuffled_questions[[i]] %>% as_document()
      detect_question_header <- reshuffled_question_lines %>% str_detect("## Question-[:digit:]|## question-[:digit:]")
      from <- reshuffled_question_lines[detect_question_header]
      to <- from %>% str_sub(1, -3) %>% str_replace_all("-", " ")
      dictio <- setNames(to, from)
      reshuffled_question_lines_out <- str_replace_all(reshuffled_question_lines, dictio)
      
      if (nrow(explanations) > 0){
        
        # remove evidence of sampling from explanations
        reshuffled_explanation_lines <- reshuffled_explanations[[i]] %>% as_document()
        detect_explanation_header <- reshuffled_explanation_lines %>% str_detect("## Explanation-[:digit:]|## explanation-[:digit:]")
        from <- reshuffled_explanation_lines[detect_explanation_header]
        to <- from %>% str_sub(1, -3) %>% str_replace_all("-", " ") %>% str_replace_all("Explanation", "Explanation for question")
        dictio <- setNames(to, from)
        reshuffled_explanation_lines_out <- str_replace_all(reshuffled_explanation_lines, dictio)
      }
      
      i_padded <- str_pad(i, width = max(nchar(length(reshuffled_questions)), 2), pad = "0") ## pad with at least one 
      
      # write questions file
      c(yaml,
        setup,
        prologue,
        reshuffled_question_lines_out,
        epilogue) %>%
        write_lines(file = paste0(dirname(rmd_file), "/", i_padded, ".Rmd"))
      
      if (nrow(explanations) > 0){
        
        # write explanations file
        c(yaml,
          setup,
          if (exists("reshuffled_explanation_lines_out")) reshuffled_explanation_lines_out,
          epilogue) %>%
          write_lines(file = paste0(dirname(rmd_file),"/", "explanations-", i_padded, ".Rmd"  ))
        
      }
      
    }
    
  }


reshuffle_simple_theory_quiz <- 
  function(rmd_file, n_reshufflings, questions_per_quiz){
    
    # rmd to list of data frames
    quiz_df_list <- rmd_file %>% rmd_to_df_list()
    
    
    yaml <- quiz_df_list$yaml %>% as_document()
    setup <- quiz_df_list$setup %>% as_document()
    prologue <- quiz_df_list$prologue  %>% as_document()
    questions <- quiz_df_list$questions
    epilogue <- quiz_df_list$epilogue %>% as_document()
    explanations <- quiz_df_list$explanations
    
    # Check to ensure this isn't actually a group quiz
    if(any(str_detect(questions$sec_h2, "question-1-1"))) stop("I saw '## Question-1-1'. Are you sure you are not building a 'stratified' quiz?")
    
    # Number of possible unique question combos
    total_questions <- questions %>% distinct(set) %>% nrow() 
    possible_unique_sets <- total_questions %>% choose(questions_per_quiz)
    final_unique_reshufflings <- min(possible_unique_sets, n_reshufflings)
    
    # Report on sampling procedure
    cat(paste0("Your quiz has ", total_questions, " total questions", 
               " from which it is possible to pick ", possible_unique_sets, 
               " unique sets of ", questions_per_quiz, ".", "\n",
               
               "You have asked for ", n_reshufflings, " quizzes, with ", questions_per_quiz, " questions per quiz.\n",
               
               "Now returning ", final_unique_reshufflings, " unique quizzes", ", with ", questions_per_quiz, " questions per quiz."))
    
    # Reshuffle
    questions_vec_to_shuffle <- questions %>% distinct(set) %>% pull(1)
    reshuffled_questions <- list()
    
    for (i in 1:final_unique_reshufflings) {
      
      selected_questions_vec <- utils::combn(questions_vec_to_shuffle, questions_per_quiz)[, i]
      reshuffled_questions[[i]] <- questions %>% filter(set %in% selected_questions_vec)
      
      class(reshuffled_questions[[i]]) <- c("rmd_tibble", "tbl_df", "tbl", "data.frame")  # otherwise, parsermd will not accept it
    }
    
    # Output Rmds
    for (i in 1:length(reshuffled_questions)){
      
      # remove evidence of sampling from questions.
      reshuffled_question_lines <- 
        reshuffled_questions[[i]] %>% 
        as_document() %>% 
        str_remove_all("## Question-[:digit:]|## question-[:digit:]")
      
      
      # remove evidence of sampling from questions. Could be done more efficiently with better regex
      # also would be better to do this to the `questions` object *before* it gets joined with each of the reshufflings
      reshuffled_question_lines <- reshuffled_questions[[i]] %>% as_document()
      detect_question_header <- reshuffled_question_lines %>% str_detect("## Question-[:digit:]|## question-[:digit:]")
      from <- reshuffled_question_lines[detect_question_header]
      from_number <- str_sub(from, -1, -1)
      to_number <- as.character(1:length(from_number))
      to <- paste0("## Question ", to_number)
      dictio <- setNames(to, from)
      reshuffled_question_lines_out <- str_replace_all(reshuffled_question_lines, dictio)
      
      
      i_padded <- str_pad(i, width = max(nchar(length(reshuffled_questions)), 2), pad = "0") ## pad with at least one 
      
      # write questions file
      c(yaml,
        setup,
        prologue,
        reshuffled_question_lines_out,
        epilogue) %>%
        write_lines(file = paste0(dirname(rmd_file), "/", i_padded, ".Rmd"))
      
    }
    
  }







#' Process TGC quizzes
#' 
#' Will document this better in due time. 
#' But very briefly:
#' For theory quiz types, this function first calls `reshuffle_stratified_theory_quiz()` or `reshuffle_simple_theory_quiz()` to create unique rmd copies
#' Then, for all quiz types, the rmds are knitted within a loop.
#' Finally the output HTML files are stuffed into an Excel spreadsheet with `quiz_html_to_tab`
#'
#'
#' @param quiz_type 
#' @param quiz_folder 
#' @param quiz_title 
#' @param course_abbrev 
#' @param n_quizzes 
#'
#' @return
#' @export
#'
#' @examples
process_quiz <-
  function(quiz_type = quiz_type,
           quiz_folder = quiz_folder,
           quiz_title = quiz_title,
           course_abbrev = course_abbrev, 
           n_quizzes = n_quizzes, 
           questions_per_quiz = NULL) {
    
    
    if (quiz_type %in% c("stratified_theory" , "simple_theory")) {
      
      
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ## Reshuffle and render 
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      n_reshufflings <- n_quizzes
      num_labels <- 1:n_reshufflings
      num_labels_padded <-
        num_labels %>% str_pad(max(2, nchar(n_reshufflings)), pad = "0")
      
      rmd_file <- paste0(quiz_folder, "/quiz.Rmd")
      
      # Reshuffle based on type
      if (quiz_type == "stratified_theory") {
        reshuffle_stratified_theory_quiz(rmd_file = rmd_file, n_reshufflings = n_reshufflings)
      }
      
      if (quiz_type == "simple_theory") {
        reshuffle_simple_theory_quiz(rmd_file = rmd_file, 
                                     n_reshufflings = n_reshufflings, 
                                     questions_per_quiz = questions_per_quiz)
      }
      
      # Render
      files_to_render <-
        quiz_folder %>% fs::dir_ls(type = "file",
                                   regexp = paste0(num_labels_padded, ".Rmd$", collapse = "|"))
      file_names <-
        basename(files_to_render) %>% tools::file_path_sans_ext()
      
      for (i in 1:length(files_to_render)) {
        rmarkdown::render(files_to_render[i],
                          output_file = paste0(file_names[i], ".html"))
      }
      
      # Delete unneeded "files" folders if they exist (self_contained = "yes" forces base64 encoding)
      fs::dir_ls(quiz_folder, type = "directory", regexp = "files") %>%  fs::dir_delete()
      
      
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ## Copy into excel file
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      quiz_tab <-
        quiz_html_to_tab(num_labels = num_labels_padded[1:length(files_to_render)],
                         quiz_folder = quiz_folder,
                         quiz_title = quiz_title)
      
      writexl::write_xlsx(
        x = quiz_tab,
        path = paste0(quiz_folder, "/", course_abbrev, "_", basename(quiz_folder), ".xlsx")
      )
    }
    
    
    
    if (quiz_type == "data") {
      
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ## Iterated render
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      n_resamplings <- n_quizzes 
      seeds <- 1:n_resamplings
      seeds_padded <- seeds %>% str_pad(max(2, nchar(n_resamplings)), pad = "0")
      for (i in 1:length(seeds)) {
        rmarkdown::render(  input = paste0(quiz_folder, "/", "quiz.Rmd"),
                            params = list(seed = seeds[i]),
                            output_file = paste0(seeds_padded[i], ".html"))
      }
      
      # Delete unneeded "files" folders if they exist (self_contained = "yes" forces base64 encoding) 
      fs::dir_ls(quiz_folder, type = "directory", regexp = "files") %>%  fs::dir_delete()
      
      # Read html quizzes to data frames
      quiz_tab <- quiz_html_to_tab(num_labels = seeds_padded,
                                   quiz_folder = quiz_folder, 
                                   quiz_title = quiz_title)
      
      # Write df to Excel template
      rio::export(x = quiz_tab, 
                  file = paste0(quiz_folder, "/", course_abbrev, "_", 
                                basename(quiz_folder), ".xlsx"), 
                  format = "xlsx")
      
      openxlsx::write.xlsx(x = quiz_tab, 
                           file = paste0(quiz_folder, "/", course_abbrev, "_", 
                                         basename(quiz_folder), ".xlsx"))
    }
    
    
  }


#' Render TGC quizzes
#' 
#' The besides rendering the quiz, this function also reads in some parameters, such as the title,  course and type from the quiz.rmd file.
#' 
#' Will document this better in due time. 
#' But very briefly:
#' For theory quiz types, this function first calls `reshuffle_stratified_theory_quiz()` or `reshuffle_simple_theory_quiz()` to create unique rmd copies
#' Then, for all quiz types, the rmds are knitted within a loop.
#' Finally the output HTML files are stuffed into an Excel spreadsheet with `quiz_html_to_tab`
#'
#'
#' @param quiz_type 
#' @param quiz_folder 
#' @param quiz_title 
#' @param course_abbrev 
#' @param n_quizzes 
#'
#' @return
#' @export
#'
#' @examples
render_quiz <-
  function(quiz_folder = quiz_folder,
           n_quizzes = 3, 
           questions_per_quiz = NULL) {
    
    
    # Read the quiz information from the script file
    # Correct for the folder where your script sits, just point to the folder, not the rmd file.
    
    rmd_file <-  paste0(here(quiz_folder,"/quiz.Rmd"))
    yaml_info <- rmarkdown::yaml_front_matter(rmd_file)
    
    # Read the information from the yaml header of the file
    course_abbrev <-  yaml_info[["course_abbrev"]]
    quiz_title <- yaml_info[["quiz_title"]]
    quiz_type <- yaml_info[["quiz_type"]]
    

    if (quiz_type %in% c("stratified_theory" , "simple_theory")) {
      
      
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ## Reshuffle and render 
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      n_reshufflings <- n_quizzes
      num_labels <- 1:n_reshufflings
      num_labels_padded <-
        num_labels %>% str_pad(max(2, nchar(n_reshufflings)), pad = "0")
      
      rmd_file <- paste0(quiz_folder, "/quiz.Rmd")
      
      # Reshuffle based on type
      if (quiz_type == "stratified_theory") {
        reshuffle_stratified_theory_quiz(rmd_file = rmd_file, n_reshufflings = n_reshufflings)
      }
      
      if (quiz_type == "simple_theory") {
        reshuffle_simple_theory_quiz(rmd_file = rmd_file, 
                                     n_reshufflings = n_reshufflings, 
                                     questions_per_quiz = questions_per_quiz)
      }
      
      # Render
      files_to_render <-
        quiz_folder %>% fs::dir_ls(type = "file",
                                   regexp = paste0(num_labels_padded, ".Rmd$", collapse = "|"))
      file_names <-
        basename(files_to_render) %>% tools::file_path_sans_ext()
      
      for (i in 1:length(files_to_render)) {
        rmarkdown::render(files_to_render[i],
                          output_file = paste0(file_names[i], ".html"))
      }
      
      # Delete unneeded "files" folders if they exist (self_contained = "yes" forces base64 encoding)
      fs::dir_ls(quiz_folder, type = "directory", regexp = "files") %>%  fs::dir_delete()
      
      
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ## Copy into excel file
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      quiz_tab <-
        quiz_html_to_tab(num_labels = num_labels_padded[1:length(files_to_render)],
                         quiz_folder = quiz_folder,
                         quiz_title = quiz_title)
      
      writexl::write_xlsx(
        x = quiz_tab,
        path = paste0(quiz_folder, "/", course_abbrev, "_", basename(quiz_folder), ".xlsx")
      )
    }
    
    
    
    if (quiz_type == "data") {
      
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ## Iterated render
      ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      n_resamplings <- n_quizzes 
      seeds <- 1:n_resamplings
      seeds_padded <- seeds %>% str_pad(max(2, nchar(n_resamplings)), pad = "0")
      for (i in 1:length(seeds)) {
        rmarkdown::render(  input = paste0(quiz_folder, "/", "quiz.Rmd"),
                            params = list(seed = seeds[i]),
                            output_file = paste0(seeds_padded[i], ".html"))
      }
      
      # Delete unneeded "files" folders if they exist (self_contained = "yes" forces base64 encoding) 
      fs::dir_ls(quiz_folder, type = "directory", regexp = "files") %>%  fs::dir_delete()
      
      # Read html quizzes to data frames
      quiz_tab <- quiz_html_to_tab(num_labels = seeds_padded,
                                   quiz_folder = quiz_folder, 
                                   quiz_title = quiz_title)
      
      # Write df to Excel template
      rio::export(x = quiz_tab, 
                  file = paste0(quiz_folder, "/", course_abbrev, "_", 
                                basename(quiz_folder), ".xlsx"), 
                  format = "xlsx")
      
      openxlsx::write.xlsx(x = quiz_tab, 
                           file = paste0(quiz_folder, "/", course_abbrev, "_", 
                                         basename(quiz_folder), ".xlsx"))
    }
    
    
  }


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Lesson utilities ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
print_image <-
  function(img_path) {
    img <- png::readPNG(here::here(img_path))
    grid::grid.raster(img)
  }


#' Pretty print data frames  with reactable
#'
#' @param df 
#' @param nrows 
reactable_print <- function(df, nrows){
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
reactable_5_rows <- function(df, options) df %>% reactable_print(5) %>% knitr::knit_print()
reactable_10_rows <- function(df, options) df %>% reactable_print(10) %>% knitr::knit_print()

# regular print
head_10_rows <- function(df, options) df %>% head(10) %>% knitr::knit_print()
head_5_rows <- function(df, options) df %>% head(5) %>% knitr::knit_print()

# kable print
kable_10_rows <- function(df, options) df %>% head(10) %>% knitr::kable() %>% knitr::knit_print()
kable_5_rows <- function(df, options) df %>% head(5) %>% knitr::kable() %>% knitr::knit_print()

# DT print
dt_10_rows <- function(df, options) df %>% head(10) %>% DT::datatable() %>% knitr::knit_print()
dt_5_rows <- function(df, options) df %>% head(5) %>% DT::datatable() %>% knitr::knit_print()


#' Print the GRAPH Courses license
#'
#' @return HTML text and license image
tgc_license <- function(){
  htmltools::HTML(
    paste0(
      "This work is licensed under the <a href = 'https://creativecommons.org/licenses/by-sa/4.0/'> Creative Commons Attribution Share Alike</a> license. ",
      '<a class="license" rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">
    <img alt="Creative Commons License" src="https://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a>')
  )
  
}

#' Print list of contributors
#'
#' @param ids IDs of contributors
#' @param csv_path Path to source csv
#' @return HTML output for contributors
tgc_contributors_list <- function(ids, csv_path = here::here("global/contributors/tgc_contributors.csv")){
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
  list_elements <-glue::glue("<li><img src= '{image_paths}' width='50px' height='50px' />
                             <name><a href='{links}' target='_blank'>{names} </a> </name> <br>
                             <label>{labels}</label>
                             <p>{taglines}</p></li>")
  
  ## the CSS for the user-profile-details class should be defined somewhere
  out <- htmltools::HTML(paste0("<div class='user-profile-details'><ul>",
                                list_elements,
                                "</ul></div>"))
  out
}




##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## HTML utilities ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




#' Markdown to HTML table
#' 
#' Convert a markdown-formatted table to an HTML one.
#'
#' @param table character value containing the table
#' @param body Body
#' @import stringr
md_to_html_table <- function(table_char){
  
  table_lines <- readr::read_lines(table_char)[-2]
  
  table_matrix <- t(sapply(strsplit(table_lines, "\\|"), function(pieces){
    stringr::str_trim(pieces[-1])
  }))
  
  df <- 
    setNames(as_tibble(table_matrix[-1,,drop = FALSE]), table_matrix[1,])
  
  
  htmlTable::htmlTable(df)
  
}





#' Collapsible
#'
#' @param summary Label
#' @param body Body
#' @import htmltools
collapsible <-
  function(body = "Hint here", summary = "Hint") {
    htmltools::tags$details(tags$summary(summary),
                            body)
    
  }




#' Button with link
#'
#' @param link
#' @param label
#' @import htmltools
link_button <- function(link, label = "Download data") {
  htmltools::tags$form(action = link,
                       target="_blank",
                       tags$input(type = "submit",
                                  value = label))
  
}




##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Other functions ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#' Source script very quietly
#'
#' @param x script to be sourced
#'
#' @return nothing
#'
mute <- function(x) {
  invisible(suppressMessages(capture.output(source(x))))
}



#' Document functions in an R Script
#' @param source_file Path to script
#' @return nothing
#' @note This is now deprecated in favor of the more powerful document::document
documenter <- function(source_file) {
  source_env = roxygen2::env_file(source_file)
  rd_blocks = roxygen2::parse_file(source_file, source_env)
  help_topics = roxygen2::roclet_process(roxygen2::rd_roclet(),
                                         rd_blocks,
                                         source_env,
                                         dirname(source_file))
  rd_code = lapply(help_topics, format)
  
  for (i in 1:length(rd_code)) {
    
    function_name <- names(rd_code)[[i]] |> tools::file_path_sans_ext()
    rd_path <- paste0(dirname(source_file), "/", function_name, ".Rd")
    html_path <-paste0(dirname(source_file), "/", function_name, ".html")
    
    readr::write_file(rd_code[[i]], file = rd_path)
    
    tools::Rd2HTML(rd_path, html_path)
    
    unlink(rd_path)
    
  }
}

#' Renumber TGC lesson chapter
#' 
#' This script renames your chapter folder and lesson file names, and also replaces paths in the lessons/quizzes.
#' It uses a simple find and replace across the directory and containing files. 
#'
#' @param dir Path to the chapter directory
#' @param string_from Chapter number (with "ch" prefix) to be replaced. E.g. "ch01".
#' @param string_to New chapter number (with "ch" prefix) E.g. "ch02".
#'
#' @return nothing
#'
#' @examples
chapter_find_replace <- function(dir, string_from, string_to){

scripts <- fs::dir_ls(dir, type = "file", recurse = T, regexp = c("[.]R$|[.]Rmd$"))

# rename paths inside scripts
xfun::gsub_dir(dir = dir, 
         pattern = string_from, 
         replacement = string_to, 
         ext = c("Rmd", "R"))

# next rename scripts themselves
basename_scripts_from <- basename(scripts)
basename_scripts_to <- stringr::str_replace_all(basename_scripts_from, string_from, string_to)
scripts_to <- paste(dirname(scripts), basename_scripts_to, sep = "/")

file.rename(from = scripts, 
            to = scripts_to)

# finally rename chapter folder
file.rename(dir, 
            str_replace(dir, string_from, string_to))

}

