determine_titles <- function(df, user){
  if(is.null(df$WhiteTitle)){
    df$WhiteTitle <- NA
  }
  if(is.null(df$BlackTitle)){
    df$BlackTitle <- NA
  }
  df <- df %>% mutate(
    my_title = case_when(
    White == user ~ WhiteTitle,
    Black == user ~ BlackTitle
    ),
    opp_title = case_when(
      White != user ~ WhiteTitle,
      Black != user ~ BlackTitle
    )
  )
  return(df)
}

count_titles <- function(df){
  counts <- df %>%
    group_by(opp_title, opp_name) %>%
    count(opp_name) %>% 
    group_by(opp_title) %>%
    count(opp_title)
  counts <- counts[!(counts$opp_title %in% c("BOT",NA)),]
  colnames(counts) <- c("Title","# Players")
  return(counts)
}