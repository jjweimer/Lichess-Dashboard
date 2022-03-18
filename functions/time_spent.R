library(tidyverse)
require(rvest) 
library(xml2)
#scrapes lichess site for total time spent in game
time_spent <- function(username){
  url <- paste("https://lichess.org/@/",username, sep = "")
  site <- session(url)
  stats <- site %>% html_element(".stats") %>% html_text(.)
  time_spent <- paste("Time",sub(".*Time *(.*?) *minutes.*", "\\1", stats), "minutes")
  return(time_spent)
}
