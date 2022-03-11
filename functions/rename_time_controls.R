rename_time_controls <- function(raw){
  raw[raw == '300+0'] <- '5+0'
  raw[raw == '600+0'] <- '10+0'
  raw[raw == '60+0'] <- '1+0'
  raw[raw == '180+2'] <- '3+2'
  raw[raw == '120+1'] <- '2+1'
  raw[raw == '180+0'] <- '3+0'
  raw[raw == "45+0"] <- "45s"
  raw[raw == "30+0"] <- "30s"
  return(raw)
}