# IWN Hackathon 2025

library(readr)
library(dplyr)
library(shiny)
library(ggplot2)

meter_reads <- read_csv("clean_data/meter_reads.csv")
households  <- read_csv("clean_data/houshold_meta_data.csv")
appliances <- read_csv("clean_data/appliances.csv")

ui <- fluidPage(
  titlePanel("IWN Hackathon 2025"),
  h1("Smart Meter Data Viewer"),
  sidebarLayout(
    sidebarPanel(
      h3("Select Household(s)"),
      p("Select one or more towns and then one or more households to update the view."),
      selectInput(
        "town", "Town",
        multiple = TRUE,
        selected = sort(unique(meter_reads$town)),
        choices  = sort(unique(meter_reads$town))
      ),
      dateRangeInput(
        "date_range", "Date range",
        start = min(as.Date(meter_reads$timestamp)),
        end   = max(as.Date(meter_reads$timestamp)),
        min   = min(as.Date(meter_reads$timestamp)),
        max   = max(as.Date(meter_reads$timestamp)),
        startview = "month"
      ),
      uiOutput("meter_select"),
      checkboxInput(
        "only_hh",
        "Only show meters with household metadata",
        value = FALSE
      ),
      actionButton("pick4", "🎲 Pick six random meters"),
      p(),
      p("Data and code available on ",
        a("GitHub",
          href = "https://github.com/pprevos/IWN-hackathon-2025",
          target = "_blank"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Meter reads", plotOutput("linePlot", height = "70vh")),
        tabPanel("Flows",       plotOutput("flowPlot",  height = "70vh")),
        tabPanel("Household Info", tableOutput("householdTable")),
        tabPanel("Appliances", tableOutput("appliancesTable"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Centralised definition of currently available meters (Town + Only HH)
  meters_available <- reactive({
    req(input$town)
    meter_reads %>%
      filter(town %in% input$town) %>%
      { if (isTRUE(input$only_hh)) {
        filter(., smart_meter_id %in% unique(households$smart_meter_id))
      } else .
      } %>%
      distinct(smart_meter_id) %>%
      pull(smart_meter_id) %>%
      sort()
  })
  
  # Meter select UI, with safe default selection
  output$meter_select <- renderUI({
    meters <- meters_available()
    default_sel <- meters[seq_len(min(6, length(meters)))]
    selectInput(
      "meter", "Select Smart Meter ID",
      choices  = meters,
      selected = default_sel,
      multiple = TRUE
    )
  })
  
  # Button to pick random meters from the current set
  observeEvent(input$pick4, {
    meters <- meters_available()
    req(length(meters) > 0)
    n <- min(6, length(meters))
    updateSelectInput(session, "meter", selected = sample(meters, n))
    showNotification(sprintf("Selected %d random meter(s).", n),
                     type = "message", duration = 2)
  })
  
  # Base data (reads) for selected meters + date filter
  plot_data <- reactive({
    req(input$meter, input$date_range)
    meter_reads %>%
      filter(
        smart_meter_id %in% input$meter,
        as.Date(timestamp) >= as.Date(input$date_range[1]),
        as.Date(timestamp) <= as.Date(input$date_range[2])
      )
  })
  
  # Plot meter reads
  output$linePlot <- renderPlot({
    df <- plot_data()
    req(nrow(df) > 0)
    ggplot(df, aes(x = timestamp, y = meter_reading)) +
      geom_line() +
      facet_wrap(~ smart_meter_id, scales = "free_y", ncol = 2) +
      labs(title = "Meter Reads", x = "Timestamp", y = "Reading") +
      theme_minimal(base_size = 18)
  })
  
  # Compute flow (units per hour)
  flow_data <- reactive({
    req(input$meter, input$date_range)
    plot_data() %>%
      arrange(smart_meter_id, timestamp) %>%
      group_by(smart_meter_id) %>%
      mutate(
        dt_hours = as.numeric(difftime(timestamp, lag(timestamp), units = "hours")),
        d_read   = meter_reading - lag(meter_reading),
        flow     = d_read / dt_hours
      ) %>%
      mutate(flow = ifelse(is.finite(flow), flow, NA_real_)) %>%
      ungroup()
  })
  
  # Plot flow
  output$flowPlot <- renderPlot({
    df <- flow_data()
    req(nrow(df) > 0)
    ggplot(df, aes(x = timestamp, y = flow)) +
      geom_line(na.rm = TRUE) +
      facet_wrap(~ smart_meter_id, scales = "free_y", ncol = 2) +
      labs(title = "Flow (units per hour)", x = "Timestamp", y = "Flow (units/hour)") +
      theme_minimal(base_size = 18)
  })
  
  # Household table (transposed) — filtered to selected meters
  household_data <- reactive({
    req(input$meter)
    hh <- households %>% 
      filter(smart_meter_id %in% input$meter)
    df <- as.data.frame(t(hh))
    colnames(df) <- df[1, ]
    df <- tibble::rownames_to_column(df, "Attribute")
    df[-1, ]
  })
  
  output$householdTable <- renderTable(
    household_data(), 
    striped = TRUE)
  
  # Appliances
  appliance_data <- reactive({
    req(input$meter)
    app <- appliances %>% 
      filter(smart_meter_id %in% input$meter)
    pivot_wider(app, names_from = smart_meter_id, values_from = number,
                values_fn = sum)
  })
  
  output$appliancesTable <- renderTable(
    appliance_data(), 
    striped = TRUE)
}

shinyApp(ui, server)
