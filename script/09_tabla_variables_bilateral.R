# -----------------------------------------------------------------
# Script      09_tabla_variables_bilateral.R
# Objetivo    Describir las variables de las dos bases de la Instancia 2
#             (tipo, nulos, ceros, valores y uso en el análisis), como
#             pide el checklist de la clase 08
# Entrada     input/batis_bilateral.csv
#             input/batis_mundo_sectores.csv
# Salida      output/tablas/09_unidad_observacion.csv
#             output/tablas/09_tabla_variables.csv
# -----------------------------------------------------------------
# Requiere haber corrido antes 05_filtrado_bilateral.R.
#
# Es el equivalente del script 02 para las bases nuevas:
# - batis_bilateral: Argentina, Brasil, Chile y Uruguay x 202 socios
#   (concentración por socio, script 07; medida: Balanced_value, D-023);
# - batis_mundo_sectores: los 202 países informantes al mundo
#   (ANOVA entre sectores, script 08; medida: Final_value, D-026).

library(tidyverse)

source("utils/resumir_valores.R")   # resume los valores de una variable
source("utils/guardar_tabla.R")     # tablas listas para Excel argentino
source("utils/describir_base.R")    # una fila por variable de cada base

# na = "": Namibia tiene código ISO "NA" y sin esto R la toma como faltante
# (D-026). Reporter y Partner se leen como texto: Kosovo tiene código "888".
tipos <- cols(
  Reporter = col_character(), Partner = col_character(),
  Item_code = col_character(), Year = col_integer(),
  Reported_value = col_double(), Final_value = col_double(),
  Final_value_methodology = col_character(), Balanced_value = col_double(),
  .default = col_guess()
)

bilateral <- read_csv("input/batis_bilateral.csv", na = "", col_types = tipos)
mundo     <- read_csv("input/batis_mundo_sectores.csv", na = "", col_types = tipos)


# 1. DIMENSIÓN Y UNIDAD DE OBSERVACIÓN --------------------------------------

# Hipótesis: en la bilateral cada fila es país x socio x sector x año, y en
# la base al mundo, país x sector x año (el socio es siempre WL). Si es así,
# ninguna combinación puede repetirse.
unidad_observacion <- tibble(
  base = c("batis_bilateral", "batis_mundo_sectores"),
  unidad = c("País informante x socio x sector x año",
             "País informante x sector x año (socio = mundo)"),
  filas = c(nrow(bilateral), nrow(mundo)),
  columnas = c(ncol(bilateral), ncol(mundo)),
  combinaciones_unicas = c(
    nrow(distinct(bilateral, Reporter, Partner, Item_code, Year)),
    nrow(distinct(mundo, Reporter, Item_code, Year))
  ),
  paises_informantes = c(n_distinct(bilateral$Reporter), n_distinct(mundo$Reporter)),
  socios = c(n_distinct(bilateral$Partner), n_distinct(mundo$Partner)),
  sectores = c(n_distinct(bilateral$Item_code), n_distinct(mundo$Item_code)),
  anios = c(n_distinct(bilateral$Year), n_distinct(mundo$Year))
)

print(unidad_observacion, width = Inf)


# 2. TABLA DE VARIABLES -----------------------------------------------------

# Descripción, tipo y uso de cada variable, escritos a mano a partir del
# diccionario (raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx) y de las
# decisiones D-023 a D-026. Las columnas comunes se describen una vez y el
# uso se escribe por base, porque cada base usa una medida distinta.
descripciones <- tribble(
  ~variable,                 ~descripcion,                                                                                     ~tipo,
  "Reporter",                "País que informa el flujo (código de 2 letras; Kosovo = 888)",                                   "Categórica",
  "Partner",                 "Economía de destino (WL = mundo; ROW = resto del mundo, socios no identificados)",              "Categórica",
  "Item_code",               "Sector de servicio EBOPS 2010 (S = total; SA a SL = 12 sectores)",                              "Categórica",
  "Year",                    "Año de referencia",                                                                              "Temporal (numérica)",
  "Reported_value",          "Valor informado por la autoridad estadística del país (millones de USD corrientes)",            "Numérica continua",
  "Final_value",             "Valor informado, completado con estimaciones de OCDE-OMC donde falta (millones de USD corrientes)", "Numérica continua",
  "Final_value_methodology", "Código del método con que se obtuvo el valor final (R_ = informado; E y M = estimado)",         "Categórica",
  "Balanced_value",          "Valor conciliado entre lo que declaran exportador e importador (millones de USD corrientes)",   "Numérica continua",
  "nombre_socio",            "Nombre del socio, de la hoja economies del diccionario",                                         "Categórica",
  "nombre_pais",             "Nombre del país informante, de la hoja economies del diccionario",                              "Categórica",
  "es_resto_mundo",          "TRUE si el socio es ROW (resto del mundo)",                                                      "Lógica",
  "origen",                  "Origen del valor final: informado, derivado o estimado (agrupa Final_value_methodology)",        "Categórica"
)

usos <- tribble(
  ~base,                   ~variable,                 ~uso_en_el_analisis,
  "batis_bilateral",       "Reporter",                "Agrupa: los 4 países",
  "batis_bilateral",       "Partner",                 "Unidad de la concentración: participación de cada socio",
  "batis_bilateral",       "Item_code",               "Agrupa: total y sectores",
  "batis_bilateral",       "Year",                    "Índices año por año; período principal 2015-2024",
  "batis_bilateral",       "Reported_value",          "Calidad del dato: vacío si el país no declaró ese flujo",
  "batis_bilateral",       "Final_value",             "Sensibilidad de la concentración (D-029)",
  "batis_bilateral",       "Final_value_methodology", "Calidad del dato: origen por socio",
  "batis_bilateral",       "Balanced_value",          "Medida principal de la concentración (D-023, D-029)",
  "batis_bilateral",       "nombre_socio",            "Etiqueta de tablas",
  "batis_bilateral",       "es_resto_mundo",          "Filtro: ROW se excluye de la concentración (D-026)",
  "batis_bilateral",       "origen",                  "Calidad del dato: % del valor estimado (05_origen_bilateral)",
  "batis_mundo_sectores",  "Reporter",                "Unidad del ANOVA: una observación por país y sector",
  "batis_mundo_sectores",  "Partner",                 "No: constante (WL)",
  "batis_mundo_sectores",  "Item_code",               "Factor del ANOVA: 12 sectores (el total S no entra)",
  "batis_mundo_sectores",  "Year",                    "Se promedia 2015-2024",
  "batis_mundo_sectores",  "Reported_value",          "Calidad del dato: faltantes reales del valor final (06_faltantes_valor_final)",
  "batis_mundo_sectores",  "Final_value",             "Variable del ANOVA y del RCA, en log (D-026, D-028)",
  "batis_mundo_sectores",  "Final_value_methodology", "Calidad del dato: ceros informados o completados",
  "batis_mundo_sectores",  "Balanced_value",          "No: se aparta mucho del final en economías chicas (D-026)",
  "batis_mundo_sectores",  "nombre_pais",             "Etiqueta de tablas",
  "batis_mundo_sectores",  "origen",                  "Calidad del dato: años sin valor informado"
)

tabla_variables <- bind_rows(
  describir_base(bilateral, "batis_bilateral"),
  describir_base(mundo, "batis_mundo_sectores")
) |>
  left_join(descripciones, by = "variable") |>
  left_join(usos, by = c("base", "variable")) |>
  relocate(descripcion, tipo, .after = variable)

print(tabla_variables, n = Inf, width = Inf)

# Lectura: el único nulo es Reported_value, que está vacío cuando el país no
# declaró ese flujo. No es un faltante de la medida: Final_value y
# Balanced_value están completos, porque OCDE-OMC completa lo no informado.
# Por eso el diagnóstico de faltantes (script 06) mira el origen del dato y
# los ceros, no los nulos.


# 3. GUARDAR ----------------------------------------------------------------

dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)
guardar_tabla(unidad_observacion, "output/tablas/09_unidad_observacion.csv")
guardar_tabla(tabla_variables,    "output/tablas/09_tabla_variables.csv")
