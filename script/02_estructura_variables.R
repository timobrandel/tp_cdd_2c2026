# -----------------------------------------------------------------
# Script      02_estructura_variables.R
# Objetivo    Describir la estructura de la base de trabajo: dimensión,
#             unidad de observación, tipo, nulos y valores de cada variable,
#             y origen de los datos (informados por el país o estimados)
# Entrada     input/batis_filtrada.csv
#             output/tablas/01_nulos_base_completa.csv
#             raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx (diccionario)
# Salida      output/tablas/02_unidad_observacion.csv
#             output/tablas/02_tabla_variables.csv
#             output/tablas/02_origen_datos_por_pais.csv
#             output/tablas/02_metodologias_por_pais.csv
#             output/tablas/02_estimados_detalle.csv
# -----------------------------------------------------------------
# Requiere haber corrido antes 01_filtrado_batis.R.

library(tidyverse)
library(readxl)   # lectura del diccionario en Excel

source("utils/resumir_valores.R")    # resume los valores de una variable
source("utils/clasificar_origen.R")  # informado / derivado / estimado
source("utils/guardar_tabla.R")      # tablas listas para Excel argentino

# Declaramos los tipos: Reporter y Partner son códigos de texto.
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

nulos_completa <- read_csv2("output/tablas/01_nulos_base_completa.csv",
                            show_col_types = FALSE)

metodologias <- read_excel(
  "raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx",
  sheet = "methodology codes"
)

# El Excel de códigos no trae todos los códigos que aparecen en los datos.
# Los faltantes están en el Anexo H de la metodología oficial
# (raw/OECD-WTO_Batis_methodology_BPM6.pdf); los agregamos a mano.
metodologias <- bind_rows(
  metodologias,
  tribble(
    ~Methodology, ~Description,
    "R_OECD", "Reported: OECD International Trade in Services Statistics (ITSS).",
    "E2",     "Estimation of most recent year(s) missing in primary source by using the national BOP growth rate (partner world only).",
    "E3",     "Estimated using past or future shares (partner world only).",
    "E5",     "Estimates based on regional growth rates (partner world only)."
  )
)


# 1. DIMENSIÓN Y UNIDAD DE OBSERVACIÓN --------------------------------------

dim(batis)

# Hipótesis: cada fila es un país (Reporter) en un año (Year) para una
# categoría de servicio (Item_code). Si esa es la unidad de observación,
# ninguna combinación puede repetirse.
unidad_observacion <- tibble(
  filas                = nrow(batis),
  columnas             = ncol(batis),
  combinaciones_unicas = nrow(distinct(batis, Reporter, Year, Item_code)),
  filas_duplicadas     = sum(duplicated(batis[, c("Reporter", "Year", "Item_code")])),
  paises               = n_distinct(batis$Reporter),
  anios                = n_distinct(batis$Year),
  categorias           = n_distinct(batis$Item_code)
)

print(unidad_observacion)


# 2. TABLA DE VARIABLES -----------------------------------------------------

# Descripciones tomadas del diccionario oficial (hojas "notes", "type",
# "flow", "service items" y "methodology codes"), traducidas.
descripciones <- tribble(
  ~variable,                 ~descripcion,                                                                 ~tipo,                  ~uso_en_el_analisis,
  "Reporter",                "País que informa el flujo (código de 2 letras)",                             "Categórica",           "Agrupa: país",
  "type_Reporter",           "Tipo de economía que informa (c = país, g = grupo de países)",               "Categórica",           "No: constante en la base de trabajo",
  "Partner",                 "Economía de destino (WL = mundo)",                                           "Categórica",           "Filtro: solo WL",
  "type_Partner",            "Tipo de economía de destino (c = país, g = grupo de países)",                "Categórica",           "No: constante en la base de trabajo",
  "Flow",                    "Sentido del flujo (X = exportaciones, M = importaciones)",                   "Categórica",           "Filtro: solo X",
  "Item_code",               "Categoría de servicio EBOPS 2010 (S = total; SA a SL = 12 categorías)",      "Categórica",           "Agrupa: categoría",
  "type_Item",               "Tipo de ítem (s = estándar BPM6, d = derivado)",                             "Categórica",           "No: constante en la base de trabajo",
  "Year",                    "Año de referencia",                                                          "Temporal (numérica)",  "Eje temporal",
  "Reported_value",          "Valor informado por la autoridad estadística del país (millones de USD corrientes)", "Numérica continua", "Calidad del dato: vacío si el valor fue estimado",
  "Final_value",             "Valor informado por el país, completado con estimaciones de OCDE-OMC donde falta (millones de USD corrientes)", "Numérica continua", "Variable principal (D-015)",
  "Final_value_methodology", "Código del método con que se obtuvo el valor final (R = informado; E y M = estimado)", "Categórica", "Calidad del dato",
  "Balanced_value",          "Valor conciliado entre lo que informa el exportador y lo que informa el importador (millones de USD corrientes)", "Numérica continua", "Calidad del dato: comparación con el valor final"
)

# Resumen automático de los valores de cada variable:
# - categóricas: cuántos valores distintos hay y cuáles son (hasta 13)
# - numéricas: mínimo y máximo
# resumir_valores() está en utils/resumir_valores.R

tabla_variables <- tibble(
  variable          = names(batis),
  clase_en_R        = map_chr(batis, ~ class(.x)[1]),
  valores_distintos = map_int(batis, n_distinct),
  nulos_base_trabajo = map_int(batis, ~ sum(is.na(.x))),
  valores           = map_chr(batis, resumir_valores)
) |>
  left_join(descripciones, by = "variable") |>
  left_join(
    nulos_completa |> select(variable, pct_nulos_base_completa = pct_nulos),
    by = "variable"
  ) |>
  relocate(descripcion, tipo, .after = variable)

print(tabla_variables, width = Inf)


# 3. ORIGEN DE LOS DATOS: ¿INFORMADOS O ESTIMADOS? --------------------------

# Final_value_methodology dice cómo se obtuvo cada valor. Los códigos que
# empiezan con "R_" son datos informados por una fuente oficial (nacional,
# FMI o Eurostat); E1 es una derivación simple de datos informados; el resto
# son estimaciones de OCDE-OMC (modelos de gravedad, interpolaciones, ceros).
batis <- batis |>
  mutate(origen = clasificar_origen(Final_value_methodology))

origen_por_pais <- batis |>
  count(Reporter, origen) |>
  group_by(Reporter) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()

metodologias_por_pais <- batis |>
  count(Reporter, Final_value_methodology) |>
  left_join(
    metodologias |> rename(Final_value_methodology = Methodology,
                           descripcion = Description),
    by = "Final_value_methodology"
  ) |>
  arrange(Reporter, desc(n))

# ¿En qué años y categorías se concentran las estimaciones? Importa porque
# un año estimado (por ejemplo, el último) condiciona las comparaciones.
estimados_detalle <- batis |>
  filter(origen == "Estimado por OCDE-OMC") |>
  group_by(Reporter, Final_value_methodology) |>
  summarise(
    filas      = n(),
    anios      = paste(sort(unique(Year)), collapse = ", "),
    categorias = paste(sort(unique(Item_code)), collapse = ", "),
    .groups = "drop"
  )

print(origen_por_pais)
print(metodologias_por_pais, n = Inf)
print(estimados_detalle, width = Inf)


# 4. GUARDADO ---------------------------------------------------------------

guardar_tabla(unidad_observacion,    "output/tablas/02_unidad_observacion.csv")
guardar_tabla(tabla_variables,       "output/tablas/02_tabla_variables.csv")
guardar_tabla(origen_por_pais,       "output/tablas/02_origen_datos_por_pais.csv")
guardar_tabla(metodologias_por_pais, "output/tablas/02_metodologias_por_pais.csv")
guardar_tabla(estimados_detalle,     "output/tablas/02_estimados_detalle.csv")
