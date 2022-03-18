library(shiny)
library(shinycssloaders)
library(dplyr)
library(bslib)
library(plotly)

#spinner options
options(spinner.type = 3,
        spinner.color.background  = "#161512")

shinyUI(fixedPage(

 ## --------- THEMING ------------------------------              
  #load custom css from file
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "/css/style.css")
  ),
  #inline css styling for all body text
  #not sure why this works or how to apply it to button text yet
  tags$head(tags$style('body {color:#C0BFBF;}')),
    #custom theming
    theme = bslib::bs_theme(
      bg = '#161512', fg = "#C0BFBF",
      primary = "#619824", #lichess green
      secondary = "#296FC5", #lichess blue
      base_font = font_google("Open Sans"),
    ),
  #header
  fluidRow(
    column(
      12,
      align = "center",
      h2("lichess.org User Statistics")
      ) 
    ),
  
  #top row
  fluidRow(
    column(
      4,
      offset = 4,
      align = "center",
      textInput("username","Enter Lichess Username", "eldiel_prime", width = "100%"),
      actionButton("submit","Go!", width = "100%"),
      ),
    column(
      4,
      align = "bottom",
      img(src = "images/logo.png", height = 135, width = 135)
    ),
  ),
    
 tags$hr(),
    
 #tabs
 fluidRow(
   column(
     12, 
     align = 'center',
     tabsetPanel(type = "pills",
                 tabPanel("Performance",
                          #Elo Row
                          fluidRow(
                            column(
                              12,
                              tags$hr()
                              ),
                            column(
                              4,
                              uiOutput("username_text"),
                              #tags$hr(),
                              tags$br(),
                              #bullet stats row
                              fluidRow(
                                column(
                                  2,
                                  img(src = "images/bullet_transparent.png",height = 60, width = 60)
                                  ),
                                column(
                                  10,
                                  uiOutput("bullet_elo")
                                  )
                                ),
                              #blitz stats row
                              fluidRow(
                                column(
                                  2,
                                  img(src = "images/blitz_transparent.png", height = 60, width = 60)
                                  ),
                                column(
                                  10,
                                  uiOutput("blitz_elo")
                                  )
                                ),
                              #rapid stats row
                              fluidRow(
                                column(
                                  2,
                                  img(src = "images/rapid_transparent.png", height = 60, width = 60)
                                  ),
                                column(
                                  10,
                                  uiOutput("rapid_elo")
                                  )
                                ),
                              ), #end text rating stats
                            column(
                              8,
                              plotlyOutput("elo_over_time") %>% withSpinner()
                              )
                            ), #end elo row
                          tags$hr(),
                          #tags$br(),
                          fluidRow(
                            column(
                              6,
                              plotlyOutput("time_control_scores")
                            ),
                            column(
                              6,
                              plotlyOutput("move_count_result")
                            )
                          )
                          #tags$hr(),
                          ), #end rating panel
                 #openings panel
                 tabPanel("Openings",
                          #openings text
                          fluidRow(
                            column(
                              12,
                              tags$hr(),
                              uiOutput("opening_user_text")
                              )
                            ),
                          #openings plots
                          fluidRow(
                            column(
                              5,
                              plotlyOutput("opening_counts")
                              ),
                            column(
                              7,
                              plotlyOutput("opening_scores")
                              )
                            ),
                          #tags$hr(),
                          ), #end openings panel
                 tabPanel("Heatmap",
                          fluidRow(
                            column(
                              12,
                              tags$hr(),
                              plotlyOutput("heatmap") %>% withSpinner(),
                              )
                            )
                          ),
                 tabPanel("Social",
                          fluidRow(
                            column(
                              12,
                              tags$hr()
                              )
                            ),
                          fluidRow(
                            column(
                              2,
                              #args
                              h3("More Filler"),
                              textOutput("game_count") %>% withSpinner()
                              ),
                            column(
                              6,
                              plotlyOutput("top_opps"),
                              
                              )
                            )
                          )#ned other panel
                 )#end tabset panel
     ) #end column (12)
   ), #end fluidrow
))
