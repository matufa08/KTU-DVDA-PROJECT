#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(h2o)
h2o.init()

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("DVDA projektas"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    
    sidebarPanel(
        fileInput("file", "Upload CSV file"),
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
      numericInput("years_current_job",
                   "Years in current job:",
                   min = 1,
                   max = 20,
                   step = 1,
                   value = 1),
      selectInput("loan_purpose", "Loan purpose:", c("debt_consolidation","other","home_improvements","business_loan","buy_a_car","medical_bills"),
                  "good"),
      selectInput("home_ownership", "Home ownership:", c("mortgage","rent", "own"),
                  "good"),
      selectInput("credit_score", "Credit score:", c("good","very_good", "fair"),
                  "good"),
      selectInput("term", "Loan term:", c("short","long"),
                  "good"),
      actionButton("calculate_button", "Calculate")
      ),
    
    mainPanel(
        dataTableOutput("fileTable"),
      tableOutput("inputTable"),
      tableOutput("predictionTable"),
      
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  model <- h2o.loadModel("./best_gbm_model_v1")
  
  input_data <- eventReactive(input$calculate_button, {
    data <- data.frame(
      amount_current_loan = input$amount_current_loan,
      yearly_income = input$yearly_income,
      bankruptcies = input$bankruptcies,
      monthly_debt = input$monthly_debt,
      years_credit_history = input$years_credit_history,
      months_since_last_delinquent = input$months_since_last_delinquent,
      open_accounts = input$open_accounts,
      credit_problems = input$credit_problems,
      credit_balance = input$credit_balance,
      max_open_credit = input$max_open_credit,
      years_current_job = input$years_current_job,
      loan_purpose = factor(input$loan_purpose),
      home_ownership = factor(input$home_ownership),
      credit_score = factor(input$credit_score),
      term = factor(input$term)
    )
    data.frame(
      column = names(data),
      value = unlist(data)
    )
  })
  
  output$inputTable <- renderTable({
    input_data()
  })
  
  prediction_data <- eventReactive(input$calculate_button, {
    
    inputData <- data.frame(
      amount_current_loan = input$amount_current_loan,
      yearly_income = input$yearly_income,
      bankruptcies = input$bankruptcies,
      monthly_debt = input$monthly_debt,
      years_credit_history = input$years_credit_history,
      months_since_last_delinquent = input$months_since_last_delinquent,
      open_accounts = input$open_accounts,
      credit_problems = input$credit_problems,
      credit_balance = input$credit_balance,
      max_open_credit = input$max_open_credit,
      years_current_job = input$years_current_job,
      loan_purpose = factor(input$loan_purpose),
      home_ownership = factor(input$home_ownership),
      credit_score = factor(input$credit_score),
      term = factor(input$term)
    )
    
    predictions <- h2o.predict(model, as.h2o(inputData))
    as.data.frame(predictions)
  })
  
  output$predictionTable <- renderTable({
    prediction_data()
  })
  
  output$fileTable <- renderDataTable({
    req(input$file)
    test_data <- h2o.importFile(input$file$datapath)
    predictions <- h2o.predict(model, test_data)
    predictions %>%
      as_tibble() %>%
      mutate(id = row_number(), y = p0) %>%
      select(id,y)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)