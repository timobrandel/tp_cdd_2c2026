# -----------------------------------------------------------------
# Script      03_exploracion.R
# Objetivo    Explorar las exportaciones de servicios de Argentina, Brasil,
#             Chile y Uruguay (2005-2024): nivel, evolución, volatilidad,
#             composición, relación entre países y calidad del dato
# Entrada     input/batis_filtrada.csv
# Salida      output/tablas/03_*.csv (formato Excel argentino)
#             output/graficos/03_g1 a 03_g7 (.png)
# -----------------------------------------------------------------
# Requiere haber corrido antes 01_filtrado_batis.R.
# La variable principal se elige en `variable_principal` (sección 0; ver
# decisión D-015). Todos los valores están en millones de USD CORRIENTES:
# como no están deflactados, los crecimientos incluyen la inflación de
# EE.UU. (se deflacta en la Instancia 2, con herramientas de la Unidad 3).

library(tidyverse)
library(scales)   # formato de los números en los ejes

source("utils/clasificar_origen.R")     # informado / derivado / estimado
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


# 0. VARIABLE PRINCIPAL (D-015) ---------------------------------------------
# Dos medidas posibles del valor exportado:
# - "Final_value": lo que cada país informa a su balanza de pagos, completado
#   con estimaciones de OCDE-OMC donde falta el dato.
# - "Balanced_value": el valor conciliado con lo que declaran los países
#   socios como importaciones (garantiza que X de A a B = M de B desde A).
# Cambiando esta línea se rehace todo el análisis con la otra medida.
variable_principal <- "Final_value"

etiqueta_medida <- if (variable_principal == "Final_value") {
  "valor final informado por cada país"
} else {
  "valor balanceado OCDE-OMC"
}

batis <- batis |>
  mutate(
    Pais = factor(unname(etiquetas_paises[Reporter]),
                  levels = unname(etiquetas_paises)),
    valor_principal = .data[[variable_principal]],
    origen = clasificar_origen(Final_value_methodology)
  )

# Formato argentino para los ejes: punto de miles, coma decimal
formato_ar <- label_number(big.mark = ".", decimal.mark = ",")

# Nota al pie: fuente y medida. La unidad de cada gráfico va en su subtítulo
# (no todos están en USD: hay índices y porcentajes).
fuente <- paste0("Fuente: elaboración propia con datos de OECD-WTO BaTIS ",
                 "(BPM6, versión dic. 2025). Medida: ", etiqueta_medida, ". ",
                 "Chile 2023-2024: estimaciones de OCDE-OMC.")

# Tema común: nota al pie alineada a la izquierda de todo el gráfico (no del
# panel), así la leyenda no la corta; leyenda abajo para dar ancho al panel.
tema_tp <- theme_minimal() +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.caption          = element_text(hjust = 0, size = 8, color = "grey30"),
    legend.position       = "bottom"
  )


# 1. TOTAL DE SERVICIOS: NIVEL, TASA DE VARIACIÓN E ÍNDICE ------------------

# El total de servicios es el ítem S. Tres miradas complementarias:
# - nivel: tamaño del sector exportador de cada país
# - tasa de variación interanual: cuánto cambia de un año a otro; no depende
#   del tamaño del país, así que permite comparar la volatilidad
# - índice 2005 = 100: trayectoria relativa de cada país desde el mismo punto
#   de partida, sin que Brasil aplaste a Uruguay en el gráfico
total <- batis |>
  filter(Item_code == "S") |>
  select(Pais, Year, valor = valor_principal) |>
  arrange(Pais, Year) |>
  group_by(Pais) |>
  mutate(
    tasa_var    = (valor / lag(valor) - 1) * 100,
    indice_2005 = valor / valor[Year == 2005] * 100
  ) |>
  ungroup()


# 2. ESTADÍSTICAS DESCRIPTIVAS DEL NIVEL ------------------------------------

# Ojo al interpretar: el nivel tiene tendencia, así que la media de 20 años
# describe el tamaño típico del período, no un valor "estable". El
# coeficiente de variación (desvío / media) mide la dispersión relativa y
# permite comparar países de tamaños muy distintos.
descriptivos_nivel <- total |>
  group_by(Pais) |>
  summarise(
    n                  = n(),
    media              = mean(valor),
    mediana            = median(valor),
    desvio             = sd(valor),
    coef_variacion     = desvio / media,
    minimo             = min(valor),
    anio_minimo        = Year[which.min(valor)],
    p25                = quantile(valor, 0.25),
    p75                = quantile(valor, 0.75),
    rango_intercuartil = IQR(valor),
    maximo             = max(valor),
    anio_maximo        = Year[which.max(valor)],
    .groups = "drop"
  )

print(descriptivos_nivel, width = Inf)

# Tamaño relativo de Argentina frente a Chile, año por año (cuánto más
# grande es un sector exportador que el otro, en %).
argentina_vs_chile <- total |>
  filter(Pais %in% c("Argentina", "Chile")) |>
  select(Pais, Year, valor) |>
  pivot_wider(names_from = Pais, values_from = valor) |>
  mutate(argentina_sobre_chile_pct = (Argentina / Chile - 1) * 100)

print(argentina_vs_chile, n = Inf)


# 3. ESTADÍSTICAS DESCRIPTIVAS DE LAS TASAS DE VARIACIÓN --------------------

# El desvío de la tasa interanual es la medida de volatilidad: cuánto se
# alejan, en promedio, los cambios anuales de su valor típico.
tasas <- total |> filter(!is.na(tasa_var))

descriptivos_tasas <- tasas |>
  group_by(Pais) |>
  summarise(
    n               = n(),
    media           = mean(tasa_var),
    mediana         = median(tasa_var),
    desvio          = sd(tasa_var),
    p10             = quantile(tasa_var, 0.10),
    p25             = quantile(tasa_var, 0.25),
    p75             = quantile(tasa_var, 0.75),
    p90             = quantile(tasa_var, 0.90),
    minimo          = min(tasa_var),
    anio_minimo     = Year[which.min(tasa_var)],
    maximo          = max(tasa_var),
    anio_maximo     = Year[which.max(tasa_var)],
    anios_negativos = sum(tasa_var < 0),
    .groups = "drop"
  )

print(descriptivos_tasas, width = Inf)

# Atípicos según la regla del boxplot (más de 1,5 rangos intercuartiles por
# fuera de la caja), calculados dentro de cada país.
atipicos_tasas <- tasas |>
  group_by(Pais) |>
  filter(tasa_var %in% boxplot.stats(tasa_var)$out) |>
  ungroup() |>
  select(Pais, Year, tasa_var)

print(atipicos_tasas)


# 4. CRECIMIENTO 2005-2024 Y PANDEMIA ---------------------------------------

# La tasa anual compuesta resume el crecimiento acumulado en un ritmo anual
# equivalente (19 años entre 2005 y 2024). Se agrega 2005-2022 porque en
# Chile 2023 y 2024 son estimaciones de OCDE-OMC, no datos informados.
crecimiento <- total |>
  group_by(Pais) |>
  summarise(
    valor_2005 = valor[Year == 2005],
    valor_2022 = valor[Year == 2022],
    valor_2024 = valor[Year == 2024],
    crecimiento_acumulado_2005_2024_pct = (valor_2024 / valor_2005 - 1) * 100,
    tasa_anual_compuesta_2005_2024_pct  = tasa_anual_compuesta(valor_2005, valor_2024, 19),
    tasa_anual_compuesta_2005_2022_pct  = tasa_anual_compuesta(valor_2005, valor_2022, 17),
    .groups = "drop"
  ) |>
  arrange(desc(tasa_anual_compuesta_2005_2024_pct))

# Pandemia: la recuperación se mide contra 2019 (nivel previo al shock).
# Medirla contra 2020 exagera el rebote porque parte de un piso (efecto base);
# se incluye solo para comparar con el script original del grupo.
pandemia <- total |>
  filter(Year %in% c(2019, 2020, 2024)) |>
  select(Pais, Year, valor) |>
  pivot_wider(names_from = Year, values_from = valor, names_prefix = "anio_") |>
  mutate(
    caida_2020_vs_2019_pct  = (anio_2020 / anio_2019 - 1) * 100,
    nivel_2024_vs_2019_pct  = (anio_2024 / anio_2019 - 1) * 100,
    rebote_2024_vs_2020_pct = (anio_2024 / anio_2020 - 1) * 100
  )

print(crecimiento, width = Inf)
print(pandemia, width = Inf)


# 5. COMPOSICIÓN: PARTICIPACIÓN DE CADA CATEGORÍA EN EL TOTAL ---------------

componentes <- batis |>
  filter(Item_code != "S") |>
  select(Pais, Year, Item_code, valor = valor_principal) |>
  left_join(total |> select(Pais, Year, total = valor), by = c("Pais", "Year")) |>
  mutate(
    participacion = valor / total * 100,
    Servicio = factor(unname(etiquetas_servicios[Item_code]),
                      levels = unname(etiquetas_servicios))
  )

# Control: las 12 categorías deberían sumar el total (100%).
control_suma <- componentes |>
  group_by(Pais, Year) |>
  summarise(suma_participaciones = sum(participacion), .groups = "drop")

cat("Suma de participaciones por país y año (debería ser 100):\n")
print(summary(control_suma$suma_participaciones))

composicion_2005_2024 <- componentes |>
  filter(Year %in% c(2005, 2024)) |>
  select(Pais, Servicio, Year, participacion) |>
  pivot_wider(names_from = Year, values_from = participacion,
              names_prefix = "part_") |>
  mutate(cambio_pp = part_2024 - part_2005) |>
  arrange(Pais, desc(part_2024))

# Concentración de la canasta: cuánto del total explican las 3 categorías
# más grandes de cada país (a mayor valor, canasta más concentrada).
concentracion_top3 <- componentes |>
  group_by(Pais, Year) |>
  summarise(participacion_top3 = sum(sort(participacion, decreasing = TRUE)[1:3]),
            .groups = "drop") |>
  filter(Year %in% c(2005, 2024)) |>
  pivot_wider(names_from = Year, values_from = participacion_top3,
              names_prefix = "top3_")

print(composicion_2005_2024, n = Inf, width = Inf)
print(concentracion_top3)


# 6. RELACIÓN ENTRE VARIABLES -----------------------------------------------

# a) ¿Se mueven juntas las exportaciones de los cuatro países? Correlación de
#    las tasas de variación anuales entre países, con su n. Se repite sin
#    2020-2022 (caída y rebote de la pandemia).
#    Cuidado al interpretar: son tasas de valores en USD corrientes, así que
#    parte de la asociación puede venir de shocks comunes (crisis de 2009,
#    dólar fuerte de 2015, pandemia) y de la valuación en dólares, no de una
#    integración entre los países. Con n = 16, una correlación de 0,4 tiene
#    un intervalo de confianza muy amplio.
tasas_ancho <- tasas |>
  select(Pais, Year, tasa_var) |>
  pivot_wider(names_from = Pais, values_from = tasa_var)

tasas_sin_pandemia <- filter(tasas_ancho, !Year %in% 2020:2022)

correlaciones <- bind_rows(
  as_tibble(cor(select(tasas_ancho, -Year), method = "pearson"),
            rownames = "Pais") |>
    mutate(metodo = paste0("Pearson, 2006-2024 (n = ", nrow(tasas_ancho), ")")),
  as_tibble(cor(select(tasas_ancho, -Year), method = "spearman"),
            rownames = "Pais") |>
    mutate(metodo = paste0("Spearman, 2006-2024 (n = ", nrow(tasas_ancho), ")")),
  as_tibble(cor(select(tasas_sin_pandemia, -Year), method = "pearson"),
            rownames = "Pais") |>
    mutate(metodo = paste0("Pearson, sin 2020-2022 (n = ", nrow(tasas_sin_pandemia), ")"))
)

print(correlaciones)

# b) Calidad del dato: ¿cuánto se aparta el valor balanceado (conciliado con
#    lo que declaran los socios) del valor final que informa cada país? Se
#    muestra año por año porque la brecha no es pareja en el tiempo.
brecha_anual <- batis |>
  filter(Item_code == "S") |>
  transmute(
    Pais, Year, Final_value, Balanced_value, Reported_value, origen,
    diferencia_pct = (Balanced_value / Final_value - 1) * 100
  )

brecha_resumen <- brecha_anual |>
  group_by(Pais) |>
  summarise(
    anios_con_valor_informado    = sum(!is.na(Reported_value)),
    diferencia_media_pct         = mean(diferencia_pct),
    diferencia_minima_pct        = min(diferencia_pct),
    anio_diferencia_minima       = Year[which.min(diferencia_pct)],
    diferencia_maxima_pct        = max(diferencia_pct),
    anio_diferencia_maxima       = Year[which.max(diferencia_pct)],
    correlacion_final_balanceado = cor(Final_value, Balanced_value),
    .groups = "drop"
  )

print(brecha_resumen, width = Inf)


# 7. DISTRIBUCIÓN DE LA VARIABLE PRINCIPAL ----------------------------------

# Se usan solo las 960 filas de categorías (sin el total S): el total es la
# suma de sus 12 categorías, y juntarlos contaría dos veces lo mismo.
# La distribución es muy asimétrica a la derecha (pocos valores muy grandes),
# por eso se grafica en escala logarítmica (clase 08, sección 5.4) y se
# reporta la mediana además de la media. Los ceros no tienen logaritmo:
# se informan cuántos son, de dónde vienen y quedan fuera solo del gráfico.
categorias <- batis |> filter(Item_code != "S")

distribucion_valores <- categorias |>
  summarise(
    n                 = n(),
    media             = mean(valor_principal),
    mediana           = median(valor_principal),
    desvio            = sd(valor_principal),
    minimo            = min(valor_principal),
    maximo            = max(valor_principal),
    valores_cero      = sum(valor_principal == 0),
    valores_positivos = sum(valor_principal > 0)
  )

ceros_detalle <- categorias |>
  filter(valor_principal == 0) |>
  group_by(Pais, origen) |>
  summarise(
    ceros      = n(),
    categorias = paste(sort(unique(Item_code)), collapse = ", "),
    .groups = "drop"
  )

print(distribucion_valores, width = Inf)
print(ceros_detalle, width = Inf)


# 7 bis. ROBUSTEZ: ¿CAMBIAN LAS CONCLUSIONES SEGÚN LA MEDIDA? ---------------

# Se comparan las dos medidas en crecimiento y composición. Si cuentan la
# misma historia, la elección de la medida no cambia las conclusiones.
# "Conocimiento" = Telecom., informática e información (SI) + Otros
# servicios empresariales (SJ).
robustez_crecimiento <- batis |>
  filter(Item_code == "S") |>
  group_by(Pais) |>
  summarise(
    tac_2005_2024_final      = tasa_anual_compuesta(Final_value[Year == 2005], Final_value[Year == 2024], 19),
    tac_2005_2024_balanceado = tasa_anual_compuesta(Balanced_value[Year == 2005], Balanced_value[Year == 2024], 19),
    tac_2005_2022_final      = tasa_anual_compuesta(Final_value[Year == 2005], Final_value[Year == 2022], 17),
    tac_2005_2022_balanceado = tasa_anual_compuesta(Balanced_value[Year == 2005], Balanced_value[Year == 2022], 17),
    .groups = "drop"
  )

robustez_composicion <- batis |>
  filter(Year %in% c(2005, 2024)) |>
  group_by(Pais, Year) |>
  summarise(
    conocimiento_final      = sum(Final_value[Item_code %in% c("SI", "SJ")]) / Final_value[Item_code == "S"] * 100,
    conocimiento_balanceado = sum(Balanced_value[Item_code %in% c("SI", "SJ")]) / Balanced_value[Item_code == "S"] * 100,
    viajes_final            = Final_value[Item_code == "SD"] / Final_value[Item_code == "S"] * 100,
    viajes_balanceado       = Balanced_value[Item_code == "SD"] / Balanced_value[Item_code == "S"] * 100,
    .groups = "drop"
  )

# ¿El cambio 2005-2024 de cada categoría va en la misma dirección con las
# dos medidas? (sube con una y baja con la otra = dirección distinta)
robustez_direccion <- batis |>
  filter(Item_code != "S", Year %in% c(2005, 2024)) |>
  group_by(Pais, Year) |>
  mutate(
    part_final      = Final_value / sum(Final_value) * 100,
    part_balanceado = Balanced_value / sum(Balanced_value) * 100
  ) |>
  ungroup() |>
  select(Pais, Item_code, Year, part_final, part_balanceado) |>
  pivot_wider(names_from = Year, values_from = c(part_final, part_balanceado)) |>
  mutate(
    Servicio             = unname(etiquetas_servicios[Item_code]),
    cambio_final_pp      = part_final_2024 - part_final_2005,
    cambio_balanceado_pp = part_balanceado_2024 - part_balanceado_2005,
    misma_direccion      = sign(cambio_final_pp) == sign(cambio_balanceado_pp)
  ) |>
  select(Pais, Item_code, Servicio, cambio_final_pp, cambio_balanceado_pp, misma_direccion)

print(robustez_crecimiento, width = Inf)
print(robustez_composicion, width = Inf)
cat("Pares país-categoría con distinta dirección:",
    sum(!robustez_direccion$misma_direccion), "de", nrow(robustez_direccion), "\n")
print(filter(robustez_direccion, !misma_direccion), width = Inf)


# 8. GRÁFICOS ---------------------------------------------------------------

# 8.1 Evolución en niveles
g_niveles <- ggplot(total, aes(x = Year, y = valor, color = Pais)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = formato_ar) +
  labs(
    title = "Exportaciones de servicios, 2005-2024",
    subtitle = "Millones de USD corrientes",
    x = NULL, y = NULL, color = NULL, caption = str_wrap(fuente, 110)
  ) +
  tema_tp

# 8.2 Evolución relativa: índice 2005 = 100
g_indice <- ggplot(total, aes(x = Year, y = indice_2005, color = Pais)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  labs(
    title = "Exportaciones de servicios: evolución relativa",
    subtitle = "Índice 2005 = 100, calculado sobre valores en USD corrientes",
    x = NULL, y = NULL, color = NULL, caption = str_wrap(fuente, 110)
  ) +
  tema_tp

# 8.3 Histograma de las tasas de variación anual, un panel por país
# Intervalos de 5 puntos porcentuales; línea punteada en 0 (sin cambio).
g_hist_tasas <- ggplot(tasas, aes(x = tasa_var)) +
  geom_histogram(binwidth = 5, boundary = 0, fill = "steelblue", color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~ Pais, nrow = 2) +
  labs(
    title = "Distribución de las tasas de variación anual de las exportaciones de servicios",
    subtitle = paste0("Variación interanual (%) de valores en USD corrientes, 2006-2024 ",
                      "(19 años por país).\nIntervalos de 5 puntos porcentuales"),
    x = "Variación interanual (%)", y = "Cantidad de años",
    caption = str_wrap(fuente, 110)
  ) +
  tema_tp

# 8.4 Boxplot de las tasas de variación, con los atípicos rotulados por año
g_box_tasas <- ggplot(tasas, aes(x = Pais, y = tasa_var)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_boxplot(fill = "grey85", outlier.color = "firebrick") +
  geom_text(data = atipicos_tasas, aes(label = Year),
            nudge_x = 0.25, size = 3, color = "firebrick") +
  labs(
    title = "Volatilidad de las exportaciones de servicios",
    subtitle = paste0("Variación interanual (%) de valores en USD corrientes, 2006-2024.\n",
                      "En rojo, años atípicos (regla de 1,5 rangos intercuartiles)"),
    x = NULL, y = "Variación interanual (%)", caption = str_wrap(fuente, 110)
  ) +
  tema_tp

# 8.5 Composición 2005 vs. 2024 (barras al 100%)
# Para que se lea, se muestran las 5 categorías de mayor participación
# promedio (calculadas con los datos) y el resto se agrupa.
top5 <- componentes |>
  group_by(Servicio) |>
  summarise(part_media = mean(participacion), .groups = "drop") |>
  slice_max(part_media, n = 5) |>
  pull(Servicio) |>
  as.character()

etiqueta_resto <- paste0("Resto (", 12 - length(top5), " categorías)")

composicion_grafico <- componentes |>
  filter(Year %in% c(2005, 2024)) |>
  mutate(Categoria = if_else(as.character(Servicio) %in% top5,
                             as.character(Servicio), etiqueta_resto),
         Categoria = factor(Categoria, levels = c(top5, etiqueta_resto))) |>
  group_by(Pais, Year, Categoria) |>
  summarise(participacion = sum(participacion), .groups = "drop")

g_composicion <- ggplot(composicion_grafico,
                        aes(x = factor(Year), y = participacion, fill = Categoria)) +
  geom_col(width = 0.7) +
  facet_wrap(~ Pais, nrow = 1) +
  labs(
    title = "Composición de las exportaciones de servicios, 2005 y 2024",
    subtitle = "Participación de cada categoría en el total exportado por cada país (%)",
    x = NULL, y = "%", fill = NULL, caption = str_wrap(fuente, 140)
  ) +
  tema_tp +
  guides(fill = guide_legend(ncol = 2))

# 8.6 Histograma de las observaciones de categorías en escala logarítmica
g_hist_log <- ggplot(filter(categorias, valor_principal > 0),
                     aes(x = valor_principal)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  scale_x_log10(labels = formato_ar) +
  labs(
    title = "Distribución de los valores exportados por categoría (país x año x categoría)",
    subtitle = paste0(distribucion_valores$valores_positivos,
                      " observaciones con valor positivo; se excluyen ",
                      distribucion_valores$valores_cero,
                      " valores iguales a cero (no tienen logaritmo).\n",
                      "Millones de USD corrientes, eje en escala logarítmica"),
    x = "Millones de USD corrientes (escala logarítmica)",
    y = "Cantidad de observaciones", caption = str_wrap(fuente, 110)
  ) +
  tema_tp

# 8.7 Brecha entre el valor balanceado y el valor final, año por año
g_brecha <- ggplot(brecha_anual, aes(x = Year, y = diferencia_pct, color = Pais)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  labs(
    title = "¿Cuánto se aparta el valor balanceado del valor que informa cada país?",
    subtitle = paste0("Diferencia porcentual entre el valor balanceado y el valor final, ",
                      "total de servicios.\nArriba de 0: el balanceado es mayor"),
    x = NULL, y = "Diferencia (%)", color = NULL,
    caption = "Fuente: elaboración propia con datos de OECD-WTO BaTIS (BPM6, versión dic. 2025)."
  ) +
  tema_tp


# 9. GUARDADO ---------------------------------------------------------------

guardar_tabla(total,                 "output/tablas/03_total_servicios_por_anio.csv")
guardar_tabla(descriptivos_nivel,    "output/tablas/03_descriptivos_nivel.csv")
guardar_tabla(argentina_vs_chile,    "output/tablas/03_argentina_vs_chile.csv")
guardar_tabla(descriptivos_tasas,    "output/tablas/03_descriptivos_tasas.csv")
guardar_tabla(atipicos_tasas,        "output/tablas/03_atipicos_tasas.csv")
guardar_tabla(crecimiento,           "output/tablas/03_crecimiento.csv")
guardar_tabla(pandemia,              "output/tablas/03_pandemia.csv")
guardar_tabla(componentes,           "output/tablas/03_composicion_completa.csv")
guardar_tabla(control_suma,          "output/tablas/03_control_suma_participaciones.csv")
guardar_tabla(composicion_2005_2024, "output/tablas/03_composicion_2005_2024.csv")
guardar_tabla(concentracion_top3,    "output/tablas/03_concentracion_top3.csv")
guardar_tabla(correlaciones,         "output/tablas/03_correlaciones_tasas.csv")
guardar_tabla(brecha_anual,          "output/tablas/03_brecha_anual.csv")
guardar_tabla(brecha_resumen,        "output/tablas/03_brecha_resumen.csv")
guardar_tabla(distribucion_valores,  "output/tablas/03_distribucion_valores.csv")
guardar_tabla(ceros_detalle,         "output/tablas/03_ceros_detalle.csv")
guardar_tabla(robustez_crecimiento,  "output/tablas/03_robustez_crecimiento.csv")
guardar_tabla(robustez_composicion,  "output/tablas/03_robustez_composicion.csv")
guardar_tabla(robustez_direccion,    "output/tablas/03_robustez_direccion.csv")

ggsave("output/graficos/03_g1_evolucion_niveles.png",      g_niveles,     width = 8,  height = 5.5, dpi = 200, bg = "white")
ggsave("output/graficos/03_g2_evolucion_indice.png",       g_indice,      width = 8,  height = 5.5, dpi = 200, bg = "white")
ggsave("output/graficos/03_g3_histograma_tasas.png",       g_hist_tasas,  width = 8,  height = 6,   dpi = 200, bg = "white")
ggsave("output/graficos/03_g4_boxplot_tasas.png",          g_box_tasas,   width = 8,  height = 5.5, dpi = 200, bg = "white")
ggsave("output/graficos/03_g5_composicion_2005_2024.png",  g_composicion, width = 10, height = 6.5, dpi = 200, bg = "white")
ggsave("output/graficos/03_g6_histograma_valores_log.png", g_hist_log,    width = 8,  height = 5.5, dpi = 200, bg = "white")
ggsave("output/graficos/03_g7_brecha_balanceado_final.png", g_brecha,     width = 8,  height = 5.5, dpi = 200, bg = "white")
