library(shiny)
library(chessR)
library(dplyr)
library(ggplot2)
library(ggridges)
library(plotly)
library(lubridate)
library(thematic)

#source functions
source("functions/clean_openings.R")
source("functions/rename_time_controls.R")
source("functions/determine_my_elo.R")
source("functions/determine_user_result.R")
#source some pre saved games
load("game_data/games.Rdata")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #interactive themer
  #bslib::bs_themer()
  
  thematic::thematic_shiny()
  
  #test returning on actinobutton press 
  output$text <- eventReactive(input$submit,{
    return(input$username)
  })
  
  #call api to get game data
  api_call <- eventReactive(input$submit,{
    if(input$username == "Eldiel_Prime"){
      df <- eldiel_prime
    } else if (input$username == "DrDrunkenstein"){
      df <- magnus
    } else if (input$username == "TSMFTXH"){
      df <- hikaru
    } else{
      df <- get_raw_lichess(input$username)
    }
    return(df)
  })
  
  #clean data
  game_data <- reactive({
    df <- api_call()
    
    #helpers from ChessR
    df$num_moves <- return_num_moves(moves_string = df$Moves)
    df$winner <- get_winner(result_column = df$Result,
                            white = df$White,
                            black = df$Black)
    
    #change dates to date class
    df$Date <- ymd(df$Date)
    #day of week
    df$day_of_week <- wday(df$Date, label = TRUE)
    #rename time controls
    df$TimeControl <- rename_time_controls(df$TimeControl)
    #standardize opening names
    df$Opening <- clean_openings(df$Opening)
    #determine user elo ("my elo") and opp elo
    df <- determine_my_elo(df = df, user = input$username)
    #dtermine user result
    df <- determine_user_result(df, user = input$username)

    return(df)
  })
  
  #game count
  output$game_count <- eventReactive(input$submit,{
    df <- game_data()
    count <- nrow(df)
    return(paste("Games Played: ", count))
  })
  
  #opening counts plot
  output$opening_counts <- renderPlotly({
    df <- game_data()
    opening_counts <- df %>% group_by(Opening) %>%
      count(Opening) %>% arrange(-n)
    
    #filter to top 15 openings atm
    opening_counts <- opening_counts[1:15,]
    
    #plot
    fig <- ggplotly(
      opening_counts %>% 
        ggplot(aes(x = n, y = reorder(Opening,n))) +
        geom_col(stat = "identity", fill = "#296FC5" ) +
        ggtitle("Top Openings") +
        labs(x= "Number of Games", y= NULL) +
        theme(legend.position = NULL,
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(),
              text = element_text(family = font_google("Open Sans")))
    ) %>% config(displayModeBar = F)
    
    return(fig)
    
  })
  
})
