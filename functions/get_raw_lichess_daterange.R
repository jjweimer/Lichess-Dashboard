#can be used like get_raw_lichess() because auto values for dates are 01/01/2000 to 12/31/2099
#date strings need to be formatted mdy 
get_raw_lichess_daterange <- function (player_names, start = "01/01/2000", end = "12/31/2099") 
{
  get_file <- function(player_name) {
    cat("Extracting ", player_name, " games from " , start, " to ", end, ". Please wait\n")
    start <- as.numeric(as.POSIXct.Date(mdy(start))) * 1000
    end <- as.numeric(as.POSIXct.Date(mdy(end))) *1000
    tmp <- tempfile()
    curl::curl_download(paste0("https://lichess.org/api/games/user/", 
                               player_name, "?evals=true&clocks=true&opening=true",
                               "&since=",start,"&until=",end), 
                        tmp)
    read_in_file <- readLines(tmp)
    collapsed_strings <- paste(read_in_file, collapse = "\n") %>% 
      strsplit(., "\n\n\n") %>% unlist()
    games_list <- strsplit(collapsed_strings, "\n")
    return(games_list)
  }
  create_games_df <- function(games_list) {
    first_test <- games_list
    first_test <- first_test[-which(first_test == "")]
    tab_names <- c(gsub("\\s.*", "", first_test[grep("\\[", 
                                                     first_test)]) %>% gsub("\\[", "", .), "Moves")
    tab_values <- c(gsub(".*[\"]([^\"]+)[\"].*", "\\1", 
                         first_test[grep("\\[", first_test)]), first_test[length(first_test)])
    df <- rbind(tab_values) %>% data.frame(stringsAsFactors = F)
    colnames(df) <- tab_names
    rownames(df) <- c()
    errorneous_columns <- which(grepl("[0-9]", colnames(df)))
    df[, errorneous_columns] <- NULL
    column_names <- colnames(df) %>% paste0(collapse = ",")
    if (grepl("WhiteRatingDiff", column_names)) {
      df$WhiteRatingDiff <- gsub("\\+", "", df$WhiteRatingDiff)
    }
    if (grepl("WhiteRatingDiff", column_names)) {
      df$BlackRatingDiff <- gsub("\\+", "", df$BlackRatingDiff)
    }
    return(df)
  }
  final_output <- data.frame()
  for (each_player in player_names) {
    output <- get_file(each_player) %>% purrr::map_df(create_games_df)
    output$Username <- each_player
    output <- output %>% dplyr::filter(.data$Variant != 
                                         "From Position")
    final_output <- dplyr::bind_rows(final_output, output)
  }
  return(final_output)
}


