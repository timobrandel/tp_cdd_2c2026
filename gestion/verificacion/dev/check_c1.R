suppressMessages(library(tidyverse))
b <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
cat(names(b), "\n")
x <- b |> filter(Item_code == "S", Partner != "ROW", Year %in% 2015:2024) |>
  pivot_longer(c(Balanced_value, Final_value), names_to = "medida", values_to = "v") |>
  group_by(medida, Reporter, Year) |>
  mutate(s = v / sum(v)) |>
  summarise(hhi = 1e4 * sum(s^2), cr4 = 100 * sum(sort(s, decreasing = TRUE)[1:4]), .groups = "drop") |>
  group_by(medida, Reporter) |> summarise(hhi = mean(hhi), cr4 = mean(cr4), .groups = "drop")
print(x)
# Origen del Final_value bilateral por país 2015-2024
print(b |> filter(Item_code == "S", Partner != "ROW", Year %in% 2015:2024) |>
  group_by(Reporter, origen) |> summarise(v = sum(Final_value), .groups = "drop") |>
  group_by(Reporter) |> mutate(pct = 100 * v / sum(v)))
