# IWN Hackathon 2025

library(readr)
library(dplyr)
library(shiny)
library(ggplot2)
library(DT)

meter_reads <- read_csv("clean_data/meter_reads.csv")
households  <- read_csv("clean_data/houshold_meta_data.csv")

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
        selected = c("Tegna", "Valencia"),
        choices = sort(unique(meter_reads$town))
      ),
      checkboxInput(
        "only_hh",
        "Only show meters with household metadata",
        value = FALSE
      ),
      # --- New: time filter ---
      dateRangeInput(
        "date_range", "Date range",
        start = min(as.Date(meter_reads$timestamp)),
        end   = max(as.Date(meter_reads$timestamp)),
        min   = min(as.Date(meter_reads$timestamp)),
        max   = max(as.Date(meter_reads$timestamp)),
        startview = "month"
      ),
      uiOutput("meter_select"),
      p("Data and code available on ",
        a("GitHub",
          href = "https://github.com/pprevos/IWN-hackathon-2025",
          target = "_blank"))
    ), # sidebarpanel
    mainPanel(
      tabsetPanel(
        tabPanel("Meter reads", plotOutput("linePlot")),
        tabPanel("Flows", plotOutput("flowPlot")),
        tabPanel("Household Info", DTOutput("householdTable"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Meter choices update whenever towns change; optional household filter
  output$meter_select <- renderUI({
    req(input$town)
    
    meters <- meter_reads %>%
      filter(town %in% input$town) %>%
      {
        if (isTRUE(input$only_hh)) {
          filter(., smart_meter_id %in% unique(households$smart_meter_id))
        } else .
      } %>%
      distinct(smart_meter_id) %>%
      pull(smart_meter_id) %>%
      sort()
    
    default_sel <- head(meters, 4)
    
    selectInput(
      "meter", "Select Smart Meter ID",
      choices  = meters,
      selected = default_sel,
      multiple = TRUE
    )
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
      facet_wrap(~ smart_meter_id, scales = "free_y") +
      labs(
        title = "Meter Reads",
        x = "Timestamp",
        y = "Reading"
      ) +
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
      facet_wrap(~ smart_meter_id, scales = "free_y") +
      labs(
        title = "Flow (units per hour)",
        x = "Timestamp",
        y = "Flow (units/hour)"
      ) +
      theme_minimal(base_size = 18)
  })
  
  # Household table (transposed) — filtered to selected meters; time filter not applied
  household_data <- reactive({
    req(input$meter)
    hh <- households %>%
      filter(smart_meter_id %in% input$meter)
    
    df <- as.data.frame(t(hh))
    colnames(df) <- paste("Household", seq_len(ncol(df)))
    tibble::rownames_to_column(df, "Attribute")
  })
  
  output$householdTable <- renderDT({
    datatable(household_data(),
              options = list(pageLength = 20, scrollX = TRUE))
  })
}

shinyApp(ui, server)
