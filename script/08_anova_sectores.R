# -----------------------------------------------------------------
# Script      08_anova_sectores.R
# Objetivo    Contrastar si el valor exportado difiere entre los 12
#             sectores de servicios, con todos los países (ANOVA de un
#             factor, sus supuestos y las comparaciones de a pares)
# Entrada     input/batis_mundo_sectores.csv
# Salida      output/tablas/08_descriptivos_sectores.csv
#             output/tablas/08_tests.csv
#             output/tablas/08_comparaciones_pares.csv
#             output/tablas/08_posicion_paises.csv
#             output/graficos/08_g1_medias_sectores.png
#             output/graficos/08_g2_qq_residuos.png
#             output/graficos/08_g3_pares_sectores.png
# -----------------------------------------------------------------
# Requiere haber corrido antes 05_filtrado_bilateral.R.
#
# Responde la última parte de la hipótesis (D-024): "el valor exportado
# difiere según el sector". Es la sugerencia del profesor en la devolución
# de la Instancia 1: "usen la base con todos los países para analizar si los
# servicios tienen diferencias entre sí en cuanto al valor generado (con un
# ANOVA)". La secuencia sigue la clase 10:
#   1. ANOVA sobre el logaritmo del valor, con eta cuadrado;
#   2. supuestos: independencia, normalidad de los residuos y varianzas;
#   3. si fallan: ANOVA de Welch y Kruskal-Wallis;
#   4. comparaciones de a pares: Tukey o Games-Howell.
#
# Unidad de análisis (D-026): una fila por país y sector con el promedio
# anual 2015-2024 del valor final, para las economías presentes los diez
# años. Es la misma base del script 06.

library(tidyverse)
library(scales)

source("utils/guardar_tabla.R")
source("utils/games_howell.R")
source("utils/test_levene.R")
source("utils/formato_num.R")
source("utils/formato_p.R")
source("utils/etiqueta_razon.R")

dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)
dir.create("output/graficos", recursive = TRUE, showWarnings = FALSE)

# na = "": el código de Namibia es "NA" (ver el 05)
mundo <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)

etiquetas_paises <- c(AR = "Argentina", BR = "Brasil", CL = "Chile", UY = "Uruguay")

etiquetas_servicios <- c(
  SA = "Manufactura sobre insumos de terceros",
  SB = "Mantenimiento y reparación",
  SC = "Transporte",
  SD = "Viajes",
  SE = "Construcción",
  SF = "Seguros y pensiones",
  SG = "Financieros",
  SH = "Propiedad intelectual",
  SI = "Telecom., informática e información",
  SJ = "Otros servicios empresariales",
  SK = "Personales, culturales y recreativos",
  SL = "Bienes y servicios del gobierno"
)
sectores <- names(etiquetas_servicios)

periodo_analisis <- 2015:2024

fuente <- paste0("Fuente: elaboración propia con datos de OECD-WTO BaTIS ",
                 "(BPM6, versión dic. 2025).")
tema_tp <- theme_minimal() +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.caption          = element_text(hjust = 0, size = 8, color = "grey30"),
    legend.position       = "bottom"
  )



# 1. BASE DEL ANOVA -----------------------------------------------------------

# Mismo armado que el 06: promedio 2015-2024 por país y sector, solo las
# economías presentes los diez años.
base_anova <- mundo |>
  filter(Item_code %in% sectores, Year %in% periodo_analisis) |>
  group_by(Reporter, nombre_pais, Item_code) |>
  summarise(
    anios            = n(),
    valor_medio      = mean(Final_value),
    anios_informados = sum(!is.na(Reported_value)),
    .groups = "drop"
  ) |>
  filter(anios == length(periodo_analisis)) |>
  mutate(sector = factor(Item_code, levels = sectores))

# Control de que la base coincide con la del 06 (200 economías x 12
# sectores, 318 celdas en cero). Si cambia, hay que revisar el 06 también.
stopifnot(nrow(base_anova) == 2400, sum(base_anova$valor_medio == 0) == 318)

# El ANOVA va sobre log(valor), así que los ceros quedan afuera (log(0) no
# existe). Entran en el Kruskal-Wallis, que trabaja con rangos (punto 4).
# Por qué el logaritmo: el valor va de menos de un millón a cientos de miles
# de millones de dólares y la distribución tiene una cola larga a la
# derecha. En niveles, unos pocos países grandes dominarían las medias y
# las varianzas. En logaritmos, el ANOVA compara medias GEOMÉTRICAS: el
# valor de un "país típico" de cada sector.
positivos <- base_anova |>
  filter(valor_medio > 0) |>
  mutate(log_valor = log(valor_medio))

cat("Observaciones del ANOVA:", nrow(positivos), "de", nrow(base_anova),
    "(se excluyen", nrow(base_anova) - nrow(positivos), "ceros)\n")


# 2. DESCRIPTIVOS POR SECTOR --------------------------------------------------

# Intervalo de confianza del 95% de la media del log, con el desvío de cada
# sector (no uno común), y vuelto a millones de USD con exp().
descriptivos <- positivos |>
  group_by(sector) |>
  summarise(
    paises_con_valor = n(),
    media_log        = mean(log_valor),
    sd_log           = sd(log_valor),
    mediana_musd_corrientes     = median(valor_medio),
    .groups = "drop"
  ) |>
  mutate(
    error               = sd_log / sqrt(paises_con_valor),
    media_geom_musd_corrientes     = exp(media_log),
    ic_inferior_musd_corrientes    = exp(media_log - qt(0.975, paises_con_valor - 1) * error),
    ic_superior_musd_corrientes    = exp(media_log + qt(0.975, paises_con_valor - 1) * error)
  ) |>
  left_join(base_anova |>
              group_by(sector) |>
              summarise(paises_con_cero = sum(valor_medio == 0)),
            by = "sector") |>
  mutate(Servicio = unname(etiquetas_servicios[as.character(sector)]), .after = sector) |>
  arrange(desc(media_geom_musd_corrientes)) |>
  select(sector, Servicio, paises_con_valor, paises_con_cero, media_geom_musd_corrientes,
         ic_inferior_musd_corrientes, ic_superior_musd_corrientes, mediana_musd_corrientes, sd_log)

print(descriptivos, width = Inf)


# 3. ANOVA DE UN FACTOR -------------------------------------------------------

# H0: la media del log del valor es igual en los 12 sectores.
# H1: al menos un sector tiene una media distinta.
anova_log  <- aov(log_valor ~ sector, data = positivos)
tabla_aov  <- summary(anova_log)[[1]]
print(tabla_aov)

# Tamaño del efecto (clase 10): eta cuadrado = SC entre / SC total, la parte
# de la variabilidad entre celdas país-sector que explica el sector.
eta2 <- tabla_aov$`Sum Sq`[1] / sum(tabla_aov$`Sum Sq`)
cat("Eta cuadrado:", formato_num(eta2, 3), "\n")


# 4. SUPUESTOS ----------------------------------------------------------------

# Supuesto 1, independencia. NO se cumple: el mismo país aparece en hasta 12
# sectores, y un país grande exporta mucho en casi todos. Las observaciones
# de un mismo país están correlacionadas. No hay test para esto; se controla
# en el punto 6 con un ANOVA que agrega el país como segundo factor.

# Supuesto 2, normalidad de los residuos. Con más de 2.000 observaciones,
# Shapiro-Wilk rechaza ante desvíos chicos; por eso se mira junto con el
# QQ-plot y la asimetría.
residuos <- residuals(anova_log)
shapiro  <- shapiro.test(residuos)
asimetria <- mean((residuos - mean(residuos))^3) / sd(residuos)^3
cat("Shapiro-Wilk W =", formato_num(shapiro$statistic, 3), " p =", formato_p(shapiro$p.value),
    " asimetría =", formato_num(asimetria, 2), "\n")

g_qq <- ggplot(tibble(residuo = residuos), aes(sample = residuo)) +
  stat_qq(alpha = 0.3, size = 0.8) +
  stat_qq_line(color = "firebrick", linewidth = 0.8) +
  labs(title = "Los residuos siguen a la normal en el centro y se apartan en las colas",
       subtitle = paste0("QQ-plot de los residuos del ANOVA de log(valor) por sector. ",
                         "Shapiro-Wilk: p ", formato_p(shapiro$p.value),
                         ", asimetría ", formato_num(asimetria, 2), ".\n",
                         "Abajo a la izquierda, países que exportan muy poco en un sector ",
                         "(los atípicos bajos del 06);\narriba, una cola más corta que la ",
                         "normal. Con n = ", nrow(positivos), ", Shapiro rechaza aun con ",
                         "desvíos chicos."),
       x = "Cuantiles teóricos (normal)", y = "Cuantiles de los residuos",
       caption = paste(fuente, "Valor final, promedio 2015-2024.")) +
  tema_tp

# Supuesto 3, varianzas parecidas. Regla práctica de la clase 10: si el
# desvío más grande dividido el más chico supera 2, conviene Welch. Además,
# test de Levene (H0: varianzas iguales).
cociente_sd <- max(descriptivos$sd_log) / min(descriptivos$sd_log)
levene      <- test_levene(positivos$log_valor, positivos$sector)
cat("Cociente de desvíos:", formato_num(cociente_sd, 2),
    " Levene F =", formato_num(levene$estadistico, 2), " p =", formato_p(levene$p_valor), "\n")

# Criterio fijado ANTES de mirar los p-valores de los tests de medias (clase
# 10, ejercicio 4): si las varianzas no son parecidas, el test principal es
# Welch y las comparaciones de a pares son Games-Howell; si lo son, ANOVA
# clásico y Tukey.
varianzas_distintas <- cociente_sd > 2 || levene$p_valor < 0.05


# 5. ALTERNATIVAS SI FALLAN LOS SUPUESTOS -------------------------------------

# ANOVA de Welch: compara medias sin suponer varianzas iguales.
welch <- oneway.test(log_valor ~ sector, data = positivos, var.equal = FALSE)

# Kruskal-Wallis: compara rangos, así que no necesita normalidad y los ceros
# pueden entrar (un cero es el rango más bajo). Responde si algún sector
# tiende a tener valores más altos. Se corre con y sin ceros.
# Tamaño del efecto: epsilon cuadrado = H / (N - 1).
kw_con_ceros <- kruskal.test(valor_medio ~ sector, data = base_anova)
kw_sin_ceros <- kruskal.test(valor_medio ~ sector, data = positivos)
epsilon2_con <- unname(kw_con_ceros$statistic) / (nrow(base_anova) - 1)
epsilon2_sin <- unname(kw_sin_ceros$statistic) / (nrow(positivos) - 1)


# 6. CONTROL DE INDEPENDENCIA: EL PAÍS COMO SEGUNDO FACTOR --------------------

# El país está CRUZADO con el sector: cada país aparece en varios sectores.
# En el ANOVA de un factor, las diferencias de tamaño entre países van a
# parar al error, que queda inflado. Eso hace al test de un factor
# CONSERVADOR (le cuesta más rechazar), no optimista.
# aov(log_valor ~ pais + sector) saca esa variabilidad del error y mide la
# del sector DESPUÉS de descontar el tamaño de cada país (el orden importa:
# primero pais). Si la diferencia entre sectores fuera solo un efecto del
# tamaño de los países, acá desaparecería.
anova_bloque <- aov(log_valor ~ Reporter + sector, data = positivos)
tabla_bloque <- summary(anova_bloque)[[1]]
print(tabla_bloque)
fila_sector  <- which(trimws(rownames(tabla_bloque)) == "sector")
sc_sector    <- tabla_bloque$`Sum Sq`[fila_sector]
sc_residual  <- tabla_bloque$`Sum Sq`[nrow(tabla_bloque)]
# Dos tamaños del efecto, que no se comparan entre sí:
# - eta cuadrado del sector sobre la SC TOTAL: es el comparable con el eta²
#   del ANOVA de un factor (misma base);
# - eta cuadrado parcial: SC sector / (SC sector + SC residual). Saca al país
#   del denominador, así que siempre da más alto.
eta2_sector_bloque <- sc_sector / sum(tabla_bloque$`Sum Sq`)
eta2_parcial       <- sc_sector / (sc_sector + sc_residual)
eta2_pais          <- tabla_bloque$`Sum Sq`[1] / sum(tabla_bloque$`Sum Sq`)

# Supuestos del modelo con bloque. Con una sola observación por país y
# sector, la interacción país x sector no se puede estimar: el modelo es
# aditivo (supone que la diferencia entre sectores es la misma en todos los
# países). Se revisan sus residuos con los mismos criterios del punto 4.
residuos_bloque  <- residuals(anova_bloque)
shapiro_bloque   <- shapiro.test(residuos_bloque)
asimetria_bloque <- mean((residuos_bloque - mean(residuos_bloque))^3) / sd(residuos_bloque)^3
levene_bloque    <- test_levene(residuos_bloque, positivos$sector)
cociente_bloque  <- max(tapply(residuos_bloque, positivos$sector, sd)) /
  min(tapply(residuos_bloque, positivos$sector, sd))
cat("Residuos del modelo con bloque: Shapiro W =", formato_num(shapiro_bloque$statistic, 3),
    " asimetría =", formato_num(asimetria_bloque, 2),
    " cociente de desvíos =", formato_num(cociente_bloque, 2), "\n")

# Los residuos del modelo con bloque cumplen peor los supuestos que los del
# de un factor. Por eso se agrega su versión por rangos: el test de Friedman,
# que es al ANOVA con bloque lo que el Kruskal-Wallis es al de un factor.
# Ordena los 12 sectores DENTRO de cada país (rango 1 = el sector en que ese
# país exporta menos) y contrasta si algún sector tiende a quedar arriba en
# todos los países. Como compara dentro de cada país, el tamaño del país no
# influye. Necesita los 12 sectores de cada país, así que usa la base con
# ceros (un cero es el rango más bajo de ese país).
# Tamaño del efecto: W de Kendall = chi² / (países x (sectores - 1)), de 0
# (sin acuerdo entre países) a 1 (todos ordenan los sectores igual).
friedman  <- friedman.test(valor_medio ~ sector | Reporter, data = base_anova)
w_kendall <- unname(friedman$statistic) /
  (n_distinct(base_anova$Reporter) * (length(sectores) - 1))

# Resumen de todos los tests en una tabla
tests <- tribble(
  ~test, ~que_contrasta, ~estadistico, ~gl, ~p_valor, ~efecto, ~medida_efecto,
  "ANOVA de un factor", "Medias de log(valor) iguales en los 12 sectores",
    tabla_aov$`F value`[1], paste(tabla_aov$Df, collapse = " y "),
    tabla_aov$`Pr(>F)`[1], eta2, "eta cuadrado",
  "Shapiro-Wilk (residuos)", "Residuos normales",
    unname(shapiro$statistic), "", shapiro$p.value, asimetria, "asimetría",
  "Levene (mediana)", "Varianzas iguales entre sectores",
    levene$estadistico, paste(levene$gl_entre, "y", levene$gl_dentro),
    levene$p_valor, cociente_sd, "desvío máx. / mín.",
  "ANOVA de Welch", "Medias iguales sin suponer varianzas iguales",
    unname(welch$statistic), paste(welch$parameter[1], "y", formato_num(welch$parameter[2], 1)),
    welch$p.value, NA_real_, "no tiene (se usa el eta cuadrado del ANOVA)",
  "Kruskal-Wallis con ceros", "Ningún sector tiende a valores más altos",
    unname(kw_con_ceros$statistic), as.character(kw_con_ceros$parameter),
    kw_con_ceros$p.value, epsilon2_con, "epsilon cuadrado",
  "Kruskal-Wallis sin ceros", "Ídem, solo celdas con valor",
    unname(kw_sin_ceros$statistic), as.character(kw_sin_ceros$parameter),
    kw_sin_ceros$p.value, epsilon2_sin, "epsilon cuadrado",
  "ANOVA con el país como bloque", "Sectores iguales después de descontar el país",
    tabla_bloque$`F value`[fila_sector],
    paste(tabla_bloque$Df[fila_sector], "y", tabla_bloque$Df[nrow(tabla_bloque)]),
    tabla_bloque$`Pr(>F)`[fila_sector], eta2_sector_bloque,
    paste0("eta cuadrado sobre la SC total (comparable con el de un factor); parcial: ",
           formato_num(eta2_parcial, 2)),
  "Shapiro-Wilk (residuos del modelo con bloque)", "Residuos normales",
    unname(shapiro_bloque$statistic), "", shapiro_bloque$p.value, asimetria_bloque,
    "asimetría",
  "Levene (residuos del modelo con bloque)", "Varianzas iguales entre sectores",
    levene_bloque$estadistico, paste(levene_bloque$gl_entre, "y", levene_bloque$gl_dentro),
    levene_bloque$p_valor, cociente_bloque, "desvío máx. / mín.",
  "Friedman (rangos dentro de cada país, con ceros)",
    "Ningún sector tiende a quedar más arriba dentro de cada país",
    unname(friedman$statistic), as.character(friedman$parameter),
    friedman$p.value, w_kendall, "W de Kendall"
)

print(tests |> mutate(p = formato_p(p_valor)) |> select(test, estadistico, gl, p, efecto),
      width = Inf)
cat("Parte de la variabilidad que explica el país (eta cuadrado):", formato_num(eta2_pais, 3), "\n")


# 7. COMPARACIONES DE A PARES -------------------------------------------------

# 12 sectores dan 66 pares. Con 66 tests al 5% sin corregir, aparecerían
# diferencias falsas casi seguro; Tukey y Games-Howell ajustan para que el 5%
# valga para el conjunto. Se usa el que corresponde según el punto 4.
# Las diferencias se pasan a % entre medias geométricas con exp(diff) - 1.
if (varianzas_distintas) {
  metodo_pares <- "Games-Howell"
  pares <- games_howell(positivos$log_valor, positivos$sector) |>
    transmute(sector_1 = group1, sector_2 = group2,
              diff = estimate, lwr = conf.low, upr = conf.high, p_ajustado = p.adj)
} else {
  metodo_pares <- "Tukey"
  pares <- as_tibble(TukeyHSD(anova_log)$sector, rownames = "par") |>
    separate(par, into = c("sector_2", "sector_1"), sep = "-") |>
    transmute(sector_1, sector_2, diff, lwr, upr, p_ajustado = `p adj`)
}

# diff = media de sector_2 - media de sector_1 (en log). Se reordena cada par
# para que sector_2 sea siempre el de media más alta: así la diferencia en %
# se lee "el sector_2 exporta X% más que el sector_1 en un país típico".
comparaciones <- pares |>
  mutate(invertir = diff < 0,
         s1 = if_else(invertir, sector_2, sector_1),
         s2 = if_else(invertir, sector_1, sector_2),
         d  = abs(diff),
         l  = if_else(invertir, -upr, lwr),
         u  = if_else(invertir, -lwr, upr)) |>
  transmute(
    sector_mayor     = s2,
    Servicio_mayor   = unname(etiquetas_servicios[s2]),
    sector_menor     = s1,
    Servicio_menor   = unname(etiquetas_servicios[s1]),
    diferencia_pct   = 100 * (exp(d) - 1),
    ic_inferior_pct  = 100 * (exp(l) - 1),
    ic_superior_pct  = 100 * (exp(u) - 1),
    p_ajustado,
    significativo    = p_ajustado < 0.05,
    metodo           = metodo_pares
  ) |>
  arrange(desc(diferencia_pct))

cat("Comparaciones de a pares con", metodo_pares, ":",
    sum(comparaciones$significativo), "de", nrow(comparaciones),
    "pares difieren al 5%\n")

# Como control, cuántos pares serían significativos con Tukey (supone
# varianzas iguales). Si el número es parecido, la elección no cambia la
# conclusión.
pares_tukey <- sum(TukeyHSD(anova_log)$sector[, "p adj"] < 0.05)
cat("Con Tukey serían", pares_tukey, "pares\n")


# 8. DÓNDE QUEDAN LOS CUATRO PAÍSES DENTRO DE CADA SECTOR ---------------------

# El ANOVA habla de todos los países. Para conectarlo con la hipótesis, el
# percentil de Argentina, Brasil, Chile y Uruguay dentro de cada sector
# (100 = el que más exporta; cuenta los 200 países, ceros incluidos).
# Un cero que el país nunca informó es un faltante completado por OCDE-OMC
# (06, D-026): ahí el percentil 0 no dice que no exporte, y se marca como no
# interpretable (el caso de Chile en cuatro sectores).
posicion_paises <- base_anova |>
  group_by(sector) |>
  mutate(percentil = 100 * percent_rank(valor_medio),
         puesto    = min_rank(desc(valor_medio))) |>
  ungroup() |>
  filter(Reporter %in% names(etiquetas_paises)) |>
  mutate(Pais = unname(etiquetas_paises[Reporter]),
         Servicio = unname(etiquetas_servicios[as.character(sector)]),
         interpretable = !(valor_medio == 0 & anios_informados == 0)) |>
  select(Reporter, Pais, sector, Servicio, valor_medio_musd_corrientes = valor_medio,
         puesto, percentil, anios_informados, interpretable) |>
  arrange(Reporter, sector)

print(posicion_paises |>
        select(Reporter, sector, percentil) |>
        pivot_wider(names_from = Reporter, values_from = percentil))


# 9. GRÁFICOS -----------------------------------------------------------------

# Frase del subtítulo: si los cuatro controles (medias o rangos) coinciden con el
# ANOVA al 5%, se dice; si no, se nombra el que difiere.
coinciden <- c(Welch = welch$p.value, `Kruskal-Wallis` = kw_con_ceros$p.value,
               `el ANOVA con bloque` = tabla_bloque$`Pr(>F)`[fila_sector],
               Friedman = friedman$p.value) < 0.05
conclusion_robustez <- if (all(coinciden == (tabla_aov$`Pr(>F)`[1] < 0.05))) {
  "Welch, Kruskal-Wallis, el ANOVA con el país como bloque y Friedman coinciden."
} else {
  paste("No coincide:", paste(names(coinciden)[coinciden != (tabla_aov$`Pr(>F)`[1] < 0.05)],
                              collapse = ", "))
}

# g1: media geométrica por sector con su IC 95%, más cada país como punto.
orden_sectores <- descriptivos$Servicio
datos_g1 <- positivos |>
  mutate(Servicio = factor(unname(etiquetas_servicios[as.character(sector)]),
                           levels = rev(orden_sectores)))
medias_g1 <- descriptivos |>
  mutate(Servicio = factor(Servicio, levels = rev(orden_sectores)))

# El jitter separa los puntos al azar: con la semilla fija, el gráfico sale
# igual en cada corrida (QA-004, m3).
set.seed(2026)
g_medias <- ggplot() +
  geom_jitter(data = datos_g1, aes(valor_medio, Servicio),
              height = 0.2, alpha = 0.15, size = 0.8, color = "grey40") +
  geom_errorbar(data = medias_g1,
                aes(xmin = ic_inferior_musd_corrientes, xmax = ic_superior_musd_corrientes, y = Servicio),
                width = 0.4, color = "firebrick", linewidth = 0.8,
                orientation = "y") +
  geom_point(data = medias_g1, aes(media_geom_musd_corrientes, Servicio),
             color = "firebrick", size = 2.5) +
  scale_x_log10(breaks = 10^seq(-2, 6, 2),
                labels = label_number(big.mark = ".", decimal.mark = ",",
                                      drop0trailing = TRUE)) +
  labs(title = "El valor que genera un país típico cambia mucho de un sector a otro",
       subtitle = paste0("Media geométrica por sector (rojo) con IC 95%. Cada punto gris ",
                         "es un país. Eje en escala logarítmica.\n",
                         "ANOVA: F = ", formato_num(tabla_aov$`F value`[1], 1), ", p ",
                         formato_p(tabla_aov$`Pr(>F)`[1]), ", eta² = ", formato_num(eta2, 2), ". ",
                         conclusion_robustez),
       x = "Millones de USD corrientes por año (promedio 2015-2024)", y = NULL,
       caption = paste(fuente, "Valor final (informado o estimado por OCDE-OMC). Sin las celdas en cero.")) +
  tema_tp

# g3: matriz de pares. Cada celda dice cuánto más exporta el sector de la
# fila que el de la columna; gris si la diferencia no es significativa.
matriz <- comparaciones |>
  transmute(fila = Servicio_mayor, columna = Servicio_menor,
            diferencia_pct, significativo) |>
  bind_rows(comparaciones |>
              transmute(fila = Servicio_menor, columna = Servicio_mayor,
                        diferencia_pct = -100 * (1 - 1 / (1 + diferencia_pct / 100)),
                        significativo)) |>
  mutate(fila    = factor(fila, levels = rev(orden_sectores)),
         columna = factor(columna, levels = orden_sectores),
         # razón entre medias geométricas (fila / columna), en log2 para que
         # "el doble" y "la mitad" queden a la misma distancia del centro
         log2_razon = log2(1 + diferencia_pct / 100),
         # trimws: format() rellena con espacios para igualar el ancho
         etiqueta = if_else(significativo,
                            if_else(diferencia_pct >= 0,
                                    paste0("x", trimws(formato_num(1 + diferencia_pct / 100, 1))),
                                    paste0("/", trimws(formato_num(1 / (1 + diferencia_pct / 100), 1)))),
                            "n.s."))


g_pares <- ggplot(matriz, aes(columna, fila)) +
  geom_tile(aes(fill = if_else(significativo, log2_razon, NA_real_)),
            color = "white") +
  geom_text(aes(label = etiqueta), size = 2.4) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b",
                       midpoint = 0, na.value = "grey85",
                       breaks = c(-6, -3, 0, 3, 6), labels = etiqueta_razon,
                       name = "Razón fila / columna") +
  scale_x_discrete(labels = function(x) str_wrap(x, 14)) +
  labs(title = paste0(sum(comparaciones$significativo), " de ", nrow(comparaciones),
                      " pares de sectores difieren en el valor de un país típico"),
       subtitle = paste0("Comparaciones de ", metodo_pares,
                         " (5% conjunto). x3,0 = el sector de la fila exporta el triple ",
                         "que el de la columna.\nn.s. = diferencia no significativa. ",
                         "Sectores ordenados de mayor a menor media geométrica."),
       x = NULL, y = NULL,
       caption = paste(fuente, "Valor final, promedio 2015-2024, sin ceros.")) +
  tema_tp +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7),
        axis.text.y = element_text(size = 7),
        panel.grid = element_blank(),
        legend.position = "right")


# 10. GUARDADO ----------------------------------------------------------------

# Los p-valores van como texto: guardar_tabla redondea a 2 decimales y un
# p de 1e-50 quedaría como "0", que no es un p-valor posible.
guardar_tabla(descriptivos,    "output/tablas/08_descriptivos_sectores.csv")
guardar_tabla(tests |> mutate(p_valor = formato_p(p_valor)),
              "output/tablas/08_tests.csv")
guardar_tabla(comparaciones |> mutate(p_ajustado = formato_p(p_ajustado)),
              "output/tablas/08_comparaciones_pares.csv")
guardar_tabla(posicion_paises, "output/tablas/08_posicion_paises.csv")

ggsave("output/graficos/08_g1_medias_sectores.png", g_medias,
       width = 10, height = 6.5, dpi = 300, bg = "white")
ggsave("output/graficos/08_g2_qq_residuos.png", g_qq,
       width = 8, height = 6, dpi = 300, bg = "white")
ggsave("output/graficos/08_g3_pares_sectores.png", g_pares,
       width = 11, height = 8.5, dpi = 300, bg = "white")

cat("Listo: 4 tablas y 3 gráficos del script 08.\n")
