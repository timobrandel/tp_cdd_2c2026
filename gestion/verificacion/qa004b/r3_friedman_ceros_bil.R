suppressMessages(library(tidyverse))
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
sect <- c("SA","SB","SC","SD","SE","SF","SG","SH","SI","SJ","SK","SL")
b <- mun |> filter(Item_code %in% sect, Year >= 2015)
pres <- b |> distinct(Reporter, Year) |> count(Reporter) |> filter(n == 10) |> pull(Reporter)
cel <- b |> filter(Reporter %in% pres) |> group_by(Reporter, Item_code) |>
  summarise(v = mean(Final_value), .groups = "drop")
M <- cel |> pivot_wider(names_from = Item_code, values_from = v) |> select(all_of(sect)) |> as.matrix()
n <- nrow(M); k <- ncol(M)
R <- t(apply(M, 1, rank))
S <- sum((colSums(R) - n * (k + 1) / 2)^2)
# Correccion por empates: sum(t^3 - t) por bloque
ties <- sum(apply(M, 1, function(x) { t <- table(x); sum(t^3 - t) }))
chi2 <- 12 * S / (n * k * (k + 1) - ties / (k - 1))
cat("Friedman propio con empates:", chi2, " W:", chi2 / (n * (k - 1)), " p:", pchisq(chi2, k - 1, lower.tail = FALSE), "\n")

cat("=== Ceros bilaterales 2015-2024, sectores, sin ROW: codigo del valor final\n")
z <- bil |> filter(Item_code %in% sect, Year >= 2015, Partner != "ROW", Balanced_value == 0)
cat("total:", nrow(z), "\n")
print(z |> mutate(cod = case_when(str_starts(Final_value_methodology, "R_") ~ "R_ (declarado)",
                                  Final_value_methodology == "E0" ~ "E0",
                                  TRUE ~ "otra estimacion")) |> count(Reporter, cod) |>
  pivot_wider(names_from = cod, values_from = n, values_fill = 0))

cat("=== Sectores AR con final: anios con total > 0\n")
print(bil |> filter(Reporter %in% c("AR","UY"), Item_code %in% sect, Year >= 2015, Partner != "ROW") |>
  group_by(Reporter, Item_code, Year) |> summarise(t = sum(Final_value), .groups = "drop") |>
  group_by(Reporter, Item_code) |> summarise(anios_pos = sum(t > 0), .groups = "drop") |> filter(anios_pos < 10))
cat("=== BR sensibilidad 2010-2014 vs 2015-2024 balanceado y final\n")
ind <- function(var) bil |> filter(Partner != "ROW", Item_code == "S", Reporter == "BR") |> mutate(v = .data[[var]]) |>
  group_by(Year) |> mutate(s = v / sum(v)) |> summarise(hhi = 10000 * sum(s^2))
for (vv in c("Balanced_value", "Final_value")) {
  h <- ind(vv); cat(vv, " 05-09:", mean(h$hhi[h$Year <= 2009]), " 10-14:", mean(h$hhi[h$Year %in% 2010:2014]),
                    " 15-24:", mean(h$hhi[h$Year >= 2015]), "\n") }
