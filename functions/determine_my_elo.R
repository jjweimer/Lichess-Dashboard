determine_my_elo <- function(df,user){
  df$my_elo <- NA
  df$opp_elo <- NA
  df$my_elo[df$White == user] <- df$WhiteElo[df$White == user]
  df$my_elo[df$Black == user] <- df$BlackElo[df$Black == user]
  df$opp_elo[df$White == user] <- df$BlackElo[df$White == user]
  df$opp_elo[df$Black == user] <- df$WhiteElo[df$Black == user]
  return(df)
}
