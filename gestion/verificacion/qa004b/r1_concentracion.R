suppressMessages(library(tidyverse))
# Se corre desde la raiz del TP. Recalculo propio (sin funciones del Dev).
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)

cat("=== Dimensiones\n"); print(dim(bil)); print(dim(mun))
cat("=== NA por variable bilateral\n"); print(colSums(is.na(bil)))
cat("=== NA por variable mundo\n"); print(colSums(is.na(mun)))
cat("dup bil:", sum(duplicated(bil[c("Reporter","Partner","Item_code","Year")])),
    " dup mun:", sum(duplicated(mun[c("Reporter","Item_code","Year")])), "\n")
cat("Namibia como socio:", sum(bil$Partner == "NA"), " como informante:", sum(mun$Reporter == "NA"), "\n")

ind <- function(var) bil |> filter(Partner != "ROW") |> mutate(v = .data[[var]]) |>
  group_by(Reporter, Item_code, Year) |> filter(sum(v) > 0) |> mutate(s = v / sum(v)) |>
  summarise(hhi = sum(s^2), cr1 = max(s), cr4 = sum(sort(s, decreasing = TRUE)[1:4]),
            top = Partner[which.max(s)], .groups = "drop")
ib <- ind("Balanced_value") |> mutate(medida = "balanceado")
ifn <- ind("Final_value") |> mutate(medida = "final")
ii <- bind_rows(ib, ifn)

cat("=== Total S 2015-2024: HHI, CR1, CR4, 1/mean(HHI)\n")
tot <- ii |> filter(Item_code == "S", Year >= 2015) |> group_by(medida, Reporter) |>
  summarise(hhi = 10000 * mean(hhi), cr1 = 100 * mean(cr1), cr4 = 100 * mean(cr4),
            seq = 10000 / hhi, .groups = "drop")
print(tot, n = Inf)

cat("=== Anios 2015-2024 en que AR > vecino (HHI y CR4)\n")
an <- ii |> filter(Item_code == "S", Year >= 2015) |> select(medida, Reporter, Year, hhi, cr4)
ar <- an |> filter(Reporter == "AR") |> rename(hhi_ar = hhi, cr4_ar = cr4) |> select(-Reporter)
print(an |> filter(Reporter != "AR") |> left_join(ar, by = c("medida", "Year")) |>
  group_by(medida, Reporter) |>
  summarise(hhi_ar_mayor = sum(hhi_ar > hhi), cr4_ar_mayor = sum(cr4_ar > cr4), .groups = "drop"))

cat("=== HHI anual S x10000, balanceado y final, 2005-2024\n")
print(ii |> filter(Item_code == "S") |> mutate(h = round(10000 * hhi)) |>
  select(medida, Reporter, Year, h) |> pivot_wider(names_from = Reporter, values_from = h) |>
  mutate(CL_gt_AR = CL > AR, BR_gt_AR = BR > AR), n = Inf)
cat("=== CR4 anual S, balanceado 2015-2024\n")
print(ib |> filter(Item_code == "S", Year >= 2015) |> mutate(c4 = round(100 * cr4, 1)) |>
  select(Reporter, Year, c4) |> pivot_wider(names_from = Reporter, values_from = c4), n = Inf)

cat("=== Sensibilidad por periodo (S)\n")
print(ii |> filter(Item_code == "S") |> mutate(per = if_else(Year < 2015, "05-14", "15-24")) |>
  group_by(medida, Reporter, per) |> summarise(hhi = round(10000 * mean(hhi)), .groups = "drop") |>
  pivot_wider(names_from = per, values_from = hhi))

cat("=== Sectores 2015-2024: socios equivalentes = 1/mean(HHI)\n")
sec <- ii |> filter(Item_code != "S", Year >= 2015) |> group_by(medida, Reporter, Item_code) |>
  summarise(hhi = mean(hhi), cr1 = mean(cr1), n = n(), top = names(which.max(table(top))), .groups = "drop") |>
  mutate(seq = 1 / hhi)
print(sec |> filter(Reporter == "AR", medida == "balanceado") |> arrange(seq) |>
        mutate(hhi = round(10000 * hhi, 2), seq = round(seq, 3), cr1 = round(100 * cr1, 1)), n = Inf)
cat("=== CV del HHI entre sectores y extremos\n")
print(sec |> group_by(medida, Reporter) |>
  summarise(cv = round(sd(hhi) / mean(hhi), 3), min_seq = round(min(seq), 2), max_seq = round(max(seq), 2),
            s_min = Item_code[which.min(seq)], s_max = Item_code[which.max(seq)], n = min(n), .groups = "drop"), n = Inf)

cat("=== Brasil: codigos de metodologia del total por socio 2005-2014 (peso en balanceado)\n")
print(bil |> filter(Reporter == "BR", Item_code == "S", Year <= 2014, Partner != "ROW") |>
  group_by(Year, Final_value_methodology) |> summarise(v = sum(Balanced_value), .groups = "drop") |>
  group_by(Year) |> mutate(pct = round(100 * v / sum(v), 1)) |> filter(pct > 1) |> arrange(Year, desc(pct)), n = 60)
cat("=== Argentina: codigos 2005-2014\n")
print(bil |> filter(Reporter == "AR", Item_code == "S", Year <= 2014, Partner != "ROW") |>
  group_by(Final_value_methodology) |> summarise(v = sum(Balanced_value), .groups = "drop") |>
  mutate(pct = round(100 * v / sum(v), 1)))
