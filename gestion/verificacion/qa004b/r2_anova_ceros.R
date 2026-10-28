suppressMessages(library(tidyverse))
# Se corre desde la raiz del TP. Recalculo propio de faltantes, ceros, bloque y Friedman.
mun <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)
sect <- c("SA","SB","SC","SD","SE","SF","SG","SH","SI","SJ","SK","SL")

cat("=== Faltantes de Reported_value, 12 sectores, por periodo\n")
m12 <- mun |> filter(Item_code %in% sect)
cat("filas:", nrow(m12), " sin Reported:", sum(is.na(m12$Reported_value)), "\n")
print(m12 |> mutate(p = if_else(Year >= 2015, "15-24", "05-14")) |> group_by(p) |>
  summarise(n = n(), na = sum(is.na(Reported_value)), cero_compl = sum(is.na(Reported_value) & Final_value == 0)))

b <- m12 |> filter(Year >= 2015)
pres <- b |> distinct(Reporter, Year) |> count(Reporter) |> filter(n == 10) |> pull(Reporter)
b <- b |> filter(Reporter %in% pres)
cat("economias presentes 10 anios:", length(pres), "\n")
cel <- b |> group_by(Reporter, Item_code) |>
  summarise(v = mean(Final_value), rep = sum(!is.na(Reported_value)),
            e0 = sum(Final_value_methodology == "E0"),
            codigos = paste(sort(unique(Final_value_methodology)), collapse = "/"), .groups = "drop")
cat("celdas:", nrow(cel), " ceros:", sum(cel$v == 0), "\n")
cat("% anio-celda sin Reported en base ANOVA:", round(100 * mean(is.na(b$Reported_value)), 2), "\n")
z <- cel |> filter(v == 0) |> mutate(tipo = case_when(rep == 10 ~ "1 informado", rep > 0 ~ "2 mixto",
                                                     e0 > 0 ~ "3 E0", TRUE ~ "4 completado"))
print(count(z, tipo))
cat("=== Ceros por tipo y sector\n")
print(z |> count(Item_code, tipo) |> pivot_wider(names_from = tipo, values_from = n, values_fill = 0))
cat("=== Quien es el cero E0 en cada sector\n")
print(z |> filter(tipo == "3 E0") |> select(Reporter, Item_code, codigos), n = 30)
cat("=== Ceros de los 4 paises\n")
print(z |> filter(Reporter %in% c("AR","BR","CL","UY")))
cat("=== Codigos de Chile y Uruguay en SA, SB, SE, SL 2015-2024\n")
print(cel |> filter(Reporter %in% c("CL","UY"), Item_code %in% c("SA","SB","SE","SL")))

cat("=== Posicion de paises (percent_rank)\n")
pos <- cel |> group_by(Item_code) |> mutate(pct = 100 * percent_rank(v)) |> ungroup() |>
  filter(Reporter %in% c("AR","BR","CL","UY")) |> select(Reporter, Item_code, pct, v, rep)
print(pos |> filter(pct == 0 | v == 0))
print(pos |> group_by(Reporter) |> summarise(min = min(pct), max = max(pct),
  smin = Item_code[which.min(pct)], smax = Item_code[which.max(pct)]))

cat("=== ANOVA con bloque via lm\n")
pos_d <- cel |> filter(v > 0) |> mutate(y = log(v), sector = factor(Item_code), pais = factor(Reporter))
m0 <- lm(y ~ sector, data = pos_d); m1 <- lm(y ~ pais, data = pos_d); m2 <- lm(y ~ pais + sector, data = pos_d)
sst <- sum((pos_d$y - mean(pos_d$y))^2)
a <- anova(m1, m2)
cat("F sector|pais:", a$F[2], " df:", a$Df[2], a$Res.Df[2], "\n")
cat("eta2 sector|pais sobre SC total:", (deviance(m1) - deviance(m2)) / sst,
    " parcial:", (deviance(m1) - deviance(m2)) / ((deviance(m1) - deviance(m2)) + deviance(m2)),
    " eta2 pais:", (sst - deviance(m1)) / sst, "\n")
r <- residuals(m2)
cat("Shapiro bloque W:", shapiro.test(r)$statistic, " asim:", mean((r - mean(r))^3) / (mean((r - mean(r))^2))^1.5,
    " asim (sd n-1):", mean((r - mean(r))^3) / sd(r)^3, "\n")
sds <- tapply(r, pos_d$sector, sd); cat("cociente sd residuos bloque:", max(sds) / min(sds), "\n")
d <- abs(r - ave(r, pos_d$sector, FUN = median))
print(anova(lm(d ~ pos_d$sector)))

cat("=== Friedman propio (rangos con empates promedio, correccion por empates)\n")
w <- cel |> select(Reporter, Item_code, v) |> pivot_wider(names_from = Item_code, values_from = v)
M <- as.matrix(w[, sect]); n <- nrow(M); k <- ncol(M)
R <- t(apply(M, 1, rank))
Rj <- colSums(R)
S <- sum((Rj - n * (k + 1) / 2)^2)
# formula con correccion por empates (Conover)
A1 <- sum(R^2); C1 <- n * k * (k + 1)^2 / 4
T1 <- (k - 1) * (sum(Rj^2) - n * C1 / k) / (A1 - C1)
cat("n =", n, " k =", k, " chi2 Friedman (corregido empates):", T1, "\n")
cat("chi2 sin correccion:", 12 * S / (n * k * (k + 1)), "\n")
cat("W Kendall (chi2/(n(k-1))):", T1 / (n * (k - 1)), "\n")
ft <- friedman.test(M); cat("friedman.test R:", ft$statistic, ft$parameter, ft$p.value, "\n")
cat("rango medio por sector:\n"); print(round(sort(Rj / n, decreasing = TRUE), 2))
