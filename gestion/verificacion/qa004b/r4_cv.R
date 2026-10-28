suppressMessages(library(tidyverse))
t <- read_csv2("output/tablas/07_concentracion_sectores.csv", show_col_types = FALSE)
s <- t |> filter(Item_code != "S")
cat("check socios_eq = 10000/hhi, max dif:", max(abs(s$socios_equivalentes - 10000 / s$hhi_x10000)), "\n")
print(s |> group_by(medida, Reporter) |> summarise(cv = sd(hhi_x10000) / mean(hhi_x10000),
  cv_10anios = sd(hhi_x10000[anios == 10]) / mean(hhi_x10000[anios == 10]), n10 = sum(anios == 10), .groups = "drop"))
print(s |> filter(anios < 10) |> select(medida, Reporter, Item_code, anios, socios_equivalentes))
