library(shiny)
library(chessR)
library(dplyr)
library(ggplot2)
library(ggridges)
library(plotly)
library(lubridate)
library(thematic)
library(tidyr)
library(zoo)

#source functions
source("functions/clean_openings.R")
source("functions/rename_time_controls.R")
source("functions/determine_my_elo.R")
source("functions/determine_user_result.R")
source("functions/time_control_category.R")
source("functions/gather_elo_data.R")
source("functions/dataprep_heatmap.R")
source("functions/determine_opp.R")

#source some pre saved games
load("game_data/games.Rdata")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #interactive themer
  #bslib::bs_themer()
  
  #easily blend theme with plots
  thematic::thematic_shiny()
  
  ## reactive text to username input
  get_username <- eventReactive(input$submit,{
      return(input$username)
    })
  observeEvent(input$submit,{
    output$username_text <- renderUI({
      string <- paste(get_username(), "game stats")
      return(tags$h3(string))
    })
  })
  
  #call api to get game data
  api_call <- eventReactive(input$submit,{
    if(input$username == "eldiel_prime"){
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
  game_data <- eventReactive(input$submit,{
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
    df <- time_control_category(df)
    #standardize opening names
    df$Opening <- clean_openings(df$Opening)
    #determine user elo ("my elo") and opp elo
    df <- determine_my_elo(df = df, user = input$username)
    #dtermine user result
    df <- determine_user_result(df, user = input$username)
    #opp username
    df <- determine_opp(df, user = input$username)

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
    
    #ggplot
    fig <- 
      opening_counts %>% 
        ggplot(aes(x = n, y = reorder(Opening,n))) +
        geom_col(stat = "identity", fill = "#296FC5" ) +
        ggtitle("Top Openings") +
        labs(x= "Number of Games", y= NULL) +
        theme(legend.position = NULL,
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(),
              text = element_text(family = font_google("Open Sans")))
    
    #custom tooling w/ ggplotly
    fig <- ggplotly(fig, tooltip = c("n")) %>% 
      config(displayModeBar = F) 
  
    return(fig)
  })
  
  #elo over time plot
  output$elo_over_time <- renderPlotly({
    df <- game_data()
    elo_data <- gather_elo_data(df)
    
    #now plot
    fig <- elo_data %>%
      ggplot(aes(x = Date)) 
      
    if(!is.null(elo_data$blitz) & FALSE %in% is.na(elo_data$blitz)){
      fig <- fig + geom_line(aes(y = blitz), color = "#3172B3")
    }  
    if(!is.null(elo_data$bullet) & FALSE %in% is.na(elo_data$bullet)){
      fig <- fig + geom_line(aes(y = bullet), color = "#6EB4EA") 
    }  
    if(!is.null(elo_data$rapid) & FALSE %in% is.na(elo_data$blitz)){
      fig <- fig + geom_line(aes(y = rapid), color = "#3E9E73") 
    }
    
    fig <- fig +  
      labs(x = NULL, y = "Elo") +
      theme(legend.position = NULL,
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            text = element_text(family = font_google("Open Sans")))
    #force compare on hover
    fig <- ggplotly(fig) %>% 
      config(displayModeBar = FALSE) %>%
      layout(hovermode = 'x')
    
    return(fig)
  })
  
  #squares heatmap
  
  output$heatmap <- renderPlotly({
    df <- game_data()
    grid <- dataprep_heatmap(df)
    
    #create heatmap
    fig2 <- ggplot(grid, aes(x = file, y = rank, fill = count)) +
      geom_tile(color = "#161512",
                lwd = 0.5,
                linetype = 1) +
      geom_text(aes(label = paste(file,rank, sep = '')), 
                color = "#C0BFBF", size = 2.5) +
      coord_fixed() +
      scale_fill_gradient(low = 'blue4',
                          high = 'red1') +
      guides(fill = guide_colourbar(barwidth = 0.5,
                                    barheight = 10)) +
      labs(x = NULL, y = NULL) +
      
      theme(legend.position = "None",
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            text = element_text(family = font_google("Open Sans")),
            axis.ticks = element_blank(), 
            axis.text = element_blank())
    #display as ggplotly object with no color scale on side
    return(hide_colorbar(ggplotly(fig2,tooltip = c("count"))) %>% 
             config(displayModeBar = FALSE))
    
  })
  
  #most freq opponents
  output$top_opps <- renderPlotly({
    df <- game_data()
    opp_counts <- df %>% group_by(opp_name) %>% count(opp_name) %>% arrange(-n)
    #keep top 10 opps
    opp_counts <- opp_counts[1:10,]

    #ggplot
    fig <- 
      opp_counts %>% 
      ggplot(aes(x = n, y = reorder(opp_name,n))) +
      geom_col(stat = "identity", fill = "#296FC5" ) +
      ggtitle("Top Oppponents") +
      labs(x= "Number of Games Played", y= NULL) +
      theme(legend.position = NULL,
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            text = element_text(family = font_google("Open Sans")))
    
    #custom tooling w/ ggplotly
    fig <- ggplotly(fig, tooltip = c("n")) %>% 
      config(displayModeBar = F) 
    
    return(fig)
  })
  
})
