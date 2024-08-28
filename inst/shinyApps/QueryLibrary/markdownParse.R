

getSqlFromMarkdown <- function(filename) {
  # createRenderedHtml(filename)
  markdownLines <- readLines(con <- file(filename))
  close(con)

  sqlLines <- character()
  isInSqlSnippet <- FALSE
  for (line in markdownLines) {
    # If line starts with three ticks, it is the start of a snipped
    if (startsWith(line, "```sql")) {
      isInSqlSnippet <- TRUE
    } else if (startsWith(line, "```")) {
      isInSqlSnippet <- FALSE
    } else {
      if (isInSqlSnippet) {
        sqlLines <- c(sqlLines, line)
      }
    }
  }
  full_sql <- paste(sqlLines, collapse = "\n")

  return(full_sql)
}

updateSqlWithInputs <- function(sql, input_vars){
  for (input_var in input_vars) {
    placeholder <- paste0("{{", input_var$varname, "}}")
    
    value_to_replace <- tryCatch(
      as.character(input_var$value),
      error = function(e) NULL
    )
    
    if (!is.na(input_var$value) && is.character(value_to_replace) && length(value_to_replace) > 0){
      sql <- gsub(placeholder, value_to_replace, sql, fixed = TRUE)  
    }
  }
  return (sql)
}
  

getVariableFromMarkdown <- function(filename, key) {
  markdownLines <- readLines(con <- file(filename))
  close(con)

  sqlLines <- character()
  for (line in markdownLines) {
    # If line starts with three ticks, it is the start of a snipped
    if (startsWith(line, key)) {
      version <- strsplit(line, ":")[[1]][2]
      return(version)
    }
  }
  return("")
}

getInputVarFromMarkdown <- function(filename, key){
  if (length(filename) == 0) {
    return(list())
  }
  markdownLines <- readLines(con <- file(filename))
  close(con)
  
  sqlLines <- character()
  inputvars <- list()
  for (line in markdownLines) {
    # If line starts with three ticks, it is the start of a snipped
    if (startsWith(line, key)) {
      varname_vartype <- strsplit(line, ":")[[1]][2]
      varname <- strsplit(varname_vartype, ",")[[1]][1]
      vartype <- strsplit(varname_vartype, ",")[[1]][2]
      varname <- trimws(varname)
      vartype <- trimws(vartype)
      
      inputvars <- append(inputvars, list(list("varname"=varname, "vartype"=vartype)))
    }
  }

  return(inputvars)
}

createRenderedHtml <- function(filename, targetSql) {
  markdownLines <- readLines(con <- file(filename))
  close(con)

  output <- character()
  output <- c(output, "---")
  output <- c(output, "title: \"&nbsp;\"")
  output <- c(output, "---")
  isInSqlSnippet <- FALSE
  sqlWritten <- FALSE
  for (line in markdownLines) {
    # Find sql snippet
    if (startsWith(line, "```sql")) {
      isInSqlSnippet <- TRUE
      output <- c(output, line)
    } else if (startsWith(line, "```")) {
      isInSqlSnippet <- FALSE
    }
    if (!isInSqlSnippet) {
      output <- c(output, line)
    } else if (!sqlWritten) {
      output <- c(output, targetSql)
      sqlWritten <- TRUE
    }
  }
  writeLines(output, con <- file(paste0(tempFolder, "/rendered.Rmd")))
  close(con)
  rmarkdown::render(paste0(tempFolder, "/rendered.Rmd"),
                    output_file = "rendered.html",
                    output_dir = paste0(tempFolder),
                    quiet = TRUE,
                    output_format = rmarkdown::html_document(theme = NULL,
                                                             mathjax = NULL,
                                                             highlight = "pygments",
                                                             css = "rendered.css"))
  return("rendered.html")
}
# r <-
# getSqlFromMarkdown('inst/shinyApps/QueryLibrary/queries/care_site/CS01_Care_site_place_of_service_counts.Rmd')
# cat(r)
