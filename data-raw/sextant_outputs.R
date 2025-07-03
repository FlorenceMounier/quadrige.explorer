## code to prepare `sextant_outputs` dataset goes here

library(tidyverse)

#------------------------------------------------------------------------------
# Read raw datasets and combine them

# Import raw sextant output files
sextant_output_Gironde <- read_csv("../sextant-output-Gironde.csv")
sextant_output_Loire <- read_csv("../sextant-output-Loire.csv")
sextant_output_Seine <- read_csv("../sextant-output-Seine.csv")

# Join datasets
sextant_outputs <- sextant_output_Gironde |>
  full_join(sextant_output_Loire) |>
  full_join(sextant_output_Seine)

# Easily opening files in Excel program
write_csv2(sextant_outputs, "../sextant-output-readr-csv2.csv")

#------------------------------------------------------------------------------
# Data cleaning identified thanks to the exploration with the app

sextant_outputs <- sextant_outputs |>

  # Save RESULTAT results as a character value
  dplyr::mutate(RESULTAT_chr = RESULTAT) |>

  # Create a numerical variable for RESULTAT
  dplyr::mutate(RESULTAT = as.numeric(RESULTAT)) |>

  # Extract geographic position
  dplyr::mutate(
    longitude = PRELEVEMENT_COORDONNEES |> stringr::str_extract("longitude\\s\\-*[0-9]+\\.[0-9]+")  |> str_remove("longitude ") |>  as.numeric(),
    latitude = PRELEVEMENT_COORDONNEES |> stringr::str_extract("latitude(\\s)[0-9]+\\.[0-9]+") |> str_remove("latitude ") |>  as.numeric()
  ) |>

  ## Test regex
  # sextant_outputs |>
  # dplyr::mutate(
  #   longitude = PRELEVEMENT_COORDONNEES |> stringr::str_extract("longitude\\s\\-*[0-9]+\\.[0-9]+")  |> str_remove("longitude ") |>  as.numeric(),
  #   latitude = PRELEVEMENT_COORDONNEES |> stringr::str_extract("latitude(\\s)[0-9]+\\.[0-9]+") |> str_remove("latitude ") |>  as.numeric()
  # ) |>
  # distinct(LIEU_MNEMONIQUE, longitude, latitude, PRELEVEMENT_COORDONNEES) |>
  # # filter(is.na(longitude)) |>
  # View()

  # Transform variables as factors
  dplyr::mutate(ZONE_MARINE_QUADRIGE = as.factor(ZONE_MARINE_QUADRIGE)) |>
  dplyr::mutate(TAXON_LIBELLE = as.factor(TAXON_LIBELLE)) |>

  # Replace missing values by 0 for numerical RESULTAT
  dplyr::mutate(RESULTAT = replace(RESULTAT, is.na(RESULTAT), 0)) |>

  # Normalization of contaminant concentration units
  dplyr::mutate(
    RESULTAT = dplyr::case_when(UNITE == "pg.g-1, p.h." ~ RESULTAT / 1000, TRUE ~ RESULTAT),
    UNITE = dplyr::case_when(UNITE == "pg.g-1, p.h." ~ "ng.g-1, p.h.", TRUE ~ UNITE)
  ) |>

  # Simplify complex names of chemicals
  dplyr::mutate(
    PARAMETRE_LIBELLE = dplyr::case_when(
      ## Organochlorinated
      PARAMETRE_LIBELLE == "Alpha-HCH (Hexachlorocyclohexane)" ~ "Alpha-HCH",
      PARAMETRE_LIBELLE == "Lindane ou gamma-HCH (Hexachlorocyclohexane)" ~ "Gamma-HCH",
      PARAMETRE_LIBELLE == "Dichlorodiphényl trichloréthane pp'" ~ "p,p'-DDT",
      PARAMETRE_LIBELLE == "Dichlorodiphényl trichloréthane op'" ~ "o,p'-DDT",
      PARAMETRE_LIBELLE == "Dichlorodiphényl dichloroéthylène pp'" ~ "p,p'-DDE",
      PARAMETRE_LIBELLE == "Dichlorodiphényl dichloréthane pp'" ~ "p,p'-DDD",
      ## Perfluorinated
      PARAMETRE_LIBELLE == "Perfluorodecanoate" ~ "PFDA",
      PARAMETRE_LIBELLE == "Perfluorododecanoate" ~ "PFDoA",
      PARAMETRE_LIBELLE == "Perfluorooctane sulfonate" ~ "PFOS",
      PARAMETRE_LIBELLE == "Perfluorooctanoate" ~ "PFOA",
      PARAMETRE_LIBELLE == "Perfluoroundecanoate" ~ "PFUnA",
      TRUE ~ PARAMETRE_LIBELLE
    )) |>
  ## HBCDD
  dplyr::mutate(PARAMETRE_LIBELLE = PARAMETRE_LIBELLE |> str_replace("Alpha-Hexabromocyclododecane", "Alpha-HBCDD")) |>
  dplyr::mutate(PARAMETRE_LIBELLE = PARAMETRE_LIBELLE |> str_replace("Beta-Hexabromocyclododecane", "Beta-HBCDD")) |>
  dplyr::mutate(PARAMETRE_LIBELLE = PARAMETRE_LIBELLE |> str_replace("Gamma-Hexabromocyclododecane", "Gamma-HBCDD")) |>
  ## PCB
  dplyr::mutate(PARAMETRE_LIBELLE = stringr::str_remove_all(string = PARAMETRE_LIBELLE, pattern = "Congénère de P")) |>
  # PBDE
  dplyr::mutate(PARAMETRE_LIBELLE = PARAMETRE_LIBELLE  |>  str_replace("Polybromodiphényléther congénère", "PBDE")) |>
  dplyr::mutate(PARAMETRE_LIBELLE = PARAMETRE_LIBELLE |> str_replace("^Tétrabromodiphényl\\s+éther\\W+congénère\\W+[:alnum:]+\\W+", "PBDE 66")) |>
  dplyr::mutate(PARAMETRE_LIBELLE = PARAMETRE_LIBELLE |> str_replace("^pentabromodiphényl\\s+éther\\W+congénère\\W+[:alnum:]+\\W+", "PBDE 85"))

#------------------------------------------------------------------------------
# Save data sextant_outputs.rda

usethis::use_data(sextant_outputs, overwrite = TRUE)
