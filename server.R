library(shiny)
library(chessR)
library(dplyr)
library(ggplot2)
library(ggridges)
library(plotly)
library(lubridate)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #test returning on actinobutton press 
  output$text <- eventReactive(input$submit,{
    return(input$username)
  })
  
  #call api to get game data
  api_call <- eventReactive(input$submit,{
    df <- get_raw_lichess(input$username)
    return(df)
  })
  
  #clean data
  game_data <- reactive({
    df <- api_call()
    df$num_moves <- return_num_moves(moves_string = df$Moves)
    df$winner <- get_winner(result_column = df$Result,
                            white = df$White,
                            black = df$Black)
    #change dates to date class
    df$Date <- ymd(df$Date)
    
    #day of week
    df$day_of_week <- wday(df$Date, label = TRUE)
    
    #rename time controls
    df$TimeControl[df$TimeControl == '300+0'] <- '5+0'
    df$TimeControl[df$TimeControl == '600+0'] <- '10+0'
    df$TimeControl[df$TimeControl == '60+0'] <- '1+0'
    df$TimeControl[df$TimeControl == '180+2'] <- '3+2'
    df$TimeControl[df$TimeControl == '120+1'] <- '2+1'
    df$TimeControl[df$TimeControl == '180+0'] <- '3+0'
    
    #determine user elo ("my elo") and opp elo
    df$my_elo <- NA
    df$opp_elo <- NA
    
    df$my_elo[df$White == input$username] <- df$WhiteElo[df$White == input$username]
    df$my_elo[df$Black == input$username] <- df$BlackElo[df$Black == input$username]
    df$opp_elo[df$White == input$username] <- df$BlackElo[df$White == input$username]
    df$opp_elo[df$Black == input$username] <- df$WhiteElo[df$Black == input$username]
    
    #determine user result
    df$my_result <- "loss"
    df$my_result[df$winner == input$username] <- "win"
    df$my_result[df$winner == "Draw"] <- "draw"
    #factor to improve ordering later
    df$my_result <- factor(df$my_result,levels = c('loss','draw','win'))
    
    return(df)
  })
  
  output$game_count <- reactive({
    df <- game_data()
    count <- nrow(df)
    return(paste("Games Played: ", count))
  })
  
})
