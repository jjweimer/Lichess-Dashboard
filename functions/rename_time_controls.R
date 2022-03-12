rename_time_controls <- function(raw){
  #blitz
  raw[raw == '180+0'] <- '3+0'
  raw[raw == '180+2'] <- '3+2'
  raw[raw == '300+0'] <- '5+0'
  raw[raw == '300+3'] <- '5+3'
  #bullet
  raw[raw == "30+0"] <- "30s"
  raw[raw == "45+0"] <- "45s"
  raw[raw == '60+0'] <- '1+0'
  raw[raw == '120+1'] <- '2+1'
  #rapid
  raw[raw == '600+0'] <- '10+0'
  raw[raw == '600+5'] <- '10+5'
  raw[raw == '900+10'] <- '15+10'
  return(raw)
}