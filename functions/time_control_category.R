time_control_category <- function(df){
  df$time_control_category <- NA
  df$time_control_category[df$TimeControl %in% c("1+0","45s","30s","2+1")] <- "bullet"
  df$time_control_category[df$TimeControl %in% c("3+0","3+2","5+0","5+3")] <- "blitz"
  df$time_control_category[df$TimeControl %in% c("10+0","15+10","10+5")] <- "rapid"
  return(df)
}