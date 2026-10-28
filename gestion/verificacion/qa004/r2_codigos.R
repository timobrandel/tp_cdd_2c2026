suppressMessages(library(tidyverse)); suppressMessages(library(readxl))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
f <- "raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx"
print(excel_sheets(f))
for (s in excel_sheets(f)) { if (grepl("method", s, ignore.case=TRUE)) { x <- read_excel(f, sheet = s); print(x, n = Inf, width = 200) } }
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
print(mun |> filter(Reporter=="GA", Year==2024, Item_code=="S") |> pull(Final_value_methodology))
# Codigos por pais y periodo, total S
print(bil |> filter(Item_code=="S") |> mutate(p = if_else(Year<2015,"05-14","15-24")) |>
  group_by(Reporter, p, Final_value_methodology) |> summarise(n=n(), valor=sum(Balanced_value), .groups="drop") |>
  group_by(Reporter, p) |> mutate(pct=100*valor/sum(valor)) |> arrange(Reporter,p,desc(pct)) |> filter(pct>0.5), n=100)
# Argentina por anio: codigo por valor
print(bil |> filter(Item_code=="S", Reporter=="AR", Year>=2014) |> group_by(Year, Final_value_methodology) |>
  summarise(n=n(), v=sum(Balanced_value), .groups="drop") |> group_by(Year) |> mutate(pct=round(100*v/sum(v),1)) |> filter(pct>0.5), n=100)
