#' exploration_raw_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

mod_exploration_raw_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        uiOutput(ns("theme_ui")),
        uiOutput(ns("parametre_groupe_ui")),
        uiOutput(ns("parametre_ui")),
        uiOutput(ns("programme_ui")),
        uiOutput(ns("taxon_ui"))
      ),
      mainPanel(
        shinyjs::useShinyjs(),  # Permet d'utiliser les fonctionnalités de shinyjs pour ajuster la taille des plot à la page dynamiquement
        tags$div(
          id = "conditional_plot-container",  # Conteneur pour le graphique
          style = "width: 100%; height: 100%;",
          plotly::plotlyOutput(ns("conditional_plot"), height = "100%")  # On laisse la hauteur à 100% ici
        )
      )
    )
  )
}

#' exploration_raw_data Server Functions
#'
#' @noRd
mod_exploration_raw_data_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # ----------------------------------------------------------------------
    # Load data

    data <- quadrige.explorer::sextant_outputs

    # ----------------------------------------------------------------------
    # UI dynamique - Sélection d'un THEME
    output$theme_ui <- renderUI({
      selectInput(ns("theme"), "Thème :", choices = unique(data$THEME), selected = unique(data$THEME)[1])
    })

    # ----------------------------------------------------------------------
    # UI dynamique - Sélection d'un PARAMETRE_GROUPE
    output$parametre_groupe_ui <- renderUI({
      req(input$theme)  # attend que l'utilisateur ait choisi un thème

      params_grp_disponibles <- data |>
        dplyr::filter(THEME == input$theme) |>
        dplyr::pull(PARAMETRE_GROUPE) |>
        unique() |>
        sort()

      selectInput(ns("parametre_groupe"), "Groupe de paramètres :", choices = params_grp_disponibles, selected = params_grp_disponibles[1])
    })

    # ----------------------------------------------------------------------
    # UI dynamique - Sélection d'un PARAMETRE
    output$parametre_ui <- renderUI({
      req(input$theme, input$parametre_groupe)  # attend que l'utilisateur ait choisi un thème et un groupe de paramètres

      params_disponibles <- data |>
        dplyr::filter(THEME == input$theme, PARAMETRE_GROUPE == input$parametre_groupe) |>
        dplyr::pull(PARAMETRE_LIBELLE) |>
        unique() |>
        sort()

      selectInput(ns("parametre"), "Paramètre :", choices = params_disponibles, selected = params_disponibles[1])
    })

    # ----------------------------------------------------------------------
    # UI dynamique - Affichage du programme
    output$programme_affiche <- renderText({
      req(filtered_data())

      programmes <- unique(filtered_data()$PROGRAMME)

      if (length(programmes) == 0) {
        return("Aucun programme associé.")
      } else {
        paste("Programme(s) associé(s) :", paste(programmes, collapse = ", "))
      }
    })

    # UI dynamique - Filtre sur PROGRAMME
    output$programme_ui <- renderUI({
      req(input$theme, input$parametre, input$parametre_groupe)

      programmes_disponibles <- data |>
        dplyr::filter(
          THEME == input$theme,
          PARAMETRE_GROUPE == input$parametre_groupe,
          PARAMETRE_LIBELLE == input$parametre
        ) |>
        dplyr::pull(PROGRAMME) |>
        unique() |>
        sort()

      selectInput(
        ns("programme"), "Programme :",
        choices = programmes_disponibles,
        selected = programmes_disponibles[1],
        multiple = TRUE  # on autorise la sélection multiple
      )
    })

    # ----------------------------------------------------------------------
    # UI dynamique - Filtre sur TAXON_LIBELLE
    output$taxon_ui <- renderUI({
      req(input$theme, input$parametre, input$parametre_groupe, input$programme)

      taxons_disponibles <- data |>
        dplyr::filter(
          THEME == input$theme,
          PARAMETRE_GROUPE == input$parametre_groupe,
          PARAMETRE_LIBELLE == input$parametre,
          PROGRAMME == input$programme
        ) |>
        dplyr::pull(TAXON_LIBELLE) |>
        unique() |>
        sort()

      selectInput(
        ns("taxon"), "Taxon :",
        choices = taxons_disponibles,
        selected = taxons_disponibles[1],
        multiple = TRUE  # multiple selection
      )
    })

    # Données filtrées pour time plot
    filtered_data <- reactive({
      data |>
        dplyr::filter(
          THEME == input$theme,
          PARAMETRE_GROUPE == input$parametre_groupe,
          PARAMETRE_LIBELLE == input$parametre,
          PROGRAMME %in% input$programme
        )
    })


    # Données filtrées pour species plot
    filtered_data_taxon <- reactive({
      data |>
        dplyr::filter(
          THEME == input$theme,
          PARAMETRE_GROUPE == input$parametre_groupe,
          PARAMETRE_LIBELLE == input$parametre,
          PROGRAMME %in% input$programme,
          TAXON_LIBELLE %in% input$taxon
        ) |>
        dplyr::mutate(YEAR = year(DATE)) |>
        dplyr::group_by(YEAR, TAXON_LIBELLE) |>
        dplyr::summarise(mean_RESULTAT = mean(RESULTAT))
    })

    # Graphique conditionnel abscence/présence valeur taxon
    output$conditional_plot <- plotly::renderPlotly({
      req(nrow(filtered_data()) > 0)

      if (is.null(input$taxon) || length(input$taxon) == 0) {
        # Pas de taxon sélectionné → graphique général
        p <- ggplot2::ggplot(filtered_data(), ggplot2::aes(x = DATE, y = RESULTAT, color = PROGRAMME)) +
          ggplot2::geom_line() +
          ggplot2::labs(title = paste("Série temporelle", input$parametre), x = "Date", y = "Résultat", color = "Programme(s)") +
          ggplot2::theme_minimal()
      } else {
        # Taxon sélectionné → graphique par espèce
        p <- ggplot2::ggplot(filtered_data_taxon(), ggplot2::aes(x = YEAR, y = mean_RESULTAT, fill = TAXON_LIBELLE)) +
          ggplot2::geom_col() +
          ggplot2::labs(title = paste("Série temporelle (par taxon) :", input$parametre), x = "Année", y = "Somme résultat", fill = "Taxon") +
          ggplot2::facet_grid(dplyr::vars(TAXON_LIBELLE), scales = "free_y") +
          ggplot2::theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
          ggplot2::theme_minimal()
      }

      plotly::ggplotly(p)
    })

    # Utilisation de shinyjs pour ajuster dynamiquement la hauteur du graphique
    observe({
      # Ajuste la hauteur du graphique en fonction de la taille de la fenêtre
      shinyjs::runjs('
      var windowHeight = $(window).height();  // Hauteur de la fenêtre
      var plotHeight = windowHeight - $("#plot-container").offset().top;  // Hauteur restante après le plot-container
      $("#plot-container").height(plotHeight);  // Ajuster la hauteur du conteneur
    ')
    })

  })
}

## To be copied in the UI
# mod_exploration_raw_data_ui("exploration_raw_data")

## To be copied in the server
# mod_exploration_raw_data_server("exploration_raw_data")
