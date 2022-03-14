#grab game data and save to RData
library(chessR)

#ping api
eldiel_prime <- get_raw_lichess("eldiel_prime")
magnus <- get_raw_lichess("DrDrunkenstein")
hikaru <- get_raw_lichess("TSMFTXH")
tang <- get_raw_lichess("C9C9C9C9C9")
rosen <- get_raw_lichess("EricRosen")
danya <- get_raw_lichess("RebeccaHarris")

setwd("C:/Users/jjwei/Desktop/data projects/Lichess-Dashboard/game_data")
save(eldiel_prime,magnus,hikaru,tang,rosen,danya, file = "games.RData")