suppressMessages(library(tidyverse))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
cat("bilateral dim:", dim(bil), "\n"); print(names(bil))
cat("mundo dim:", dim(mun), "\n"); print(names(mun))
cat("\nNA por variable bilateral:\n"); print(colSums(is.na(bil)))
cat("\nNA por variable mundo:\n"); print(colSums(is.na(mun)))
cat("\nDuplicados clave bilateral:", sum(duplicated(bil[c("Reporter","Partner","Item_code","Year")])), "\n")
cat("Duplicados clave mundo:", sum(duplicated(mun[c("Reporter","Item_code","Year")])), "\n")
cat("Reporters bilateral:", sort(unique(bil$Reporter)), "\n")
cat("Partners bilateral:", n_distinct(bil$Partner), " Reporters mundo:", n_distinct(mun$Reporter), "\n")
cat("Namibia como socio filas:", sum(bil$Partner == "NA"), " nombre:", unique(bil$nombre_socio[bil$Partner=="NA"]), "\n")
cat("Namibia como reporter mundo filas:", sum(mun$Reporter == "NA"), " nombre:", unique(mun$nombre_pais[mun$Reporter=="NA"]), "\n")
# lectura por defecto (sin na = "")
bil_def <- read_csv("input/batis_bilateral.csv", show_col_types = FALSE)
mun_def <- read_csv("input/batis_mundo_sectores.csv", show_col_types = FALSE)
cat("Con lectura por defecto: Partner NA:", sum(is.na(bil_def$Partner)), " Reporter NA mundo:", sum(is.na(mun_def$Reporter)), "\n")
# nombres sin match
cat("nombre_socio NA:", sum(is.na(bil$nombre_socio)), " nombre_pais NA:", sum(is.na(mun$nombre_pais)), "\n")
print(unique(bil$Partner[is.na(bil$nombre_socio)]))
print(unique(mun$Reporter[is.na(mun$nombre_pais)]))
# Final_value NA y metodologia NA
cat("\nFinal_value NA mundo, sectores 2015-2024:", sum(is.na(mun$Final_value[mun$Item_code!="S" & mun$Year>=2015])), "\n")
cat("Metodologia NA mundo:", sum(is.na(mun$Final_value_methodology)), " bil:", sum(is.na(bil$Final_value_methodology)), "\n")
cat("Reported_value NA mundo:", sum(is.na(mun$Reported_value)), " de ", nrow(mun), "\n")
cat("Reported_value NA bil:", sum(is.na(bil$Reported_value)), " de ", nrow(bil), "\n")
cat("Ceros Balanced bil:", sum(bil$Balanced_value==0), " Ceros Final mundo:", sum(mun$Final_value==0, na.rm=TRUE), "\n")
cat("Tabla metodologia mundo:\n"); print(sort(table(mun$Final_value_methodology), decreasing=TRUE))
cat("Tabla metodologia bil:\n"); print(sort(table(bil$Final_value_methodology), decreasing=TRUE))

# Control suma socios vs WL (Balanced)
cs <- bil |> group_by(Reporter, Item_code, Year) |> summarise(s = sum(Balanced_value), .groups="drop") |>
  inner_join(mun |> select(Reporter, Item_code, Year, wl = Balanced_value), by = c("Reporter","Item_code","Year"))
cat("\nn combos:", nrow(cs), " max abs dif:", max(abs(cs$s - cs$wl)), "\n")
# Suma de socios con Final_value vs WL Final
cs2 <- bil |> group_by(Reporter, Item_code, Year) |> summarise(s = sum(Final_value, na.rm=TRUE), .groups="drop") |>
  inner_join(mun |> select(Reporter, Item_code, Year, wl = Final_value), by = c("Reporter","Item_code","Year"))
cat("Final: max abs dif socios vs WL:", max(abs(cs2$s - cs2$wl), na.rm=TRUE), " max rel:", max(abs(cs2$s/cs2$wl-1), na.rm=TRUE), "\n")
print(cs2 |> mutate(rel = s/wl - 1) |> filter(Item_code=="S") |> group_by(Reporter) |> summarise(min=min(rel,na.rm=T), max=max(rel,na.rm=T)))

# Suma de sectores = S con Final_value en la base del ANOVA
ss <- mun |> filter(Year %in% 2015:2024) |> group_by(Reporter, Year) |>
  summarise(sec = sum(Final_value[Item_code!="S"]), tot = Final_value[Item_code=="S"], .groups="drop") |>
  mutate(dif = sec - tot, rel = ifelse(tot>0, sec/tot - 1, NA))
cat("\nFinal: suma de sectores vs S. max abs:", max(abs(ss$dif)), "\n")
print(ss |> filter(abs(rel) > 0.01) |> arrange(desc(abs(rel))) |> head(15))
print(ss |> filter(Reporter %in% c("AR","BR","CL","UY")) |> group_by(Reporter) |> summarise(min=min(rel), max=max(rel)))
# Gabon 2024
print(mun |> filter(Reporter=="GA", Year==2024, Item_code=="S") |> select(Reporter, Year, Reported_value, Final_value, Balanced_value, Final_value_methodology))
