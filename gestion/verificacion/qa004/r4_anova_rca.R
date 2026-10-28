suppressMessages(library(tidyverse))
setwd("C:/Users/timob/Documents/Codex/2026-08-28/es/tp_cdd_2c2026")
bil <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
sect <- c("SA","SB","SC","SD","SE","SF","SG","SH","SI","SJ","SK","SL")

# socios equivalentes: media de 1/HHI vs 1/media de HHI (bien calculado)
hh <- bil |> filter(Partner != "ROW") |> group_by(Reporter, Item_code, Year) |>
  filter(sum(Balanced_value) > 0) |> mutate(s = Balanced_value/sum(Balanced_value)) |>
  summarise(h = sum(s^2), .groups = "drop") |> filter(Year >= 2015)
print(hh |> group_by(Reporter, Item_code) |> summarise(hhi = 10000*mean(h), inv_media = 1/mean(h), media_inv = mean(1/h), .groups="drop") |>
  filter(Item_code %in% c("S","SK","SC","SB")), n = 50)

# Base ANOVA propia (sin copiar el script): economias con 10 anios en 2015-2024
b <- mun |> filter(Item_code %in% sect, Year >= 2015, Year <= 2024)
pres <- b |> distinct(Reporter, Year) |> count(Reporter) |> filter(n == 10) |> pull(Reporter)
cat("Economias con los 10 anios:", length(pres), " total economias en mundo:", n_distinct(mun$Reporter), "\n")
cat("Ausentes:", setdiff(unique(mun$Reporter), pres), "\n")
ba <- b |> filter(Reporter %in% pres) |> group_by(Reporter, Item_code) |>
  summarise(v = mean(Final_value), n = n(), cod0 = paste(sort(unique(Final_value_methodology)), collapse="|"), .groups = "drop")
cat("Celdas:", nrow(ba), " ceros:", sum(ba$v == 0), "\n")
print(ba |> group_by(Item_code) |> summarise(ceros = sum(v==0), pct = 100*mean(v==0)))
# Composicion de codigos en celdas cero
cat("=== codigos de metodologia en las 318 celdas cero (anios 2015-2024)\n")
z <- b |> semi_join(ba |> filter(v == 0), by = c("Reporter","Item_code"))
print(sort(table(z$Final_value_methodology), decreasing = TRUE))
cat("=== Chile, sectores con cero: codigos\n")
print(b |> filter(Reporter=="CL", Item_code %in% c("SA","SB","SE","SL")) |> count(Item_code, Final_value_methodology, Reported_value_na = is.na(Reported_value)))
cat("=== Celdas cero cuyos 10 anios son reportados (R_):\n")
print(z |> group_by(Reporter, Item_code) |> summarise(todos_R = all(str_starts(Final_value_methodology,"R_")), alguno_E0 = any(Final_value_methodology %in% c("E0","E8.0")), .groups="drop") |> count(todos_R, alguno_E0))

# ANOVA independiente con lm
p <- ba |> filter(v > 0) |> mutate(y = log(v), g = factor(Item_code))
cat("N positivos:", nrow(p), "\n")
m <- lm(y ~ g, data = p); a <- anova(m); print(a)
cat("eta2:", a$`Sum Sq`[1]/sum(a$`Sum Sq`), "\n")
r <- residuals(m); print(shapiro.test(r))
cat("asimetria (g1 poblacional):", mean((r-mean(r))^3)/mean((r-mean(r))^2)^1.5, " (con sd muestral):", mean((r-mean(r))^3)/sd(r)^3, "\n")
sds <- tapply(p$y, p$g, sd); cat("cociente sd:", max(sds)/min(sds), "\n")
# Levene Brown-Forsythe independiente (via lm)
med <- tapply(p$y, p$g, median); p$z <- abs(p$y - med[as.character(p$g)])
print(anova(lm(z ~ g, data = p)))
# Levene clasico (media) y Fligner como comparacion
mu <- tapply(p$y, p$g, mean); p$z2 <- abs(p$y - mu[as.character(p$g)])
cat("Levene (media):\n"); print(anova(lm(z2 ~ g, data = p)))
print(fligner.test(y ~ g, data = p))
print(oneway.test(y ~ g, data = p))
k1 <- kruskal.test(v ~ factor(Item_code), data = ba); k2 <- kruskal.test(v ~ g, data = p)
cat("KW con ceros H:", k1$statistic, " eps2:", k1$statistic/(nrow(ba)-1), "\n")
cat("KW sin ceros H:", k2$statistic, " eps2:", k2$statistic/(nrow(p)-1), "\n")
mb <- lm(y ~ factor(Reporter) + g, data = p); ab <- anova(mb); print(ab)
cat("eta2 parcial sector:", ab$`Sum Sq`[2]/(ab$`Sum Sq`[2]+ab$`Sum Sq`[3]), " eta2 pais:", ab$`Sum Sq`[1]/sum(ab$`Sum Sq`),
    " eta2 sector (semiparcial, SC sector|pais / SC total):", ab$`Sum Sq`[2]/sum(ab$`Sum Sq`), "\n")
# Orden inverso (sector primero) para ver SC tipo I
ab2 <- anova(lm(y ~ g + factor(Reporter), data = p)); print(ab2)
# Medias geometricas
mg <- p |> group_by(Item_code) |> summarise(mg = exp(mean(y)), n = n()) |> arrange(desc(mg)); print(mg)
cat("SD/SH:", mg$mg[mg$Item_code=="SD"]/mg$mg[mg$Item_code=="SH"], "\n")

# Games-Howell propio (formula de Games & Howell 1976): t = d/sqrt(v1/n1+v2/n2), q = t*sqrt(2)
gr <- levels(p$g); k <- length(gr); out <- list()
for (i in 1:(k-1)) for (j in (i+1):k) {
  y1 <- p$y[p$g==gr[i]]; y2 <- p$y[p$g==gr[j]]
  se2 <- var(y1)/length(y1) + var(y2)/length(y2)
  df <- se2^2/((var(y1)/length(y1))^2/(length(y1)-1) + (var(y2)/length(y2))^2/(length(y2)-1))
  q <- abs(mean(y2)-mean(y1))/sqrt(se2) * sqrt(2)
  out[[length(out)+1]] <- tibble(a=gr[i], b=gr[j], d=mean(y2)-mean(y1), padj = ptukey(q, k, df, lower.tail=FALSE))
}
gh <- bind_rows(out); cat("GH propio, pares sig:", sum(gh$padj < 0.05), " de ", nrow(gh), "\n")
tk <- TukeyHSD(aov(y ~ g, data = p))$g; cat("Tukey pares sig:", sum(tk[,"p adj"] < 0.05), "\n")
# comparar con la tabla del Dev
dev <- readr::read_csv2("output/tablas/08_comparaciones_pares.csv", show_col_types = FALSE)
cat("Dev pares sig:", sum(dev$significativo), "\n")
gh2 <- gh |> mutate(k1 = pmin(a,b), k2 = pmax(a,b), sig = padj < 0.05)
dv2 <- dev |> mutate(k1 = pmin(sector_mayor, sector_menor), k2 = pmax(sector_mayor, sector_menor))
cmp <- inner_join(gh2, dv2, by = c("k1","k2")); cat("pares con distinta significancia:", sum(cmp$sig != cmp$significativo), "\n")
print(cmp |> filter(sig != significativo))
# Pares no significativos entre los 4 grandes
print(gh2 |> filter(k1 %in% c("SC","SD","SI","SJ"), k2 %in% c("SC","SD","SI","SJ")) |> select(k1,k2,padj,sig))

# RCA y diversidad independiente
br <- ba |> group_by(Reporter) |> filter(sum(v) > 0) |> ungroup()
cat("Economias RCA:", n_distinct(br$Reporter), " excluida:", setdiff(unique(ba$Reporter), unique(br$Reporter)), "\n")
W <- sum(br$v); ws <- br |> group_by(Item_code) |> summarise(ws = sum(v)/W)
rc <- br |> group_by(Reporter) |> mutate(cs = v/sum(v)) |> ungroup() |> left_join(ws, by = "Item_code") |> mutate(rca = cs/ws)
dv <- rc |> group_by(Reporter) |> summarise(d = sum(rca > 1))
cat("Mediana diversidad:", median(dv$d), "\n")
for (cc in c("AR","BR","CL","UY")) { x <- dv$d[dv$Reporter==cc]
  cat(cc, ":", x, " sectores:", paste(rc$Item_code[rc$Reporter==cc & rc$rca>1], collapse=","),
      " %estrict menor:", round(100*mean(dv$d[dv$Reporter!=cc] < x),1),
      " %menor o igual:", round(100*mean(dv$d <= x),1),
      " percent_rank:", round(100*(sum(dv$d < x))/(nrow(dv)-1),1), "\n") }
# RCA de Chile si se excluyen los 4 sectores no informados del mundo
cat("=== Chile S vs suma de sectores Final 2015-2024 promedio:\n")
print(mun |> filter(Reporter=="CL", Year>=2015) |> group_by(Item_code) |> summarise(v = mean(Final_value), cod = paste(unique(Final_value_methodology), collapse="|")), n=20)
