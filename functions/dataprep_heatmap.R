dataprep_heatmap <- function(df){
  #this is really slow for a lot of games because its triple nested loops
  #limit to first 2000 rows of data, most recent 2000 games
  if (nrow(df) > 2000){
    df <- df[1:2000,]
  }
  
  #split 'moves' into individual components
  moves<- suppressWarnings(gsub("\\{.*?\\}", "", df$Moves,
                                perl = TRUE) %>% strsplit(., "\\s+"))
  
  values <- c() #for storing counts
  files <- c("a","b","c","d","e","f","g","h")
  ranks <- c("1","2","3","4","5","6","7","8")
  file_list <- c() #for storing each iteration file
  rank_list <- c() #for storing each iteration rank
  
  #loop through each file,rank (to get a square)
  for(i in files){
    for(j in ranks){
      #we now have a selected square with coordinates i,j
      count_temp <- c()
      for(k in moves){
        temp <- k[grepl(paste(i,j,sep = ""),k,fixed = TRUE)]
        count_temp <- append(count_temp,temp)
      }
      count_temp <- length(count_temp)
      values <- append(values, count_temp) #store counts
      file_list <- append(file_list, i) #append file
      rank_list <- append(rank_list, j) #append rank
    }
  }
  
  #combine into dataframe
  grid <- data.frame(file = file_list,
                     rank = as.numeric(rank_list),
                     count = values)
  
  #need to add castling and queenside castling later lol
  return(grid)
}