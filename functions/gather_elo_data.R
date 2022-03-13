gather_elo_data <- function(df){
  elo_data <- df %>% group_by(time_control_category, Date) %>%
    slice_tail() %>% select(Date, time_control_category, my_elo) %>% 
    pivot_wider(names_from = time_control_category, values_from = my_elo)
  
  elo_data <- elo_data %>% arrange(elo_data$Date)
  
  if(!is.null(elo_data$blitz)){
    #ensure numeric
    elo_data$blitz <- as.numeric(elo_data$blitz)
    elo_data$blitz[(which(elo_data$blitz == 1500))] <- NA
    if(FALSE %in% is.na(elo_data$blitz)){
      elo_data$blitz[min(which(!is.na(elo_data$blitz))):length(elo_data$blitz)] <- na.locf(elo_data$blitz)
    }
  }
  if(!is.null(elo_data$bullet)){
    elo_data$bullet <- as.numeric(elo_data$bullet)
    elo_data$bullet[(which(elo_data$bullet == 1500))] <- NA
    if(FALSE %in% is.na(elo_data$bullet)){
      elo_data$bullet[min(which(!is.na(elo_data$bullet))):length(elo_data$bullet)] <- na.locf(elo_data$bullet)
    }
  }  
  if(!is.null(elo_data$rapid)){
    elo_data$rapid <- as.numeric(elo_data$rapid)
    #drop appearance of 1500 aka provisional rating
    elo_data$rapid[(which(elo_data$rapid == 1500))] <- NA
    if(FALSE %in% is.na(elo_data$rapid)){
      #handle missing data
      elo_data$rapid[min(which(!is.na(elo_data$rapid))):length(elo_data$rapid)] <- na.locf(elo_data$rapid)
    }
  }
  #drop first observation, as all elos will be NA
  elo_data <- elo_data[2:nrow(elo_data),]
  
  return(elo_data)
}