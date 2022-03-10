library(shiny)
library(shinycssloaders)
library(dplyr)

#spinner options
options(spinner.type = 3,
        spinner.color.background  = "#ffffff")

shinyUI(fluidPage(

    # Application title
    titlePanel("Lichess Dashboard"),
    
    fluidRow(
      column(3,
        #args
        textInput("username","Enter Lichess Username", ""),
        actionButton("submit","Go!"),
        textOutput("text")
      ),
      column(9,
             #args
             h3("More Filler"),
             textOutput("game_count") %>% withSpinner()
      )
    )
))
