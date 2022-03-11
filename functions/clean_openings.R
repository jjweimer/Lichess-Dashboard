#opening name standardization
clean_openings <- function(raw_openings){
  #Needles
  opening_names <- c("Caro-Kann","Queen's Gambit","King's Indian",
                     "Nimzo-Indian Defense","Queen's Pawn Game",
                     "English Opening","Englund Gambit","French Defense",
                     "Sicilian Defense","Scandinavian Defense","Benoni Defense",
                     "Vienna Game","Semi-Slav","Slav Defense","Modern Defense",
                     "Dutch Defense","Budapest Defense")
  #replace raw with generalized names
  for(i in opening_names){
    #subset data frame and replace opening names with needle
    raw_openings[grepl(i,raw_openings,fixed = TRUE)] <- i
  }
  return(raw_openings)
}