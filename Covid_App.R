library(shiny)
library(tidyverse)

covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

state_name <- covid19 %>% 
  distinct(state) %>% 
  arrange(state) %>% 
  pull(state)

ui <- fluidPage("Covid Case Comparison",
                selectInput(inputId = "state",
                          label = "Enter State(s):",
                          choices = state_name,
                          multiple = TRUE),
                submitButton("Submit"),
                plotOutput(outputId = "timeplot"))
server <- function(input, output) {
  output$timeplot <- renderPlot(
  covid19 %>% 
    group_by(state) %>% 
    filter(cases>19) %>% 
    arrange(state, cases) %>%
    mutate(days_since_20 = date - min(date)) %>% 
    filter(state %in% input$state) %>% 
    ggplot(aes(x = days_since_20, y = cases)) +
    geom_line(aes(color = state)) +
    theme_minimal() +
    scale_y_log10() +
    theme(legend.title = "State") +
    labs(x = "Days Since 20 Cases", y = "Cumulative Case Count"))}
shinyApp(ui = ui, server = server)