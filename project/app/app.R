#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("DVDA projektas"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      numericInput("amount_current_loan",
                   "Current loan amount:",
                   min = 0,
                   max = 2000000,
                   step = 500,
                   value = 0),
      numericInput("yearly_income",
                  "Yearly income:",
                  min = 0,
                  max = 2000000,
                  step = 500,
                  value = 0),
      numericInput("bankruptcies",
                   "Bankruptcies:",
                   min = 0,
                   max = 10,
                   step = 1,
                   value = 0),
      numericInput("monthly_debt",
                   "Monthly debt:",
                   min = 0,
                   max = 1000000,
                   step = 500,
                   value = 0),
      numericInput("years_credit_history",
                   "Years of credit history:",
                   min = 0,
                   max = 100,
                   step = 1,
                   value = 0),
      numericInput("months_since_last_delinquent",
                   "Months since last delinquet:",
                   min = 0,
                   max = 500,
                   step = 1,
                   value = 0),
      numericInput("open_accounts",
                   "Open accounts:",
                   min = 0,
                   max = 100,
                   step = 1,
                   value = 0),
      numericInput("credit_problems",
                   "Credit problems:",
                   min = 0,
                   max = 50,
                   step = 1,
                   value = 0),
      numericInput("credit_balance",
                   "Credit balance:",
                   min = 0,
                   max = 50000000,
                   step = 1000,
                   value = 0),
      numericInput("max_open_credit",
                   "Max open credit:",
                   min = 0,
                   max = 50000000,
                   step = 1000,
                   value = 0),
      selectInput("term", "Loan term:", c("debt_consolidation","other","home_improvements","business_loan","buy_a_car","medical_bills"),
                  "good"),
      selectInput("credit_score", "Credit score:", c("mortgage","rent", "own"),
                  "good"),
      selectInput("credit_score", "Credit score:", c("good","very_good", "fair"),
                  "good"),
      selectInput("term", "Loan term:", c("short","long"),
                  "good"),
      actionButton("calculate_button", "Calculate button")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tableOutput("inputTable"),
      #verbatimTextOutput("inputTable")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  input_data <- eventReactive(input$calculate_button, {
    data <- as.list(input)
    data.frame(
      column = names(data),
      value = unlist(data)
    )
  })
  
  output$inputTable <- renderTable({
      input_data()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)