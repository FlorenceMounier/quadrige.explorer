#' exploration_data_contamination UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_exploration_data_contamination_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        uiOutput(ns("parametre_ui")),
        uiOutput(ns("zone_marine_ui"))
      ),
      mainPanel(
        shinyjs::useShinyjs(),  # Permet d'utiliser les fonctionnalités de shinyjs pour ajuster la taille des plot à la page dynamiquement
        tags$div(
          id = "plot-container",  # plot container
          style = "width: 100%; height: 100%;",
          plotly::plotlyOutput(ns("plot"), height = "100%")  # keep height at 100% here
        )
      )
    )
  )
}

#' exploration_data_contamination Server Functions
#'
#' @noRd
mod_exploration_data_contamination_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # ----------------------------------------------------------------------
    # Load data

    data <- quadrige.explorer::data_contamination |>
      dplyr::mutate(YEAR = year(DATE))

    # ----------------------------------------------------------------------
    # UI dynamic - PARAMETRE_LIBELLE
    output$parametre_ui <- renderUI({
      selectInput(ns("parametre"), "Parameter:",
                  choices = unique(data$PARAMETRE_LIBELLE),
                  selected = unique(data$PARAMETRE_LIBELLE)[1])
    })


    # ----------------------------------------------------------------------
    # UI dynamic - ZONE_MARINE_QUADRIGE
    output$zone_marine_ui <- renderUI({
      req(input$parametre)  # wait for user "Parameter" selection

      zone_marine_disponibles <- data |>
        dplyr::filter(PARAMETRE_LIBELLE == input$parametre) |>
        dplyr::pull(ZONE_MARINE_QUADRIGE) |>
        unique() |>
        sort()

      selectInput(ns("zone_marine"), "Quadrige marine zone:",
                  choices = zone_marine_disponibles,
                  selected = zone_marine_disponibles[1],
                  multiple = TRUE)
    })

    # ----------------------------------------------------------------------
    # Filtered data for time plot
    filtered_data <- reactive({
      data |>
        dplyr::filter(
          PARAMETRE_LIBELLE == input$parametre,
          ZONE_MARINE_QUADRIGE %in% input$zone_marine
        )
    })

    # ----------------------------------------------------------------------
    # Plot output

    output$plot <- plotly::renderPlotly({

      # req(nrow(filtered_data()) > 0)

      p <- ggplot2::ggplot(filtered_data(), ggplot2::aes(x = YEAR, y = RESULTAT, color = PROGRAMME)) +
        ggplot2::geom_line() +
        ggplot2::labs(title = paste("Time series", input$parametre), x = "Date", y = "Result", color = "Program") +
        ggplot2::facet_grid(rows = vars(ZONE_MARINE_QUADRIGE)) +
        ggplot2::theme_minimal()

      plotly::ggplotly(p)
    })

    # ----------------------------------------------------------------------
    # Use of shinyjs to dynamically adjust the height of the graph
    observe({
      # Adjusts the height of the graph to the size of the window
      shinyjs::runjs('
      var windowHeight = $(window).height();  // Window height
      var plotHeight = windowHeight - $("#plot-container").offset().top;  // Remaining height after the plot-container
      $("#plot-container").height(plotHeight);  // Adjusting the height of the container
    ')
    })

  })
}

## To be copied in the UI
# mod_exploration_data_contamination_ui("exploration_data_contamination_1")

## To be copied in the server
# mod_exploration_data_contamination_server("exploration_data_contamination_1")
