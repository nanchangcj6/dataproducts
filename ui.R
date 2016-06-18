# Course project for the Developing Data Products course in the Data Science 
# Specialisation offered by John Hopkins University through Coursera

# The topic I have chosen is an interactive exploratory analysis of earthquake data 
# from the Canterbury region in New Zealand in a Shiny app

# This app meets the following critiera: 

# Some form of input (widget: textbox, radio button, checkbox, ...)
# Some operation on the ui input in sever.R
# Some reactive output displayed as a result of server calculations
# You must also include enough documentation so that a novice user could use your application.
# The documentation should be at the Shiny website itself.

# Load required packages
library(shiny)  # Shiny itself
library(plotly) # to use plotly for the interactive charts

# ui.R - the Shiny user interface

# Standard layout with side navigation and tabbed main panel.  The 'analysis' 
# mainpanel tab is also tabbed itself.  The documentation is found in the 
# 'about' panel.

shinyUI(fluidPage(
  navbarPage(
    "Canterbury (NZ) Earthquake Analysis",
    tabPanel(
      "Analysis",
      sidebarPanel(
        helpText("Select a date range to examine Canterbury earthquake data"),
        
        # set slider range and default values
        
        sliderInput(
          "dates",
          "Date Range:",
          min = as.Date("2010-01-01"),
          max = as.Date("2016-05-30"),
          value = c(as.Date("2010-01-01"),
                    as.Date("2010-12-31")),
          step = 90,
          timeFormat = "%Y-%m"
        ),
        br(),
        
        # Check boxes - one conditional
        
        checkboxInput("mag", "Magnitude > 3.0 (recommended)",
                      value = TRUE),
        
        # conditional control only shows if a specific tab is active
        
        conditionalPanel(
          condition = "input.tabs == 'Predicting Earthquakes?'",
          helpText("Log scale gives best result"),
          checkboxInput("log", "Log scale? (recommended)",
                        value = TRUE)
        ),
        
        helpText("Select different views using the tabs on the right"),
        helpText("(Note you may experience some delay loading map data")
      ),
      
      mainPanel(
        tabsetPanel(
          id = "tabs",
          
          # four tabs in the 'analysis' main page
          
          tabPanel(
            "Frequency",
            h3("Earthquake Frequency"),
            p(
              "Prior to September 2010, earthquakes were a rare event in the
              Canterbury region.  This chart shows how the region's seismic
              stability has changed over time."
            ),
            p("Change the date range in the menu to see how this has since evolved."),
            
            # Shiny plot - intercative using ployly
            plotlyOutput("plot"),
            htmlOutput("freq_count"),
            p(
              "A previously unknown and dormant earthquake fault has become active
              and the region remains seismically active today."
            ),
            p(
              "Unselect the 'Magnitude > 3.0' box to see all seismic activity, although
              note that those less than 3.0 are generally considered to be below
              the threashold for being felt by people."
            ),
            p(
              "Hover over the graph to see date and magnitude (note: dates are in UCT)
              or use the plotly controls (visible when you hover over the plot) 
              to zoom in on more detail."
            )
            
            ),
          
          tabPanel(
            "Energy",
            h3("Earthquake Energy Release"),
            p(
              "One way to comprehend the destructive force of
              earthquakes is to convert from magnitude to a measure of energy."
            ),
            p(
              "To do this we use the Gutenberg / Richter energy-magnitude
              formula:"
            ),
            p("Energy(in Joules) = 10^(1.5*Magnitude + 4.8)"),
            p(
              "Another perhaps useful comparison is to convert this to the 'ton of TNT'.
              which is generally agreed to be equivalent to 4.184e9 Joules."
            ),
            p(
              "The table below shows the calculated monthly amount of energy released
              by the earthquakes in the selected date range."
            ),
            
            # Shiny tabular output
            dataTableOutput("table"),
            htmlOutput("energy_count"),
            p(
              "For comparison, the atomic bomb dropped on the city of Hiroshima
              in 1945 had a blast yeild equivalent to 1.50e04 tons of TNT"
            )
            ),
          
          tabPanel(
            "Find the Fault",
            h3("Finding the Fault Line"),
            p(
              "A previously unknown earthquake faultline existed.  Using the earthquake data
              overlaid on a map of Canterbury and then adding a smoothed trendline gives
              possible clue to its location."
            ),
            
            # This time an interactive map
            plotOutput("map"),
            htmlOutput("fault_count"),
            p(
              "To see how well this matches the expert assessment, look at the image of the
              Greendale Fault as plotted by GSN Science contained in the app documentation
              (on the 'about' tab above.)"
            )
            ),
          
          tabPanel(
            "Predicting Earthquakes?",
            h3("Can This Data Predict Future Earthquakes?"),
            p("The short answer is 'no'."),
            p(
              "However, there are a number of prediction methods being researched,
              some of which use 'seismicity patterns' as an indicator.
              Plotting magnitude against the frequency in a particular 
              region over time gives the 'seismicity rate' for that area.  This is 
              illustrated in the plot below for the Canterbury area."
            ),
            p(
              "Changing the date range shows how Canterbury's seismicity rate has
              changed since 2010."
            ),
            
            # Plot to describe magnitude-frequency relationship
            plotOutput("predict"),
            htmlOutput("pred_count"),
            p(
              "When the 'log scale' is selected, the resulting correlation is known 
              as the Gutenberg-Richter relationship, which describes the exponential 
              distribution of earthquake magnitudes - usually written as:"
            ),
            p("N = 10^(a - bM)"),
            p(
              "Where 'N' is the number of earthquakes with magnitude greater than
              or equal to 'M', 'a' and 'b' are the intercept and slope respectively,
              of the fitted trend line.  The 'b' value is the 'seismicity rate'
              for a particular area.  Over a long enough period, this can be
              thought of as the regions 'background' earthquake rate."
            ),
            p(
              "Uncheck the 'log scale' option to see a simple relationship of how often
              earthquakes of certain size happened."
            ),
            p(
              "For best results in both case, use magnitudes > 3.0, but for interest sake 
              see what happens when all earthquakes are selected."
            )
          )
        )
        )
        ),
    tabPanel("About",
             mainPanel(# Simply use a markdown file for the documentation
               includeMarkdown("about.md")))
        )
  ))