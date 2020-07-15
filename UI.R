library(shiny)
library(dbplyr)
library(shinythemes)

ui <- fluidPage(theme = shinytheme("sandstone"),
  #Application title
  navbarPage("ClinEx v. beta",
    tabPanel("Analysis", #First Tab Panel
    sidebarLayout(
    sidebarPanel(
    selectInput("CancerID", "Cancer data to Analyse",
                  choices = project_id,
                  selected = NULL),
    selectInput("Variable", "Select Clinical Group",
                choices = c('gender','primary_diagnosis'),
                selected = NULL)
    ),
      mainPanel(
        plotOutput("Bars"),
        plotOutput("Survival")
    )
  )
),
  tabPanel("Home", #Second Tab Panel
           fluidRow(
             column(6,
                    includeMarkdown("README.md")
             )
           )
        )
      ),

      #Third Tab Panel
)



server <- function(input, output) {
  #Connect to the database
  sqlite <- dbDriver("SQLite")
  db <- src_sqlite("ClinicalDb.sqlite")
  
  cancer_table <- reactive(tbl(db, input$CancerID))

  cancer_data <- reactive(data.frame(
        cancer_table() %>%
          select(input$Variable, days_to_last_follow_up, days_to_death, vital_status) %>%
          collect 
      ))
  
  output$Bars <- renderPlot({
    dataset <- cancer_data()
    ggplot(data = dataset, aes(x = dataset[,1])) + 
      geom_bar(stat = "count", width = 0.5) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            axis.text.x = element_text(angle = 90))
  })
  
  output$Survival <- renderPlot({
      dataset <- cancer_data()
      TCGAanalyze_survival(dataset,
                          clusterCol=input$Variable,
                          risk.table = FALSE,
                          conf.int = FALSE,
                          )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)