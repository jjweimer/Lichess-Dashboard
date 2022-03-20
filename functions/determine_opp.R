determine_opp <- function(df, username){
  df <- df %>% mutate(
    opp_name = case_when(
      White == username ~ Black,
      Black == username ~ White
    )
  )
  return(df)
}