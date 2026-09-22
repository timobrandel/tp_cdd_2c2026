# -----------------------------------------------------------------
# Script      04_comparacion_medidas.R
# Objetivo    Comparar las dos medidas del valor exportado (valor final
#             informado por cada país y valor balanceado de OCDE-OMC) y
#             ver qué afirmaciones del análisis exploratorio se mantienen
#             con cada una
# Entrada     input/batis_filtrada.csv
# Salida      output/tablas/04_*.csv (formato Excel argentino)
#             output/graficos/04_g1 a 04_g3 (.png)
# -----------------------------------------------------------------
# Requiere haber corrido antes 01_filtrado_batis.R.
# 03_exploracion.R analiza con una sola medida, el valor final (D-015).
# Este script calcula las mismas métricas con las dos medidas a la vez y,
# al final, chequea con cada una las afirmaciones de la presentación de la
# Instancia 1 (decisión D-019). Todos los valores están en millones de USD
# CORRIENTES, sin deflactar.

library(tidyverse)
library(scales)   # formato de los números en ejes y textos

source("utils/tasa_anual_compuesta.R")  # ritmo anual equivalente
source("utils/guardar_tabla.R")         # tablas listas para Excel argentino

dir.create("output/tablas",   recursive = TRUE, showWarnings = FALSE)
dir.create("output/graficos", recursive = TRUE, showWarnings = FALSE)

batis <- read_csv(
  "input/batis_filtrada.csv",
  col_types = cols(
    Reporter = col_character(), type_Reporter = col_character(),
    Partner = col_character(), type_Partner = col_character(),
    Flow = col_character(), Item_code = col_character(),
    type_Item = col_character(), Year = col_integer(),
    Reported_value = col_double(), Final_value = col_double(),
    Final_value_methodology = col_character(), Balanced_value = col_double()
  )
)

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

etiquetas_medidas <- c(
  final      = "Valor final (informado por cada país)",
  balanceado = "Valor balanceado (OCDE-OMC)"
)

# Formato argentino (punto de miles, coma decimal) para los ejes y para las
# cifras que van dentro de los textos del resumen (sección 8)
formato_ar   <- label_number(big.mark = ".", decimal.mark = ",")
formato_1d   <- label_number(accuracy = 0.1, big.mark = ".", decimal.mark = ",")
formato_part <- label_number(accuracy = 0.1, big.mark = ".", decimal.mark = ",",
                             suffix = "%")
formato_var  <- label_number(accuracy = 0.1, big.mark = ".", decimal.mark = ",",
                             suffix = "%", style_positive = "plus")
formato_pp   <- label_number(accuracy = 0.1, big.mark = ".", decimal.mark = ",",
                             suffix = " pp", style_positive = "plus")

# Colores de las medidas: azul y naranja, validados para lectores con
# daltonismo. Además del color, cada medida tiene su tipo de línea y de punto.
colores_medidas <- c(final = "#2a78d6", balanceado = "#eb6834")
lineas_medidas  <- c(final = "solid",   balanceado = "dashed")
puntos_medidas  <- c(final = 16,        balanceado = 17)

fuente <- paste0("Fuente: elaboración propia con datos de OECD-WTO BaTIS ",
                 "(BPM6, versión dic. 2025). Chile 2023-2024: estimaciones de OCDE-OMC.")

# Mismo tema que 03: nota al pie alineada a la izquierda y leyenda abajo
tema_tp <- theme_minimal() +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.caption          = element_text(hjust = 0, size = 8, color = "grey30"),
    legend.position       = "bottom"
  )


# 0. FORMATO LARGO: LAS DOS MEDIDAS EN UNA SOLA COLUMNA ---------------------
# En la base, cada medida es una columna (Final_value y Balanced_value). Acá
# se apilan: cada fila país × año × categoría aparece dos veces, una por
# medida, con el número en `valor` y el nombre de la medida en `medida`.
# Así cada métrica se escribe una sola vez, agrupando también por medida, y
# las dos versiones quedan en la misma tabla, listas para comparar.
batis_largo <- batis |>
  mutate(Pais = factor(unname(etiquetas_paises[Reporter]),
                       levels = unname(etiquetas_paises))) |>
  select(Pais, Year, Item_code, Final_value, Balanced_value) |>
  pivot_longer(c(Final_value, Balanced_value),
               names_to = "medida", values_to = "valor") |>
  mutate(medida = factor(if_else(medida == "Final_value", "final", "balanceado"),
                         levels = c("final", "balanceado")))

# Control: 1.040 filas × 2 medidas = 2.080 filas, sin faltantes
stopifnot(nrow(batis_largo) == 2 * nrow(batis), !anyNA(batis_largo$valor))


# 1. TOTAL DE SERVICIOS: NIVEL, TASA DE VARIACIÓN E ÍNDICE ------------------
# Mismas definiciones que en 03 (ítem S = total de servicios), para cada medida.
total <- batis_largo |>
  filter(Item_code == "S") |>
  select(medida, Pais, Year, valor) |>
  arrange(medida, Pais, Year) |>
  group_by(medida, Pais) |>
  mutate(
    tasa_var    = (valor / lag(valor) - 1) * 100,
    indice_2005 = valor / valor[Year == 2005] * 100
  ) |>
  ungroup()

# diferencia_pct: cuánto se aparta el balanceado del final, en % (misma
# definición que 03_brecha_anual; arriba de 0, el balanceado es mayor).
tabla_total <- total |>
  pivot_wider(names_from = medida, values_from = c(valor, indice_2005, tasa_var)) |>
  mutate(diferencia_pct = (valor_balanceado / valor_final - 1) * 100,
         .after = valor_balanceado)


# 2. TAMAÑO: DESCRIPTIVOS DEL NIVEL Y ARGENTINA VS. CHILE -------------------
descriptivos_nivel <- total |>
  group_by(medida, Pais) |>
  summarise(
    media          = mean(valor),
    mediana        = median(valor),
    desvio         = sd(valor),
    coef_variacion = desvio / media,
    minimo         = min(valor),
    anio_minimo    = Year[which.min(valor)],
    maximo         = max(valor),
    anio_maximo    = Year[which.max(valor)],
    .groups = "drop"
  )

# Cuánto más grande es el sector exportador argentino que el chileno (%),
# año por año y con cada medida.
argentina_vs_chile <- total |>
  filter(Pais %in% c("Argentina", "Chile")) |>
  select(medida, Pais, Year, valor) |>
  pivot_wider(names_from = Pais, values_from = valor) |>
  mutate(argentina_sobre_chile_pct = (Argentina / Chile - 1) * 100)

print(descriptivos_nivel, width = Inf)


# 3. CRECIMIENTO 2005-2024 Y 2005-2022 --------------------------------------
# 2005-2022 se agrega porque en Chile 2023 y 2024 son estimaciones. El
# puesto ordena a los países de mayor a menor crecimiento dentro de cada
# medida (1 = el que más creció).
crecimiento <- total |>
  group_by(medida, Pais) |>
  summarise(
    crecimiento_acumulado_2005_2024_pct = (valor[Year == 2024] / valor[Year == 2005] - 1) * 100,
    tasa_anual_compuesta_2005_2024_pct  = tasa_anual_compuesta(valor[Year == 2005], valor[Year == 2024], 19),
    tasa_anual_compuesta_2005_2022_pct  = tasa_anual_compuesta(valor[Year == 2005], valor[Year == 2022], 17),
    .groups = "drop"
  ) |>
  group_by(medida) |>
  mutate(
    puesto_2005_2024 = min_rank(desc(tasa_anual_compuesta_2005_2024_pct)),
    puesto_2005_2022 = min_rank(desc(tasa_anual_compuesta_2005_2022_pct))
  ) |>
  ungroup()

print(crecimiento, width = Inf)


# 4. VOLATILIDAD Y ATÍPICOS DE LAS TASAS DE VARIACIÓN -----------------------
tasas <- total |> filter(!is.na(tasa_var))

# Atípicos según la regla del boxplot (más de 1,5 rangos intercuartiles por
# fuera de la caja), dentro de cada país y medida, como en 03.
atipicos <- tasas |>
  group_by(medida, Pais) |>
  filter(tasa_var %in% boxplot.stats(tasa_var)$out) |>
  ungroup() |>
  select(medida, Pais, Year, tasa_var)

volatilidad <- tasas |>
  group_by(medida, Pais) |>
  summarise(
    media           = mean(tasa_var),
    mediana         = median(tasa_var),
    desvio          = sd(tasa_var),
    anios_negativos = sum(tasa_var < 0),
    .groups = "drop"
  ) |>
  left_join(
    atipicos |>
      group_by(medida, Pais) |>
      summarise(anios_atipicos = paste(Year, collapse = ", "), .groups = "drop"),
    by = c("medida", "Pais")
  ) |>
  mutate(anios_atipicos = replace_na(anios_atipicos, "ninguno"))

print(volatilidad, width = Inf)


# 5. PANDEMIA ---------------------------------------------------------------
# La recuperación se mide contra 2019, el nivel previo al shock (como en 03).
pandemia <- total |>
  group_by(medida, Pais) |>
  summarise(
    caida_2020_vs_2019_pct = (valor[Year == 2020] / valor[Year == 2019] - 1) * 100,
    nivel_2024_vs_2019_pct = (valor[Year == 2024] / valor[Year == 2019] - 1) * 100,
    .groups = "drop"
  )

print(pandemia, width = Inf)


# 6. COMPOSICIÓN: PARTICIPACIÓN DE CADA CATEGORÍA EN EL TOTAL ---------------
componentes <- batis_largo |>
  filter(Item_code != "S") |>
  left_join(total |> select(medida, Pais, Year, total = valor),
            by = c("medida", "Pais", "Year")) |>
  mutate(
    participacion = valor / total * 100,
    Servicio = factor(unname(etiquetas_servicios[Item_code]),
                      levels = unname(etiquetas_servicios))
  )

# Control: con las dos medidas, las 12 categorías suman el total (100%).
# Si no fuera así, las participaciones de una medida y otra no serían
# comparables.
suma_participaciones <- componentes |>
  group_by(medida, Pais, Year) |>
  summarise(suma = sum(participacion), .groups = "drop")

cat("Suma de participaciones por medida (debería ser 100):\n")
print(suma_participaciones |>
        group_by(medida) |>
        summarise(minimo = min(suma), maximo = max(suma)))
stopifnot(all(abs(suma_participaciones$suma - 100) < 0.001))

# Participación de cada categoría en 2005 y 2024, y su cambio en puntos
# porcentuales (pp)
composicion <- componentes |>
  filter(Year %in% c(2005, 2024)) |>
  select(medida, Pais, Item_code, Servicio, Year, participacion) |>
  pivot_wider(names_from = Year, values_from = participacion,
              names_prefix = "part_") |>
  mutate(cambio_pp = part_2024 - part_2005)

# ¿El cambio 2005-2024 de cada categoría va en la misma dirección con las
# dos medidas? Una categoría que en cero con el final y positiva con el
# balanceado (las 4 que Chile no informa) cuenta como dirección distinta.
tabla_composicion <- composicion |>
  pivot_wider(names_from = medida, values_from = c(part_2005, part_2024, cambio_pp)) |>
  mutate(misma_direccion = if_else(sign(cambio_pp_final) == sign(cambio_pp_balanceado),
                                   "Sí", "No")) |>
  arrange(Pais, desc(part_2024_final))

cat("Pares país-categoría con distinta dirección del cambio 2005-2024:",
    sum(tabla_composicion$misma_direccion == "No"), "de", nrow(tabla_composicion), "\n")

# "Conocimiento" = Telecom., informática e información (SI) + Otros
# servicios empresariales (SJ), como en 03.
conocimiento <- composicion |>
  filter(Item_code %in% c("SI", "SJ")) |>
  group_by(medida, Pais) |>
  summarise(across(c(part_2005, part_2024, cambio_pp), sum), .groups = "drop")

# Concentración de la canasta: peso de las 3 categorías más grandes (a
# mayor valor, canasta más concentrada) y categoría principal de 2024.
concentracion <- componentes |>
  filter(Year %in% c(2005, 2024)) |>
  group_by(medida, Pais, Year) |>
  summarise(top3 = sum(sort(participacion, decreasing = TRUE)[1:3]),
            .groups = "drop") |>
  pivot_wider(names_from = Year, values_from = top3, names_prefix = "top3_") |>
  mutate(cambio_pp = top3_2024 - top3_2005) |>
  left_join(
    componentes |>
      filter(Year == 2024) |>
      group_by(medida, Pais) |>
      summarise(
        categoria_principal_2024     = as.character(Servicio[which.max(participacion)]),
        participacion_principal_2024 = max(participacion),
        .groups = "drop"
      ),
    by = c("medida", "Pais")
  )

print(conocimiento, width = Inf)
print(concentracion, width = Inf)


# 7. DISTRIBUCIÓN DE LOS VALORES POR CATEGORÍA ------------------------------
# Las 960 filas de categorías, sin el total S, como en 03. Con el valor
# final hay ceros; con el balanceado, OCDE-OMC asigna valores positivos
# incluso a las categorías que Chile no informa.
distribucion <- batis_largo |>
  filter(Item_code != "S") |>
  group_by(medida) |>
  summarise(
    n                 = n(),
    media             = mean(valor),
    mediana           = median(valor),
    desvio            = sd(valor),
    minimo            = min(valor),
    maximo            = max(valor),
    valores_cero      = sum(valor == 0),
    valores_positivos = sum(valor > 0)
  )

print(distribucion, width = Inf)


# 8. RESUMEN: ¿CADA AFIRMACIÓN SE MANTIENE CON LAS DOS MEDIDAS? -------------
# Las afirmaciones son los hallazgos de la presentación de la Instancia 1,
# que se armó con el valor final. Para cada una se calcula, con cada medida,
# la cifra que la respalda (`valor`, en texto) y si se cumple (`cumple`),
# según el criterio escrito en la columna `criterio`.
afirmaciones <- tribble(
  ~id, ~hallazgo, ~afirmacion, ~indicador, ~criterio,
  "1.1", "1. Giro hacia el conocimiento (diap. 10)",
  "Otros servicios empresariales gana peso en los cuatro países",
  "Cambio de su participación 2005-2024", "Sube en los cuatro países",
  "1.2", "1. Giro hacia el conocimiento (diap. 10)",
  "Telecom., informática e información gana peso en los cuatro países",
  "Cambio de su participación 2005-2024", "Sube en los cuatro países",
  "1.3", "1. Giro hacia el conocimiento (diap. 10)",
  "Transporte pierde peso en los cuatro países",
  "Cambio de su participación 2005-2024", "Baja en los cuatro países",
  "1.4", "1. Giro hacia el conocimiento (diap. 10)",
  "Viajes pierde peso en Argentina, Brasil y Uruguay; en Chile gana",
  "Cambio de su participación 2005-2024", "Baja en Argentina, Brasil y Uruguay, y sube en Chile",
  "1.5", "1. Giro hacia el conocimiento (diap. 10)",
  "En Argentina, conocimiento pasa a ser más de la mitad de lo que exporta",
  "Participación de conocimiento (SI + SJ) de Argentina", "Mayor que 50% en 2024",
  "1.6", "1. Giro hacia el conocimiento (diap. 10)",
  "Uruguay tuvo la mayor transformación hacia conocimiento",
  "Cambio de la participación de conocimiento 2005-2024", "El mayor aumento es el de Uruguay",
  "1.7", "1. Giro hacia el conocimiento (diap. 10)",
  "En Argentina, otros servicios empresariales ya supera a viajes",
  "Categoría principal de Argentina en 2024 y su participación", "La principal es otros servicios empresariales",
  "1.8", "1. Giro hacia el conocimiento (diap. 10)",
  "La canasta se diversificó en los cuatro países",
  "Cambio del peso de las 3 categorías más grandes, 2005-2024", "Baja en los cuatro países",
  "2.1", "2. Argentina creció menos que Uruguay y Brasil (diap. 6 y 7)",
  "Argentina es tercera en crecimiento, detrás de Uruguay y Brasil",
  "Tasa anual compuesta 2005-2024, de mayor a menor", "Orden: Uruguay, Brasil, Argentina, Chile",
  "2.2", "2. Argentina creció menos que Uruguay y Brasil (diap. 6 y 7)",
  "El orden no cambia si se mira solo 2005-2022 (años que Chile informó)",
  "Tasa anual compuesta 2005-2022, de mayor a menor", "Mismo orden que en 2005-2024 con la misma medida",
  "2.3", "2. Argentina creció menos que Uruguay y Brasil (diap. 6 y 7)",
  "Desde 2006, Argentina exporta más que Chile todos los años",
  "Años de 2006-2024 en que Argentina supera a Chile y rango de la diferencia", "Los 19 años",
  "2.4", "2. Argentina creció menos que Uruguay y Brasil (diap. 6 y 7)",
  "Chile tocó su máximo en 2011 y no lo volvió a superar",
  "Año del máximo de Chile", "2011",
  "3.1", "3. La media engaña: Argentina es la que más veces cae (diap. 8 y 9)",
  "Argentina tiene la mediana de crecimiento anual más baja",
  "Mediana de la variación interanual, 2006-2024", "La menor es la de Argentina",
  "3.2", "3. La media engaña: Argentina es la que más veces cae (diap. 8 y 9)",
  "Argentina es el país con más años de caída",
  "Años con variación interanual negativa (de 19)", "Argentina tiene más que cada uno de los otros",
  "3.3", "3. La media engaña: Argentina es la que más veces cae (diap. 8 y 9)",
  "Los únicos años atípicos son de Argentina: 2020 y 2022",
  "Años atípicos (regla del boxplot, 1,5 rangos intercuartiles)", "Solo Argentina 2020 y 2022",
  "3.4", "3. La media engaña: Argentina es la que más veces cae (diap. 8 y 9)",
  "El desvío de Argentina no es el más alto: Uruguay y Chile oscilan más",
  "Desvío de la variación interanual (puntos porcentuales)", "Uruguay y Chile, mayores que Argentina",
  "4.1", "4. Pandemia: mayor caída y menor recuperación (diap. 9)",
  "Argentina tuvo la mayor caída en 2020",
  "Variación 2020 contra 2019", "La mayor caída es la de Argentina",
  "4.2", "4. Pandemia: mayor caída y menor recuperación (diap. 9)",
  "Argentina tuvo la menor recuperación",
  "Variación 2024 contra 2019", "La menor es la de Argentina",
  "D.1", "Distribución de la variable principal (diap. 4)",
  "Los valores por categoría tienen una distribución muy asimétrica a la derecha",
  "Media y mediana de las 960 filas de categorías (millones de USD)", "Media mayor que el doble de la mediana",
  "D.2", "Distribución de la variable principal (diap. 4)",
  "Hay 150 valores en cero, que quedan fuera del histograma en escala logarítmica",
  "Cantidad de valores en cero (de 960)", "150"
)

chequeos <- bind_rows(
  # 1.1 a 1.4: dirección del cambio 2005-2024 de una categoría, por país
  composicion |>
    filter(Item_code == "SJ") |>
    group_by(medida) |>
    summarise(id = "1.1",
              valor = paste(Pais, formato_pp(cambio_pp), collapse = "; "),
              cumple = all(cambio_pp > 0)),
  composicion |>
    filter(Item_code == "SI") |>
    group_by(medida) |>
    summarise(id = "1.2",
              valor = paste(Pais, formato_pp(cambio_pp), collapse = "; "),
              cumple = all(cambio_pp > 0)),
  composicion |>
    filter(Item_code == "SC") |>
    group_by(medida) |>
    summarise(id = "1.3",
              valor = paste(Pais, formato_pp(cambio_pp), collapse = "; "),
              cumple = all(cambio_pp < 0)),
  composicion |>
    filter(Item_code == "SD") |>
    group_by(medida) |>
    summarise(id = "1.4",
              valor = paste(Pais, formato_pp(cambio_pp), collapse = "; "),
              cumple = all(cambio_pp[Pais != "Chile"] < 0) & cambio_pp[Pais == "Chile"] > 0),
  # 1.5 y 1.6: participación de conocimiento
  conocimiento |>
    filter(Pais == "Argentina") |>
    group_by(medida) |>
    summarise(id = "1.5",
              valor = paste(formato_part(part_2005), "en 2005 y",
                            formato_part(part_2024), "en 2024"),
              cumple = part_2024 > 50),
  conocimiento |>
    group_by(medida) |>
    summarise(id = "1.6",
              valor = paste(Pais, formato_pp(cambio_pp), collapse = "; "),
              cumple = Pais[which.max(cambio_pp)] == "Uruguay"),
  # 1.7: categoría principal de Argentina en 2024
  concentracion |>
    filter(Pais == "Argentina") |>
    group_by(medida) |>
    summarise(id = "1.7",
              valor = paste0(categoria_principal_2024, " (",
                             formato_part(participacion_principal_2024), ")"),
              cumple = categoria_principal_2024 == "Otros servicios empresariales"),
  # 1.8: diversificación (baja el peso de las 3 categorías más grandes)
  concentracion |>
    group_by(medida) |>
    summarise(id = "1.8",
              valor = paste(Pais, formato_pp(cambio_pp), collapse = "; "),
              cumple = all(cambio_pp < 0)),
  # 2.1 y 2.2: orden de crecimiento
  crecimiento |>
    group_by(medida) |>
    arrange(puesto_2005_2024, .by_group = TRUE) |>
    summarise(id = "2.1",
              valor = paste(Pais, formato_var(tasa_anual_compuesta_2005_2024_pct),
                            collapse = " > "),
              cumple = identical(as.character(Pais),
                                 c("Uruguay", "Brasil", "Argentina", "Chile"))),
  crecimiento |>
    group_by(medida) |>
    arrange(puesto_2005_2022, .by_group = TRUE) |>
    summarise(id = "2.2",
              valor = paste(Pais, formato_var(tasa_anual_compuesta_2005_2022_pct),
                            collapse = " > "),
              cumple = all(puesto_2005_2022 == puesto_2005_2024)),
  # 2.3: Argentina contra Chile desde 2006
  argentina_vs_chile |>
    filter(Year >= 2006) |>
    group_by(medida) |>
    summarise(id = "2.3",
              valor = paste0(sum(argentina_sobre_chile_pct > 0), " de ", n(),
                             " años; diferencia entre ",
                             formato_var(min(argentina_sobre_chile_pct)), " y ",
                             formato_var(max(argentina_sobre_chile_pct))),
              cumple = all(argentina_sobre_chile_pct > 0)),
  # 2.4: año del máximo de Chile
  descriptivos_nivel |>
    filter(Pais == "Chile") |>
    group_by(medida) |>
    summarise(id = "2.4",
              valor = as.character(anio_maximo),
              cumple = anio_maximo == 2011),
  # 3.1 a 3.4: volatilidad de las tasas de variación
  volatilidad |>
    group_by(medida) |>
    summarise(id = "3.1",
              valor = paste(Pais, formato_var(mediana), collapse = "; "),
              cumple = Pais[which.min(mediana)] == "Argentina"),
  volatilidad |>
    group_by(medida) |>
    summarise(id = "3.2",
              valor = paste(Pais, anios_negativos, collapse = "; "),
              cumple = anios_negativos[Pais == "Argentina"] >
                       max(anios_negativos[Pais != "Argentina"])),
  # .drop = FALSE: si una medida no tuviera atípicos, igual aparece su fila
  atipicos |>
    group_by(medida, .drop = FALSE) |>
    summarise(id = "3.3",
              valor = paste(Pais, Year, collapse = "; "),
              cumple = setequal(paste(Pais, Year), c("Argentina 2020", "Argentina 2022"))),
  volatilidad |>
    group_by(medida) |>
    summarise(id = "3.4",
              valor = paste(Pais, formato_1d(desvio), collapse = "; "),
              cumple = desvio[Pais == "Uruguay"] > desvio[Pais == "Argentina"] &
                       desvio[Pais == "Chile"] > desvio[Pais == "Argentina"]),
  # 4.1 y 4.2: pandemia
  pandemia |>
    group_by(medida) |>
    summarise(id = "4.1",
              valor = paste(Pais, formato_var(caida_2020_vs_2019_pct), collapse = "; "),
              cumple = Pais[which.min(caida_2020_vs_2019_pct)] == "Argentina"),
  pandemia |>
    group_by(medida) |>
    summarise(id = "4.2",
              valor = paste(Pais, formato_var(nivel_2024_vs_2019_pct), collapse = "; "),
              cumple = Pais[which.min(nivel_2024_vs_2019_pct)] == "Argentina"),
  # D.1 y D.2: distribución de los valores por categoría
  distribucion |>
    group_by(medida) |>
    summarise(id = "D.1",
              valor = paste0("media ", formato_1d(media), "; mediana ", formato_1d(mediana)),
              cumple = media > 2 * mediana),
  distribucion |>
    group_by(medida) |>
    summarise(id = "D.2",
              valor = as.character(valores_cero),
              cumple = valores_cero == 150)
)

resumen <- afirmaciones |>
  left_join(
    chequeos |>
      mutate(valor  = if_else(valor == "", "ninguno", valor),
             cumple = if_else(cumple, "Sí", "No")) |>
      pivot_wider(names_from = medida, values_from = c(valor, cumple)),
    by = "id"
  ) |>
  select(id, hallazgo, afirmacion, indicador, valor_final, valor_balanceado,
         criterio, se_cumple_con_final = cumple_final,
         se_cumple_con_balanceado = cumple_balanceado)

# Control: cada afirmación tiene su cifra y su resultado con las dos medidas
stopifnot(nrow(resumen) == nrow(afirmaciones), !anyNA(resumen))

cat("\nAfirmaciones que se cumplen, de", nrow(resumen), ":",
    "con el valor final", sum(resumen$se_cumple_con_final == "Sí"),
    "/ con el valor balanceado", sum(resumen$se_cumple_con_balanceado == "Sí"), "\n")
print(select(resumen, id, afirmacion, se_cumple_con_final, se_cumple_con_balanceado),
      n = Inf, width = Inf)


# 9. GRÁFICOS ---------------------------------------------------------------

# 9.1 Nivel del total con las dos medidas, un panel por país. Cada panel
# tiene su propia escala: se compara la distancia entre las dos líneas
# dentro de cada país (entre países, ver 03_g1).
g_niveles <- ggplot(total, aes(x = Year, y = valor, color = medida,
                               linetype = medida, shape = medida)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.8) +
  facet_wrap(~ Pais, scales = "free_y") +
  scale_y_continuous(labels = formato_ar) +
  scale_color_manual(values = colores_medidas, labels = etiquetas_medidas) +
  scale_linetype_manual(values = lineas_medidas, labels = etiquetas_medidas) +
  scale_shape_manual(values = puntos_medidas, labels = etiquetas_medidas) +
  labs(
    title = "Exportaciones de servicios con las dos medidas, 2005-2024",
    subtitle = "Millones de USD corrientes. Cada panel tiene su propia escala",
    x = NULL, y = NULL, color = NULL, linetype = NULL, shape = NULL,
    caption = str_wrap(fuente, 120)
  ) +
  tema_tp

# 9.2 Composición 2024 con las dos medidas: un punto por medida y una línea
# gris que los une, para ver la distancia entre las dos en cada categoría.
g_composicion <- ggplot(filter(componentes, Year == 2024),
                        aes(x = participacion, y = fct_rev(Servicio))) +
  geom_line(aes(group = Servicio), color = "grey75", linewidth = 0.8) +
  geom_point(aes(color = medida, shape = medida), size = 2.3) +
  facet_wrap(~ Pais, nrow = 1) +
  scale_color_manual(values = colores_medidas, labels = etiquetas_medidas) +
  scale_shape_manual(values = puntos_medidas, labels = etiquetas_medidas) +
  labs(
    title = "Composición de las exportaciones de servicios en 2024, con las dos medidas",
    subtitle = "Participación de cada categoría en el total exportado por cada país (%)",
    x = "%", y = NULL, color = NULL, shape = NULL,
    caption = str_wrap(fuente, 150)
  ) +
  tema_tp

# 9.3 Peso de conocimiento en 2005 y 2024, con las dos medidas. Resume en un
# gráfico qué es robusto y qué no: con las dos medidas la línea sube en los
# cuatro países (la dirección se mantiene), pero con el balanceado queda más
# abajo (el nivel depende de la medida). Tamaño pensado para una diapositiva.
conocimiento_largo <- conocimiento |>
  select(medida, Pais, part_2005, part_2024) |>
  pivot_longer(c(part_2005, part_2024), names_to = "Year",
               names_prefix = "part_", values_to = "participacion")

g_conocimiento <- ggplot(conocimiento_largo,
                         aes(x = Year, y = participacion, group = medida,
                             color = medida, linetype = medida, shape = medida)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.2) +
  # Rótulo solo en 2024, donde las dos medidas se separan más. Va en gris:
  # la medida se identifica por el color de la línea y la leyenda.
  geom_text(data = filter(conocimiento_largo, Year == "2024"),
            aes(label = formato_part(participacion)),
            color = "grey20", hjust = -0.3, size = 3, show.legend = FALSE) +
  facet_wrap(~ Pais, nrow = 1) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), limits = c(0, 60)) +
  scale_x_discrete(expand = expansion(add = c(0.3, 1))) +
  scale_color_manual(values = colores_medidas, labels = etiquetas_medidas) +
  scale_linetype_manual(values = lineas_medidas, labels = etiquetas_medidas) +
  scale_shape_manual(values = puntos_medidas, labels = etiquetas_medidas) +
  labs(
    title = "Peso de los servicios de conocimiento, 2005 y 2024",
    subtitle = "Telecom., informática e información + otros servicios empresariales (% del total)",
    x = NULL, y = NULL, color = NULL, linetype = NULL, shape = NULL,
    caption = str_wrap(fuente, 100)
  ) +
  tema_tp


# 10. GUARDADO --------------------------------------------------------------
# Tablas anchas: cada métrica con su versión final y balanceada, una al lado
# de la otra (sufijos _final y _balanceado).
guardar_tabla(tabla_total, "output/tablas/04_total_por_anio.csv")
guardar_tabla(pivot_wider(descriptivos_nivel, names_from = medida, values_from = !c(medida, Pais)),
              "output/tablas/04_descriptivos_nivel.csv")
guardar_tabla(pivot_wider(argentina_vs_chile, names_from = medida,
                          values_from = c(Argentina, Chile, argentina_sobre_chile_pct)),
              "output/tablas/04_argentina_vs_chile.csv")
guardar_tabla(pivot_wider(crecimiento, names_from = medida, values_from = !c(medida, Pais)),
              "output/tablas/04_crecimiento.csv")
guardar_tabla(pivot_wider(volatilidad, names_from = medida, values_from = !c(medida, Pais)),
              "output/tablas/04_volatilidad.csv")
guardar_tabla(pivot_wider(pandemia, names_from = medida, values_from = !c(medida, Pais)),
              "output/tablas/04_pandemia.csv")
guardar_tabla(tabla_composicion, "output/tablas/04_composicion.csv")
guardar_tabla(pivot_wider(conocimiento, names_from = medida, values_from = !c(medida, Pais)),
              "output/tablas/04_conocimiento.csv")
guardar_tabla(pivot_wider(concentracion, names_from = medida, values_from = !c(medida, Pais)),
              "output/tablas/04_concentracion.csv")
guardar_tabla(distribucion, "output/tablas/04_distribucion.csv")
guardar_tabla(resumen,      "output/tablas/04_resumen_hallazgos.csv")

ggsave("output/graficos/04_g1_niveles_final_vs_balanceado.png", g_niveles,
       width = 9, height = 6.5, dpi = 200, bg = "white")
ggsave("output/graficos/04_g2_composicion_2024_final_vs_balanceado.png", g_composicion,
       width = 12, height = 6.5, dpi = 200, bg = "white")
ggsave("output/graficos/04_g3_conocimiento_final_vs_balanceado.png", g_conocimiento,
       width = 7.2, height = 4.4, dpi = 200, bg = "white")
