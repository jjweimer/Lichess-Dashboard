determine_opp <- function(df, user){
  df$opp_name <- NA
  df$opp_name[df$White != user] <- df$White[df$White != user]
  df$opp_name[df$Black != user] <- df$Black[df$Black != user]
  
  return(df)
}