suppressMessages(library(tidyverse))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
sect <- c("SA","SB","SC","SD","SE","SF","SG","SH","SI","SJ","SK","SL")
b <- mun |> filter(Item_code %in% sect, Year >= 2015, Year <= 2024)
pres <- b |> distinct(Reporter, Year) |> count(Reporter) |> filter(n == 10) |> pull(Reporter)
b <- b |> filter(Reporter %in% pres)
cel <- b |> group_by(Reporter, Item_code) |>
  summarise(v = mean(Final_value), anios_R = sum(str_starts(Final_value_methodology, "R_")),
            anios_E0 = sum(Final_value_methodology == "E0"), anios_E3 = sum(Final_value_methodology == "E3"),
            rep_na = sum(is.na(Reported_value)), .groups = "drop")
z <- cel |> filter(v == 0)
cat("celdas cero:", nrow(z), "\n")
z <- z |> mutate(tipo = case_when(anios_R == 10 ~ "cero informado los 10 anios",
                                  anios_R == 0 & anios_E0 == 0 ~ "ningun anio informado, sin E0 (E3/E2/E5...)",
                                  anios_R == 0 ~ "ningun anio informado, con E0",
                                  TRUE ~ "mixto (algunos anios informados)"))
print(count(z, tipo))
cat("Reported_value NA en las celdas cero (anio-celda):", sum(z$rep_na), " de ", 10*nrow(z), "\n")
print(z |> filter(Reporter %in% c("AR","BR","CL","UY")))
# Peso del dato no informado en la base del ANOVA (anio-celda)
cat("% anio-celdas con codigo no R_ en la base ANOVA:", round(100*mean(!str_starts(b$Final_value_methodology, "R_")),1), "\n")
cat("% anio-celdas con Reported_value NA:", round(100*mean(is.na(b$Reported_value)),1), "\n")
