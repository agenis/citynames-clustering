# PACKAGES
library(shiny)
library(dplyr)
library(stringdist)
library(cluster)
library(rgdal)
if (FALSE){
  library(sp)
  library(rgeos)
}

pageWithSidebar(
  headerPanel('Find city names related to your city'),
  sidebarPanel(
    selectInput('mycity_raw', 'Choose a city from the list', com$nom_brut),
    selectInput('mymetric', 'Choose a distance metric', c("4gram", "3gram", "Levenshtein", "mixed"), selected="mixed"),
    sliderInput("maxnum", "maximum number of cities in the output", 10, 250, value=100)
  ),
  mainPanel(
    plotOutput('map', height="600px"),
    hr(),
    tableOutput('top50')
  )
)