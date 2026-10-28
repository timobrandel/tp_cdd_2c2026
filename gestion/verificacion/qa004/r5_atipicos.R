suppressMessages(library(tidyverse))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
sect <- c("SA","SB","SC","SD","SE","SF","SG","SH","SI","SJ","SK","SL")
b <- mun |> filter(Item_code %in% sect, Year >= 2015) |> group_by(Reporter, Item_code) |>
  summarise(v = mean(Final_value), n = n(), .groups = "drop") |> filter(n == 10, v > 0) |> mutate(y = log(v))
# boxplot.stats usa bisagras de Tukey (fivenum), otra variante de cuartiles
at <- b |> group_by(Item_code) |> mutate(q1 = quantile(y, .25), q3 = quantile(y, .75), r = q3 - q1,
  t = case_when(y < q1 - 1.5*r ~ "bajo", y > q3 + 1.5*r ~ "alto")) |> ungroup()
print(at |> count(t)); print(at |> filter(t == "alto") |> select(Reporter, Item_code, v))
print(at |> filter(t == "bajo") |> select(Reporter, Item_code, v) |> arrange(Item_code), n = 30)
bs <- b |> group_by(Item_code) |> summarise(nout = length(boxplot.stats(y)$out)); cat("con boxplot.stats (fivenum):", sum(bs$nout), "\n")
# bilateral 2024
f <- bil |> filter(Year == 2024, Item_code %in% sect, Partner != "ROW", Balanced_value > 0) |>
  mutate(y = log(Balanced_value)) |> group_by(Reporter, Item_code) |>
  mutate(q1 = quantile(y,.25), q3 = quantile(y,.75), r = q3-q1, alto = y > q3 + 1.5*r) |> ungroup()
print(f |> filter(alto) |> select(Reporter, Item_code, Partner, Balanced_value))
cat("altos:", sum(f$alto), " combos:", n_distinct(paste(f$Reporter[f$alto], f$Item_code[f$alto])), "\n")
# AR SK 2023 vs 2024: socios principales, codigo de metodologia
print(bil |> filter(Reporter=="AR", Item_code=="SK", Year %in% 2022:2024) |> group_by(Year) |>
  slice_max(Balanced_value, n = 4) |> select(Year, Partner, Balanced_value, Final_value, Final_value_methodology))
print(bil |> filter(Reporter=="AR", Item_code=="SK", Year %in% 2021:2024) |> group_by(Year) |> summarise(tot_bal = sum(Balanced_value), tot_fin = sum(Final_value),
  us_bal = sum(Balanced_value[Partner=="US"]), us_fin = sum(Final_value[Partner=="US"])))
# Tablas del Dev: cifras clave
s <- read_csv2("output/tablas/07_sensibilidad_periodo.csv", show_col_types = FALSE); print(s, width = Inf)
d <- read_csv2("output/tablas/07_diversidad.csv", show_col_types = FALSE); print(d, width = Inf)
t8 <- read_csv2("output/tablas/08_tests.csv", show_col_types = FALSE); print(t8, width = Inf)
cs <- read_csv2("output/tablas/07_concentracion_sectores.csv", show_col_types = FALSE)
print(cs |> filter(Reporter == "AR") |> select(Item_code, hhi_x10000, socios_equivalentes, cr1_pct, socio_principal, dato_propio), n = 20)
dg <- read_csv2("output/tablas/06_diagnostico_resumen.csv", show_col_types = FALSE); for (i in 1:nrow(dg)) cat(i, dg$tema[i], "||", dg$magnitud[i], "||", dg$decision[i], "\n")
# GH: bloques de D-028
pr <- read_csv2("output/tablas/08_comparaciones_pares.csv", show_col_types = FALSE)
blk <- function(x) pr |> filter(sector_mayor %in% x, sector_menor %in% x) |> select(sector_mayor, sector_menor, diferencia_pct, p_ajustado, significativo)
cat("bloque medio SL SG SE SA SF\n"); print(blk(c("SL","SG","SE","SA","SF")), n = 20)
cat("bloque bajo SK SB SH\n"); print(blk(c("SK","SB","SH")))
cat("medio vs bajo\n"); print(pr |> filter(sector_mayor %in% c("SL","SG","SE","SA","SF"), sector_menor %in% c("SK","SB","SH")) |> select(sector_mayor, sector_menor, p_ajustado, significativo), n = 20)
cat("medio vs bajo (invertido)\n"); print(pr |> filter(sector_menor %in% c("SL","SG","SE","SA","SF"), sector_mayor %in% c("SK","SB","SH")) |> select(sector_mayor, sector_menor, p_ajustado, significativo), n = 20)
