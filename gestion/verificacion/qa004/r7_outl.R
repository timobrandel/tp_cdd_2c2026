suppressMessages(library(tidyverse))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
det <- read_csv2("output/tablas/06_atipicos_mundo_detalle.csv", show_col_types = FALSE)
x <- mun |> filter(Year >= 2015) |> semi_join(det, by = c("Reporter", "Item_code")) |>
  group_by(Reporter, Item_code) |>
  summarise(codigos = paste(names(table(Final_value_methodology)), table(Final_value_methodology), sep = ":", collapse = " "),
            anios_cero = sum(Final_value == 0), media = mean(Final_value), .groups = "drop")
print(x, n = 30, width = 200)
