#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_exploration_raw_data_server("raw_data")
  mod_exploration_data_contamination_server("data_contamination")
}
