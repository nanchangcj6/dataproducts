# server.R - The server end of the Shiny app

# See UI.R for the introduction

# Load required libraries
# Plotting
library(ggplot2)
library(ggmap)
library(plotly)

# Data cleaning and munging
library(dplyr)
library(lubridate)

# Required by includeMarkdown
library(markdown)

# The code before the ShinyServer function is only run once when the server oject
# is born

# Get data

# Check that we have a directory for this analysis
dir_name <- paste0(getwd(), "/data")

# if the directory doesn't exist, create it
if (!dir.exists(dir_name)) {
  dir.create(dir_name)
}
setwd(dir_name)
# name for faving our download
eq_data <- "earthquake.csv"

# If the dataset isn't present, download it
if (!file.exists(eq_data)) {

  # Load Data from GNS website based on parameters in the URL as follows
  URL_base_1 <-
    "http://wfs.geonet.org.nz/geonet/ows?service=WFS&version=1.0.0"
  URL_base_2 <-
    "&request=GetFeature&typeName=geonet:quake_search_v1&outputFormat=csv"
  URL_mag <- "&cql_filter=magnitude>0.0"
  URL_and <- "+AND+"
  URL_from <- "origintime>='2010-01-01'"
  URL_to <- "origintime<='2016-05-30'"
  URL_location <- "BBOX(origin_geom, 171, -42.5, 173, -44.5)"
  
  # and build the entire URL
  eq_nz_url <-
    paste0(
      URL_base_1,
      URL_base_2,
      URL_mag,
      URL_and,
      URL_from,
      URL_and,
      URL_to,
      URL_and,
      URL_location
    )
  # Download
  download.file(eq_nz_url,
                eq_data,
                mode = "wb")
}

# Read the dataset
eq_nz <- read.csv(eq_data)

# Data filtering and cleasning

# We only want type = earthquake (other things include quarry blasts, etc.)
eq_nz <- filter(eq_nz, eventtype == "earthquake")

# carry out rounding as per GNS recommendations
eq_nz$latitude <- round(eq_nz$latitude, 2)
eq_nz$longitude <- round(eq_nz$longitude, 2)
eq_nz$depth <- round(eq_nz$depth, 0)
eq_nz$magnitude <- round(eq_nz$magnitude, 1)

# Make dates pretty and create a month variable for energy by month calculation
eq_nz$origintime <- ymd_hms(eq_nz$origintime)
eq_nz$ym <- floor_date(eq_nz$origintime, "month")

# calculate energy releasein Joules from each earthquake
eq_nz$energy <- 10 ^ (1.5 * eq_nz$magnitude + 4.8)

# now create a single location variable for google (NB: not used in this version)
eq_nz$location <- paste(eq_nz$latitude, eq_nz$longitude, sep = ":")

# The server function is called depending on control interactions
shinyServer(function(input, output) {

  # has the magnitude checkbox been changed
  magInput <- reactive({
    if (!input$mag)
      return(0)
    return(3.0)
  })
  
  # has log scale checkbox changed
  logInput <- reactive({
    if (input$log) {
      return(TRUE)
    }
    else {
      return(FALSE)
    }
  })
  
  # filter data to match the date range sliders and magnitude checkbox
  get_data <-
    reactive({
      df_data <- filter(
        eq_nz,
        date(origintime) >= input$dates[1]
        & date(origintime) <= input$dates[2]
        & magnitude >= magInput()
      )
    })

  # This plot is done using plotly to get the interactive bits going
  output$plot <- renderPlotly({
    p_title <-
      paste0("Earthquakes Magnitude > ", magInput(), " in Canterbury")
    Date <- date(get_data()$origintime)
    Magnitude <- get_data()$magnitude
    p <- ggplot(get_data(), aes(x = Date, y = Magnitude))
    p <- p + geom_line(size = 0.4,
                    alpha = 0.4,
                    color = 'red')
    p <- p + ggtitle(p_title)
    p <- p + ylab("Magnitude")
    p <- p + xlab("Date")
    p <- ggplotly(p)
    print(p)
  })
  # These render UI functions display record counts on eaach tab
  output$freq_count <- renderUI({
    n <- format(count(get_data()),
                big.mark = ",",
                scientific = FALSE)
    HTML(paste0(n, " Earthquake records read.<br/><br/>"))
  })
  
  output$fault_count <- renderUI({
    n <- format(count(get_data()),
                big.mark = ",",
                scientific = FALSE)
    HTML(paste0(n, " Earthquake records read.<br/><br/>"))
  })
  output$pred_count <- renderUI({
    n <- format(count(get_data()),
                big.mark = ",",
                scientific = FALSE)
    HTML(paste0(n, " Earthquake records read.<br/><br/>"))
  })
  
  output$energy_count <- renderUI({
    n <- format(count(get_data()),
                big.mark = ",",
                scientific = FALSE)
    HTML(paste0(n, " Earthquake records read.<br/><br/>"))
  })
  
  # Energy relase calculation in a data table
  output$table <- renderDataTable({
    df_month <- aggregate(get_data()$energy ~ get_data()$ym,
                          data = eq_nz,
                          sum)
    #Add readible column names and make data prettier
    colnames(df_month) <- c("Month", "Energy(Joules)")
    df_month$Month <- format(df_month$Month, "%b-%Y")
    # Add comparison to a ton of TNT
    df_month$TNT <- df_month$Energy / 4184000000
    colnames(df_month) <- c("Month", "Energy (Joules)", "Tons of TNT")
    
    df_month
  })
  
  # map the earthquakes to show the fault line
  output$map <- renderPlot({
    if (!exists("g_map")) {
      # Prepare the map from google
      # get_googlemap is saved as a global scope variable to improve performance
      g_map <<- get_googlemap(
        center = "Christchurch",
        size = c(300, 300),
        zoom = 8,
        scale = 2,
        maptype = 'terrain',
        style = c(
          feature = "administrative.province",
          element = "labels",
          visibility = "off"
        )
      )
    }
    
    p_title <-
      paste0("Earthquakes Mag > ", magInput(), " in Canterbury")
    
    p <- ggmap(g_map, extent = 'panel') +
      geom_point(
        data = get_data(),
        aes(x = longitude, y = latitude),
        alpha = 0.2,
        shape = 4,
        color = 'red'
      ) +
      geom_smooth(
        data = get_data(),
        aes(x = longitude, y = latitude),
        color = 'black',
        size = 1
      )
    
    print(p)
  })
  
  # plot frequency magnitude to demonstrate log relationship
  output$predict <- renderPlot({
    p_title <-
      paste0("Earthquakes Magnitude > ", magInput(), " in Canterbury")
    p_ylab <- "Freqency"
    x <- count(get_data(), magnitude)
    
    p <- ggplot(x, aes(magnitude, n)) +
      geom_point(size = 2)
    # Check are we producing a log scale or not (checkbox option)
    if (logInput()) {
      p <- p + scale_y_log10()
      p_ylab <- "Freqency (Log)"
      
    }
    p <- p + geom_smooth(aes(group = 1)) +
      ggtitle(p_title) +
      ylab (p_ylab)
    
    print(p)
  })

  # download the filtered dataset to the user's computer as a csv file
  output$dl_data <- downloadHandler(
    filename = "quake.csv",
    content = function(con) {
      write.csv(get_data(), con, row.names = FALSE)
    }
  )
    
})