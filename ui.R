library(shiny)
library(shinycssloaders)
library(dplyr)
library(bslib)
library(plotly)

#spinner options
options(spinner.type = 3,
        spinner.color.background  = "#161512")

shinyUI(fluidPage(

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
    titlePanel("lichess.org User Statistics"),
    
    fluidRow(column(3,
                    textInput("username","Enter Lichess Username", ""),
                    actionButton("submit","Go!")
                    ),
             column(5,
                    uiOutput("username_text"))
             ),
          
    
    fluidRow(
      column(4
        ),
      column(2,
        #args
        h3("More Filler"),
        textOutput("game_count") %>% withSpinner()
        ),
      column(6,
        #args
        plotlyOutput("opening_counts"),
        plotlyOutput("elo_over_time"),
        plotlyOutput("heatmap"),
        plotlyOutput("top_opps")
        )
    )
))
