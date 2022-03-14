library(shiny)
library(shinycssloaders)
library(dplyr)
library(bslib)
library(plotly)

#spinner options
options(spinner.type = 3,
        spinner.color.background  = "#161512")

shinyUI(fixedPage(

    #custom theming
    theme = bslib::bs_theme(
      bg = '#161512', fg = "#C0BFBF",
      primary = "#A44812", #lichess orange
      secondary = "#296FC5", #lichess blue
      base_font = font_google("Open Sans"),
      
    ),
    #inline css styling for all body text
    #not sure why this works or how to apply it to button text yet
    tags$head(tags$style('body {color:#C0BFBF;}')),
    
    # Application title
    fluidRow(column(12,align = "left",
                    h2("lichess.org User Statistics")
                    ) 
             ),
    
    #top row
    fluidRow(column(4, align = "left",
                    textInput("username","Enter Lichess Username", "eldiel_prime", width = "100%"),
                    actionButton("submit","Go!", width = "100%" )
                    )
             ),
    tags$hr(),
    #tabs
    fluidRow(column(12, align = 'center',
                    tabsetPanel(type = "pills",
                                tabPanel("Rating",
                                         #Elo Row
                                         fluidRow(column(12,
                                                         tags$hr()),
                                                  column(4,
                                                         uiOutput("username_text"),
                                                         tags$hr(),
                                                         #bullet stats row
                                                         fluidRow(column(2,
                                                                         img(src = "bullet.png",height = 60, width = 60)
                                                                         ),
                                                                  column(10,
                                                                         uiOutput("bullet_elo")
                                                                         )
                                                                  ),
                                                         #blitz stats row
                                                         fluidRow(column(2,
                                                                         img(src = "blitz.png", height = 60, width = 60)
                                                                         ),
                                                                  column(10,
                                                                         uiOutput("blitz_elo")
                                                                         )
                                                                  ),
                                                         #rapid stats row
                                                         fluidRow(column(2,
                                                                         img(src = "rapid.png", height = 60, width = 60)
                                                                         ),
                                                                  column(10,
                                                                         uiOutput("rapid_elo")
                                                                         )
                                                                  ),
                                                        ), #end text rating stats
                                                  column(8,
                                                         plotlyOutput("elo_over_time") %>% withSpinner()
                                                         )
                                                  ), #end elo row
                                         #tags$hr(),
                                         ), #end rating panel
                                
                                #openings panel
                                tabPanel("Openings",
                                         #openings text
                                         fluidRow(
                                                  column(12,
                                                         tags$hr(),
                                                         uiOutput("opening_user_text")
                                                         )
                                                  ),
                                         #openings plots
                                         fluidRow(column(5,
                                                         plotlyOutput("opening_counts")
                                                         ),
                                                  column(7,
                                                         plotlyOutput("opening_scores")
                                                         )
                                                  ),
                                         #tags$hr(),
                                         ), #end openings panel
                                tabPanel("Heatmap",
                                         fluidRow(column(12,
                                                         plotlyOutput("heatmap"),
                                                         )
                                                  )
                                         ),
                                tabPanel("Other",
                                         
                                         fluidRow(
                                           column(4
                                           ),
                                           column(2,
                                                  #args
                                                  h3("More Filler"),
                                                  textOutput("game_count") 
                                           ),
                                           column(6,
                                                  #args
                                                  
                                                  plotlyOutput("top_opps"),
                                                  plotlyOutput("time_control_scores")
                                           )
                                         ))
                                ), class = "flex-center" #end tabset panel
                    ) #end column (12)
             ), #end fluidrow
    
    
    #random row
    
))
