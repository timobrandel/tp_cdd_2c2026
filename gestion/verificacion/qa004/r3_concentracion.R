suppressMessages(library(tidyverse))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)

# Indices propios: HHI, CR1, CR4 por pais-item-anio, con una medida dada
indices <- function(d, var, excluir_row = TRUE) {
  if (excluir_row) d <- d |> filter(Partner != "ROW")
  d |> mutate(v = .data[[var]]) |>
    group_by(Reporter, Item_code, Year) |>
    filter(sum(v) > 0) |>
    mutate(s = v / sum(v)) |>
    summarise(hhi = sum(s^2), cr1 = max(s), cr4 = sum(sort(s, decreasing = TRUE)[1:4]),
              top = Partner[which.max(s)], .groups = "drop")
}
ib <- indices(bil, "Balanced_value")
ifn <- indices(bil, "Final_value")
ib_row <- indices(bil, "Balanced_value", excluir_row = FALSE)

res <- function(x, lab) x |> filter(Item_code == "S") |>
  mutate(per = if_else(Year < 2015, "2005-2014", "2015-2024")) |>
  group_by(Reporter, per) |>
  summarise(hhi = 10000*mean(hhi), cr1 = 100*mean(cr1), cr4 = 100*mean(cr4),
            seq_mean_inv = mean(1/hhi), seq_inv_mean = 1/mean(hhi), .groups = "drop") |>
  mutate(medida = lab)
cat("=== Total S, Balanced, sin ROW\n"); print(res(ib, "bal"), width = Inf)
cat("=== Total S, Final, sin ROW\n"); print(res(ifn, "final"), width = Inf)
cat("=== Total S, Balanced, con ROW\n"); print(res(ib_row, "bal+ROW") |> filter(per=="2015-2024"), width = Inf)

# HHI del periodo con el valor acumulado (en vez del promedio de anuales)
cat("=== HHI sobre el valor acumulado 2015-2024 (Balanced, sin ROW)\n")
print(bil |> filter(Item_code=="S", Partner!="ROW", Year>=2015) |> group_by(Reporter, Partner) |>
  summarise(v = sum(Balanced_value), .groups="drop") |> group_by(Reporter) |>
  mutate(s = v/sum(v)) |> summarise(hhi = 10000*sum(s^2), cr1=100*max(s), cr4=100*sum(sort(s,TRUE)[1:4])))

# Anual: Chile vs Argentina
cat("=== HHI anual S (x10000) Balanced\n")
an <- ib |> filter(Item_code=="S") |> select(Reporter, Year, hhi) |> mutate(hhi=round(10000*hhi)) |>
  pivot_wider(names_from=Reporter, values_from=hhi) |> mutate(CL_gt_AR = CL > AR)
print(an, n = 30)
cat("=== HHI anual S (x10000) Final\n")
print(ifn |> filter(Item_code=="S") |> select(Reporter, Year, hhi) |> mutate(hhi=round(10000*hhi)) |>
  pivot_wider(names_from=Reporter, values_from=hhi) |> mutate(CL_gt_AR = CL > AR), n = 30)

# Sectores 2015-2024, Balanced
sec <- ib |> filter(Year >= 2015, Item_code != "S") |> group_by(Reporter, Item_code) |>
  summarise(hhi = mean(hhi), seq = mean(1/hhi), seq2 = 1/mean(hhi), cr1 = mean(cr1), n = n(), .groups = "drop")
cat("=== socios equivalentes AR por sector (mean(1/HHI) vs 1/mean(HHI))\n")
print(sec |> filter(Reporter=="AR") |> arrange(seq), n = 20)
cat("=== CV HHI entre sectores\n")
print(sec |> group_by(Reporter) |> summarise(cv = sd(hhi)/mean(hhi), min_seq = min(seq), max_seq = max(seq),
  sec_min = Item_code[which.min(seq)], sec_max = Item_code[which.max(seq)],
  sec_max_by_hhi = Item_code[which.min(hhi)]))
cat("=== n anios por sector (debe ser 10)\n"); print(table(sec$n))
# SK Argentina: participacion EEUU
cat("=== AR SK: CR1 medio y top\n"); print(ib |> filter(Reporter=="AR", Item_code=="SK", Year>=2015) |> select(Year, top, cr1, hhi))
# CR1 AR US 2015-2024
cat("=== CR1 promedio 2015-2024 por pais (S)\n")
print(ib |> filter(Item_code=="S", Year>=2015) |> group_by(Reporter) |> summarise(cr1=100*mean(cr1), tops = paste(unique(top), collapse=",")))

# Origen del dato, total S, % estimado por anio
cat("=== % valor estimado (no R_, no E1) por pais-anio, S, sin ROW\n")
or <- bil |> filter(Item_code=="S", Partner!="ROW") |>
  mutate(est = !(str_starts(Final_value_methodology, "R_") | Final_value_methodology=="E1")) |>
  group_by(Reporter, Year) |> summarise(pct = 100*sum(Balanced_value[est])/sum(Balanced_value), .groups="drop") |>
  pivot_wider(names_from=Reporter, values_from=pct)
print(or, n = 30)
cat("=== % estimado por sector 2015-2024, sin ROW\n")
print(bil |> filter(Item_code!="S", Partner!="ROW", Year>=2015) |>
  mutate(est = !(str_starts(Final_value_methodology, "R_") | Final_value_methodology=="E1")) |>
  group_by(Reporter, Item_code) |> summarise(pct = round(100*sum(Balanced_value[est])/sum(Balanced_value),1), .groups="drop") |>
  pivot_wider(names_from=Reporter, values_from=pct))
# Socios con dato oficial Brasil
cat("=== BR socios con R_ por anio (S)\n")
print(bil |> filter(Item_code=="S", Reporter=="BR") |> group_by(Year) |>
  summarise(n_of = sum(str_starts(Final_value_methodology,"R_")),
            pct_v = 100*sum(Balanced_value[str_starts(Final_value_methodology,"R_")])/sum(Balanced_value)), n=30)
# ROW peso
cat("=== ROW max %:", bil |> filter(Item_code=="S") |> group_by(Reporter, Year) |>
  summarise(p = 100*sum(Balanced_value[Partner=="ROW"])/sum(Balanced_value), .groups="drop") |> pull(p) |> max(), "\n")
# Ceros bilateral 2015-2024 sin ROW, sectores
cat("ceros bilateral 2015-2024 sectores sin ROW:", sum(bil$Balanced_value[bil$Item_code!="S" & bil$Year>=2015 & bil$Partner!="ROW"]==0), "\n")
# Diferencia Balanced vs Final en la distribucion por socio de AR 2015-2024
cat("=== AR 2015-2024: participacion EEUU con Final vs Balanced (S)\n")
print(bil |> filter(Reporter=="AR", Item_code=="S", Partner!="ROW", Year>=2015) |> group_by(Year) |>
  summarise(us_bal = 100*sum(Balanced_value[Partner=="US"])/sum(Balanced_value),
            us_fin = 100*sum(Final_value[Partner=="US"])/sum(Final_value),
            tot_bal = sum(Balanced_value), tot_fin = sum(Final_value)))
