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
source("functions/order_time_controls.R")
source("functions/time_spent.R")

#source some pre saved games
load("game_data/games.Rdata")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #easily blend theme with plots
  thematic::thematic_shiny()
  
  ## reactive text to username input
  get_username <- eventReactive(input$submit,{
      return(input$username)
    })
  observeEvent(input$submit,{
    output$username_text <- renderUI({
      string <- paste(get_username(), "Rating")
      return(tags$h3(string, style = "color:#296FC5;
                                      text-align: center;")) #apply css styline to text inline
    })
  })
  
  #openings reactive text
  output$opening_user_text <- renderUI({
    string <- paste(get_username(), "Opening Stats")
    return(tags$h3(string, style = "color:#296FC5;
                                      text-align: center;")) #apply css styline to text inline
  })
  
  ##-------------- API and DATA -------------------------------------
  
  #call api to get game data
  api_call <- eventReactive(input$submit,{
    if(input$username == "eldiel_prime"){
      df <- eldiel_prime
    } else if (input$username == "DrDrunkenstein"){
      df <- magnus
    } else if (input$username == "TSMFTXH"){
      df <- hikaru
    } else if (input$username == "EricRosen"){
      df <- rosen
    } else if (input$username == "C9C9C9C9C9"){
      df <- tang
    } else if (input$username == "RebeccaHarris"){
      df <- danya
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
  
  # ------------ Text Stats --------------------------------
  
  #game count
  output$game_count <- eventReactive(input$submit,{
    df <- game_data()
    count <- nrow(df)
    return(paste("Games Played: ", count))
  })
  
  #elos of each rating category
  output$blitz_elo <- renderUI({
    df <- game_data()
    elo_data <- gather_elo_data(df)
    blitz_elo <- tail(elo_data$blitz, n = 1)
    if(is.null(blitz_elo)){
      return(tags$h3("Blitz Rating: ?"))
    } else if (is.na(blitz_elo)){
      return(tags$h3("Blitz Rating: ?"))
    } else{
      string <- paste("Blitz Rating:", blitz_elo)
      return(tags$h3(string))
    }
  })
  
  output$bullet_elo <- renderUI({
    df <- game_data()
    elo_data <- gather_elo_data(df)
    bullet_elo <- tail(elo_data$bullet, n = 1)
    if(is.null(bullet_elo)){
      return(tags$h3("Bullet Rating: ?"))
    } else if (is.na(bullet_elo)){
      return(tags$h3("Bullet Rating: ?"))
    } else{
      string <- paste("Bullet Rating:", bullet_elo)
      return(tags$h3(string))
    }
  })
  
  output$rapid_elo <- renderUI({
    df <- game_data()
    elo_data <- gather_elo_data(df)
    rapid_elo <- tail(elo_data$rapid, n = 1)
    if(is.null(rapid_elo)){
      return(tags$h3("Rapid Rating: ?"))
    } else if (is.na(rapid_elo)){
      return(tags$h3("Rapid Rating: ?"))
    } else{
      string <- paste("Rapid Rating:", rapid_elo)
      return(tags$h3(string))
    }
  })
  
  #time spent playing
  output$playtime <- renderUI({
    time <- time_spent(get_username())
    return(h4(time))
  })
  
  
 # ------------- PLOTS ----------------------------------------
  
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
        #ggtitle("Top Openings") +
        labs(x= "Number of Games", y= NULL) +
        scale_x_reverse() +
        theme(legend.position = NULL,
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(),
              panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              text = element_text(family = font_google("Open Sans")))
    
    #custom tooling w/ ggplotly
    fig <- ggplotly(fig, tooltip = c("n")) %>% 
      config(displayModeBar = F) 
  
    return(fig)
  })
  
  #opening win rates
  output$opening_scores <- renderPlotly({
    df <- game_data()
    df <- df %>% 
      group_by(Opening) %>%
      mutate(opening_count = n())
    ##find top 15 openings
    opening_counts <- df %>% group_by(Opening) %>%
      count(Opening) %>% arrange(-n)
    opening_counts <- opening_counts[1:15,]
    
    #plot
    fig <- df[df$Opening %in% opening_counts$Opening,] %>%
      group_by(Opening,my_result,opening_count) %>%
      count(Opening) %>%
      ggplot(aes(fill = my_result, y = n, x = reorder(Opening,opening_count)))+
      geom_bar(position = "fill",stat = "identity")+
      labs(x = NULL, y = "Win + Draw %", fill = "Result") +
      coord_flip() + 
      scale_fill_manual(values = c("#C0BFBF","#619824","#296FC5")) + #order is loss, draw, win (factor orderings)
      #ggtitle("Average Result") +
      theme(legend.position='none',
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            axis.text.y = element_text(hjust = 1),
            text = element_text(family = font_google("Open Sans")),
            
      )
    
    fig <- ggplotly(fig, tooltip = c("my_result","n")) %>% 
      config(displayModeBar = F) 
    #remove loss rates from visibility by directly editing object
    #i am actually a genius for figureing this one out
    #https://stackoverflow.com/questions/39625910/r-plotly-deselect-trace-by-default
    fig[["x"]][["data"]][[1]][["visible"]] <- "legendonly"
    
    return(fig)
  })
  
  #opening_ticks
  #deprecated
  output$opening_ticks <- renderPlotly({
    df <- game_data()
    opening_counts <- df %>% group_by(Opening) %>%
      count(Opening) %>% arrange(-n)
    #filter to top 15 openings atm
    opening_counts <- opening_counts[1:15,]
    opening_counts$rank <- 15:1
    
    names <- opening_counts %>%
      ggplot(aes(x = rank, y = reorder(Opening,n))) +
      geom_text(aes(y = 0, label = Opening, size = 3)) +
      coord_flip() +
      labs(x = NULL, y = NULL) +
      ggtitle("")
      theme(legend.position = 'none',
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            axis.text = element_blank()
            )
    
    names <- ggplotly(names)  %>% 
      config(displayModeBar = F) 
    
    return(names)
    
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
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
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
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            text = element_text(family = font_google("Open Sans")),
            axis.ticks = element_blank(), 
            axis.text = element_blank())
    #display as ggplotly object with no color scale on side
    return(hide_colorbar(ggplotly(fig2,tooltip = c("count"))) %>% 
             config(displayModeBar = FALSE) %>% layout(height = 800, width = 800))
    
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
  
  #results by time control
  output$time_control_scores <- renderPlotly({
    df <- game_data()
    df$TimeControl <- order_time_controls(df$TimeControl)
    df <- df[df$TimeControl %in% c("15s","30s", "45s", "1+0","2+0","2+1",
                                   '3+0','3+2','5+0','5+3',
                                   '10+0','10+5','15+10'),]
    
    fig <- df %>% 
      group_by(TimeControl, my_result) %>%
      count(TimeControl) %>%
      ggplot(aes(fill = my_result, y = n, x = TimeControl)) +
      geom_bar(position = "fill",stat = "identity")+
      #ggtitle("Performance by Time Control") +
      labs(y = "Win + Draw %", x = NULL, fill = "Result") +
      scale_fill_manual(values = c("#C0BFBF","#619824","#296FC5")) + #order is loss, draw, win (factor orderings)
      theme(legend.position = 'none',
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            text = element_text(family = font_google("Open Sans")),
            plot.title = element_text(hjust = 0.5)
      )
    
    fig <- ggplotly(fig, tooltip = c("my_result","n")) %>% 
      config(displayModeBar = F) 
    
    fig[["x"]][["data"]][[1]][["visible"]] <- "legendonly"
    
    return(fig)
      
  })
  
  output$move_count_result <- renderPlotly({
    df <- game_data()
    fig <- ggplot(df, aes(x = num_moves, fill = my_result))+
      geom_density(alpha = 0.8, color = '#161512') + 
      labs(x = "Number of Moves") +
      scale_x_continuous(limits = c(0,120)) +
      #ggtitle("Result by Move Count") +
      scale_fill_manual(values = c("#BB3231","#619824","#296FC5")) +
      theme(panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            legend.position = 'none',
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            text = element_text(family = font_google("Open Sans")),
            plot.title = element_text(hjust = 0.5),
            axis.ticks.y = element_blank(),
            axis.text.y = element_blank()
            )
    
    fig <- ggplotly(fig, tooltip = c("my_result", "num_moves")) %>% 
      config(displayModeBar = F) 
    
    return(fig)
  })
  
})
