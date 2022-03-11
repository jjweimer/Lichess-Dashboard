determine_user_result <- function(df,user){
  #determine user result
  df$my_result <- "loss"
  df$my_result[df$winner == user] <- "win"
  df$my_result[df$winner == "Draw"] <- "draw"
  #factor to improve ordering later
  df$my_result <- factor(df$my_result,levels = c('loss','draw','win'))
  return(df)
}