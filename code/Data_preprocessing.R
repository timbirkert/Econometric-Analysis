### Food data pre processing


library(readxl)
library(dplyr)
library(tidyverse)
library(ggplot2)


# Datei einlesen 
excel_sheets("data/Essen daten EU (2000-2025).xlsx") # Checken welches sheet relevant ist -> "Blatt 1"
raw_food <- read_excel("data/Essen daten EU (2000-2025).xlsx", sheet = "Blatt 1")


# Nur Spalten behalten, bei denen zweite Zeile NICHT leer ist ( )
keep_cols <- which(raw_food[2,]!="")

# Diese Spalten behalten (inkl. aller Zeilen – also auch Zeile 1)
cleaned <- raw_food[, keep_cols]

# alle Spalten von character zu numeric konvertiere, sodass wir die daten ins longormat bringen können
  # dabei alle  kommas und text entfernen da sonst NAs entstehen 
cleaned <- cleaned %>%
  mutate(across(-1, ~ as.numeric(gsub(",", ".", gsub("[^0-9,.-]", "", .)))))




# Dataframe ins long format bringen
data_long <- cleaned %>%
  pivot_longer(
    cols = -TIME,                    #Erste Spalte behalten, alle anderen "schmelzen"
    names_to = "Datum",
    values_to = "Wert",
    values_drop_na = TRUE         # optional: NAs entfernen
  )

data_long <- data_long %>%
  rename(Country = TIME)

data_long$Wert <- as.numeric(data_long$Wert)

data_long <- data_long %>%
  mutate(Datum = as.Date(paste0(Datum, "-01")))

rm(list = setdiff(ls(), "data_long"))




