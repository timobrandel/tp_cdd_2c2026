# ============================================================
# TRABAJO PRACTICO - CIENCIA DE DATOS
# OECD-WTO Balanced Trade in Services Dataset (BaTiS)
#
# Tema:
# Evolucion y composicion de las exportaciones de servicios
# de Argentina entre 2005 y 2024, en comparacion con
# Brasil, Chile y Uruguay.
#
# Esta version usa la sintaxis trabajada en la catedra.
# DuckDB se utiliza solamente para leer y filtrar el archivo
# original, que pesa aproximadamente 2,8 GB.
# ============================================================


# ------------------------------------------------------------
# 1. PAQUETES
# ------------------------------------------------------------

# Instalar una sola vez si fuera necesario:
# install.packages(c("tidyverse", "DBI", "duckdb", "readxl", "scales"))

library(tidyverse)  # manipulacion de datos y graficos
library(DBI)        # conexion entre R y DuckDB
library(duckdb)     # lectura eficiente de la base grande
library(readxl)     # lectura del diccionario en Excel
library(scales)     # formato de los ejes de los graficos


# ------------------------------------------------------------
# 2. ARCHIVOS Y CARPETA DE SALIDA
# ------------------------------------------------------------

# Los dos archivos de entrada deben estar en la misma carpeta
# que este script y conservar estos nombres.
instub  <- "."
outstub <- "output"

archivo_batis   <- file.path(instub, "BATIS.csv")
archivo_codigos <- file.path(instub, "BATIS_codes.xlsx")

# Comprobamos que los archivos existan antes de continuar.
stopifnot(file.exists(archivo_batis))
stopifnot(file.exists(archivo_codigos))

# Creamos la carpeta donde se guardaran los resultados.
dir.create(outstub, recursive = TRUE, showWarnings = FALSE)


# ------------------------------------------------------------
# 3. DICCIONARIO DE CODIGOS
# ------------------------------------------------------------

# Primero observamos las hojas disponibles en el diccionario.
hojas_codigos <- excel_sheets(archivo_codigos)
hojas_codigos

# Leemos las hojas relevantes para interpretar la base.
paises_codigos <- read_excel(
  archivo_codigos,
  sheet = "economies"
)

flow_codigos <- read_excel(
  archivo_codigos,
  sheet = "flow"
)

servicios_codigos <- read_excel(
  archivo_codigos,
  sheet = "service items"
)

head(paises_codigos)
flow_codigos
head(servicios_codigos, 30)

# Codigos identificados a partir del diccionario:
# AR = Argentina, BR = Brasil, CL = Chile, UY = Uruguay
# WL = mundo, X = exportaciones
# S = total de servicios y SA a SL = doce categorias principales


# ------------------------------------------------------------
# 4. LECTURA Y FILTRADO DE LA BASE GRANDE
# ------------------------------------------------------------

# Esta es la unica parte que no se realiza con tidyverse.
# Como el CSV completo tiene millones de filas, DuckDB selecciona
# solamente las observaciones necesarias antes de pasarlas a R.

con <- dbConnect(duckdb())

# DuckDB utiliza barras normales en las rutas.
archivo_batis_sql <- gsub("\\\\", "/", archivo_batis)

consulta_tp <- paste0("
SELECT
    Reporter,
    Partner,
    Flow,
    Item_code,
    CAST(Year AS INTEGER) AS Year,
    CAST(Balanced_value AS DOUBLE) AS Balanced_value
FROM read_csv_auto(
    '", archivo_batis_sql, "',
    types = {'Reporter': 'VARCHAR'}
)
WHERE Reporter IN ('AR', 'BR', 'CL', 'UY')
  AND Partner = 'WL'
  AND Flow = 'X'
  AND CAST(Year AS INTEGER) BETWEEN 2005 AND 2024
  AND Item_code IN (
      'S',
      'SA', 'SB', 'SC', 'SD', 'SE', 'SF',
      'SG', 'SH', 'SI', 'SJ', 'SK', 'SL'
  )
ORDER BY Reporter, Year, Item_code
")

batis_tp <- dbGetQuery(con, consulta_tp)

# Una vez creada la base analitica, cerramos la conexion.
dbDisconnect(con, shutdown = TRUE)


# ------------------------------------------------------------
# 5. INSPECCION Y CONTROL DE LA BASE ANALITICA
# ------------------------------------------------------------

glimpse(batis_tp)
dim(batis_tp)
summary(batis_tp)
colSums(is.na(batis_tp))

batis_tp |> count(Reporter)
batis_tp |> count(Item_code)

range(batis_tp$Year)

# El resultado esperado es:
# 4 paises x 20 anios x 13 items = 1.040 observaciones.
nrow(batis_tp)


# ------------------------------------------------------------
# 6. TOTAL DE EXPORTACIONES DE SERVICIOS
# ------------------------------------------------------------

# Conservamos las observaciones cuyo codigo S representa el total.
batis_total <- batis_tp |>
  filter(Item_code == "S") |>
  mutate(
    Pais = factor(
      Reporter,
      levels = c("AR", "BR", "CL", "UY"),
      labels = c("Argentina", "Brasil", "Chile", "Uruguay")
    )
  )

# Estadisticas descriptivas por pais.
resumen_total <- batis_total |>
  group_by(Pais) |>
  summarise(
    observaciones = n(),
    media   = mean(Balanced_value, na.rm = TRUE),
    mediana = median(Balanced_value, na.rm = TRUE),
    minimo  = min(Balanced_value, na.rm = TRUE),
    maximo  = max(Balanced_value, na.rm = TRUE),
    .groups = "drop"
  )

resumen_total


# ------------------------------------------------------------
# 7. GRAFICO DE EVOLUCION
# ------------------------------------------------------------

grafico_evolucion <- ggplot(
  batis_total,
  aes(
    x = Year,
    y = Balanced_value,
    color = Pais,
    linetype = Pais,
    shape = Pais
  )
) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  scale_y_continuous(
    labels = label_number(big.mark = ".", decimal.mark = ",")
  ) +
  labs(
    title = "Evolucion de las exportaciones totales de servicios",
    subtitle = "Argentina, Brasil, Chile y Uruguay - 2005 a 2024",
    x = "Anio",
    y = "Exportaciones de servicios (millones de USD)",
    color = "Pais",
    linetype = "Pais",
    shape = "Pais"
  ) +
  theme_minimal()

grafico_evolucion


# ------------------------------------------------------------
# 8. DISTRIBUCION DE LAS EXPORTACIONES POR PAIS (BOXPLOT)
# ------------------------------------------------------------

grafico_boxplot <- ggplot(
  batis_total,
  aes(x = Pais, y = Balanced_value, fill = Pais)
) +
  geom_boxplot() +
  scale_y_continuous(
    labels = label_number(big.mark = ".", decimal.mark = ",")
  ) +
  labs(
    title = "Distribucion de las exportaciones anuales por pais",
    subtitle = "2005 a 2024",
    x = NULL,
    y = "Exportaciones de servicios (millones de USD)",
    fill = "Pais"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

grafico_boxplot


# ------------------------------------------------------------
# 9. CRECIMIENTO ACUMULADO, 2005-2024
# ------------------------------------------------------------

# Variacion porcentual entre el primer y el ultimo anio de la serie.
crecimiento_2005_2024 <- batis_total |>
  filter(Year %in% c(2005, 2024)) |>
  select(Pais, Year, Balanced_value) |>
  pivot_wider(
    names_from = Year,
    values_from = Balanced_value,
    names_prefix = "anio_"
  ) |>
  mutate(
    Crecimiento = (anio_2024 - anio_2005) / anio_2005 * 100
  ) |>
  arrange(desc(Crecimiento))

crecimiento_2005_2024

grafico_crecimiento <- ggplot(
  crecimiento_2005_2024,
  aes(x = fct_reorder(Pais, Crecimiento), y = Crecimiento, fill = Pais)
) +
  geom_col() +
  geom_text(
    aes(label = paste0("+", round(Crecimiento), "%")),
    hjust = -0.1
  ) +
  coord_flip() +
  labs(
    title = "Crecimiento acumulado de las exportaciones, 2005-2024",
    subtitle = "Variacion porcentual entre el primer y el ultimo anio de la serie",
    x = NULL,
    y = "Crecimiento (%)",
    fill = "Pais"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

grafico_crecimiento


# ------------------------------------------------------------
# 10. COMPOSICION DE LAS EXPORTACIONES
# ------------------------------------------------------------

# Separamos las doce categorias principales del total S.
batis_componentes <- batis_tp |>
  filter(Item_code != "S")

# Armamos una tabla auxiliar con el total de cada pais y anio.
total_aux <- batis_total |>
  select(Reporter, Year, Total_services = Balanced_value)

# Unimos cada componente con su total y calculamos su participacion.
# left_join() conserva todas las filas de la tabla de componentes.
batis_composicion <- batis_componentes |>
  left_join(total_aux, by = c("Reporter", "Year")) |>
  mutate(
    Participacion = Balanced_value / Total_services * 100,
    Pais = factor(
      Reporter,
      levels = c("AR", "BR", "CL", "UY"),
      labels = c("Argentina", "Brasil", "Chile", "Uruguay")
    ),
    Servicio = factor(
      Item_code,
      levels = c(
        "SA", "SB", "SC", "SD", "SE", "SF",
        "SG", "SH", "SI", "SJ", "SK", "SL"
      ),
      labels = c(
        "Manufactura (maquila)",
        "Mantenimiento",
        "Transporte",
        "Viajes",
        "Construccion",
        "Seguros",
        "Financieros",
        "Propiedad intelectual",
        "Telecom. e informatica",
        "Otros empresariales",
        "Personales y culturales",
        "Gubernamentales"
      )
    )
  )

glimpse(batis_composicion)
summary(batis_composicion$Participacion)
colSums(is.na(batis_composicion))


# ------------------------------------------------------------
# 11. COMPOSICION EN 2024 (CATEGORIAS SELECCIONADAS)
# ------------------------------------------------------------

composicion_2024 <- batis_composicion |>
  filter(Year == 2024)

# Para que el grafico sea legible en la presentacion, se seleccionan
# las categorias con mayor peso relativo entre las 12 disponibles.
categorias_seleccionadas <- c(
  "Transporte", "Viajes", "Telecom. e informatica",
  "Otros empresariales", "Financieros", "Gubernamentales"
)

composicion_2024_seleccionada <- composicion_2024 |>
  filter(Servicio %in% categorias_seleccionadas) |>
  mutate(
    Servicio = recode(
      as.character(Servicio),
      "Telecom. e informatica" = "Inform. y telecom.",
      "Otros empresariales"    = "Otros serv. empresariales",
      "Gubernamentales"        = "Gobierno"
    ),
    Servicio = factor(
      Servicio,
      levels = c(
        "Transporte", "Viajes", "Inform. y telecom.",
        "Otros serv. empresariales", "Financieros", "Gobierno"
      )
    )
  )

grafico_composicion <- ggplot(
  composicion_2024_seleccionada,
  aes(
    x = Servicio,
    y = Participacion,
    fill = Pais
  )
) +
  geom_col(position = "dodge") +
  labs(
    title = "Composicion de las exportaciones de servicios en 2024",
    subtitle = "Participacion de las principales categorias sobre el total exportado por cada pais",
    x = NULL,
    y = "Participacion (%)",
    fill = "Pais"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

grafico_composicion


# ------------------------------------------------------------
# 12. CAMBIO DE COMPOSICION SECTORIAL - ARGENTINA
# ------------------------------------------------------------

composicion_argentina_2005_2024 <- batis_composicion |>
  filter(Reporter == "AR", Year %in% c(2005, 2024)) |>
  select(Servicio, Year, Participacion)

grafico_cambio_composicion <- ggplot(
  composicion_argentina_2005_2024,
  aes(x = Servicio, y = Participacion, fill = factor(Year))
) +
  geom_col(position = "dodge") +
  labs(
    title = "Cambio en la composicion sectorial de Argentina",
    subtitle = "Participacion de cada categoria sobre el total exportado, 2005 vs. 2024",
    x = NULL,
    y = "Participacion (%)",
    fill = "Anio"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

grafico_cambio_composicion


# ------------------------------------------------------------
# 13. IMPACTO DE LA PANDEMIA
# ------------------------------------------------------------

# Caida de 2020 respecto de 2019 y recuperacion de 2024 respecto de 2020.
variacion_pandemia <- batis_total |>
  filter(Year %in% c(2019, 2020, 2024)) |>
  select(Pais, Year, Balanced_value) |>
  pivot_wider(
    names_from = Year,
    values_from = Balanced_value,
    names_prefix = "anio_"
  ) |>
  mutate(
    Caida_2020         = (anio_2020 - anio_2019) / anio_2019 * 100,
    Recuperacion_2024  = (anio_2024 - anio_2020) / anio_2020 * 100
  ) |>
  select(Pais, Caida_2020, Recuperacion_2024)

variacion_pandemia

variacion_pandemia_largo <- variacion_pandemia |>
  pivot_longer(
    cols = c(Caida_2020, Recuperacion_2024),
    names_to = "Indicador",
    values_to = "Variacion"
  ) |>
  mutate(
    Indicador = recode(
      Indicador,
      "Caida_2020"        = "Caida 2020 vs. 2019",
      "Recuperacion_2024" = "Recuperacion 2024 vs. 2020"
    )
  )

grafico_pandemia <- ggplot(
  variacion_pandemia_largo,
  aes(x = Pais, y = Variacion, fill = Indicador)
) +
  geom_col(position = "dodge") +
  labs(
    title = "Caida en 2020 y recuperacion posterior",
    subtitle = "Variacion porcentual de las exportaciones totales de servicios",
    x = NULL,
    y = "Variacion (%)",
    fill = NULL
  ) +
  theme_minimal()

grafico_pandemia


# ------------------------------------------------------------
# 14. GUARDADO DE RESULTADOS
# ------------------------------------------------------------

# La catedra trabaja con una carpeta de salida separada.

# --- Tablas ---
write_csv(
  batis_tp,
  file.path(outstub, "base_analitica_batis.csv")
)

write_csv(
  resumen_total,
  file.path(outstub, "resumen_exportaciones_totales.csv")
)

write_csv(
  crecimiento_2005_2024,
  file.path(outstub, "crecimiento_2005_2024.csv")
)

write_csv(
  composicion_2024,
  file.path(outstub, "composicion_exportaciones_2024.csv")
)

write_csv(
  composicion_2024_seleccionada,
  file.path(outstub, "composicion_2024_seleccionada.csv")
)

write_csv(
  composicion_argentina_2005_2024,
  file.path(outstub, "composicion_argentina_2005_2024.csv")
)

write_csv(
  variacion_pandemia,
  file.path(outstub, "variacion_pandemia.csv")
)

# --- Graficos ---
ggsave(
  file.path(outstub, "evolucion_exportaciones_servicios.png"),
  grafico_evolucion,
  width = 8,
  height = 5,
  dpi = 300
)

ggsave(
  file.path(outstub, "boxplot_exportaciones_por_pais.png"),
  grafico_boxplot,
  width = 7,
  height = 5,
  dpi = 300
)

ggsave(
  file.path(outstub, "crecimiento_2005_2024.png"),
  grafico_crecimiento,
  width = 7,
  height = 5,
  dpi = 300
)

ggsave(
  file.path(outstub, "composicion_exportaciones_2024.png"),
  grafico_composicion,
  width = 9,
  height = 6,
  dpi = 300
)

ggsave(
  file.path(outstub, "cambio_composicion_argentina.png"),
  grafico_cambio_composicion,
  width = 9,
  height = 6,
  dpi = 300
)

ggsave(
  file.path(outstub, "variacion_pandemia.png"),
  grafico_pandemia,
  width = 7,
  height = 5,
  dpi = 300
)

# Fin del script.
