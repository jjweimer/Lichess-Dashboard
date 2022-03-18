order_time_controls <- function(raw_time_controls){
  ordered <- factor(raw_time_controls, 
                    levels = c("15s","30s", "45s", "1+0","2+0","2+1",
                               '3+0','3+2','5+0','5+3',
                               '10+0','10+5','15+10'))
  return(ordered)
}
