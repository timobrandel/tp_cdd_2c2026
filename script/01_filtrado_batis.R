# -----------------------------------------------------------------
# Script      01_filtrado_batis.R
# Objetivo    Medir la base BaTIS completa (dimensión y nulos por variable)
#             y extraer la base de trabajo: exportaciones de servicios al
#             mundo de Argentina, Brasil, Chile y Uruguay, 2005-2024
# Entrada     raw/OECD-WTO_BATIS_BPM6_December2025_bulk.csv (~2,98 GB)
# Salida      input/batis_filtrada.csv (base de trabajo, CSV estándar)
#             output/tablas/01_dimension_base_completa.csv
#             output/tablas/01_nulos_base_completa.csv
# -----------------------------------------------------------------
# Requiere haber corrido antes 00_descarga_datos.R.
# El CSV completo tiene decenas de millones de filas: no se carga en R.
# DuckDB (un motor de base de datos que funciona como paquete de R) lee
# el archivo desde el disco, hace los cálculos y le pasa a R solo los
# resultados. Es la única parte del proyecto que no usa tidyverse.

library(tidyverse)
library(DBI)     # interfaz para conectar R con bases de datos
library(duckdb)  # motor que consulta el CSV sin cargarlo en memoria

source("utils/guardar_tabla.R")   # guarda tablas listas para Excel argentino

archivo_batis <- "raw/OECD-WTO_BATIS_BPM6_December2025_bulk.csv"
stopifnot(file.exists(archivo_batis))

dir.create("input", showWarnings = FALSE)
dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)

# shared_home = FALSE: DuckDB usa una carpeta temporal para sus archivos
# internos y no muestra un aviso largo en la consola cada vez que se corre.
con <- dbConnect(duckdb(shared_home = FALSE))

# Declaramos el tipo de las 12 columnas en lugar de dejar que DuckDB lo adivine:
# - Reporter y Partner son códigos de texto. Adivinando, "888" (Kosovo)
#   parecería un número y "NA" (Namibia) podría confundirse con un faltante.
# - Reported_value tiene muchas celdas vacías y podría detectarse como texto.
tabla_batis <- paste0(
  "read_csv('", archivo_batis, "', header = true, types = {",
  "'Reporter': 'VARCHAR', 'type_Reporter': 'VARCHAR', ",
  "'Partner': 'VARCHAR', 'type_Partner': 'VARCHAR', ",
  "'Flow': 'VARCHAR', 'Item_code': 'VARCHAR', 'type_Item': 'VARCHAR', ",
  "'Year': 'INTEGER', 'Reported_value': 'DOUBLE', 'Final_value': 'DOUBLE', ",
  "'Final_value_methodology': 'VARCHAR', 'Balanced_value': 'DOUBLE'})"
)

columnas <- c(
  "Reporter", "type_Reporter", "Partner", "type_Partner", "Flow",
  "Item_code", "type_Item", "Year", "Reported_value", "Final_value",
  "Final_value_methodology", "Balanced_value"
)


# 1. DIMENSIÓN Y NULOS DE LA BASE COMPLETA ----------------------------------

# COUNT(*) cuenta todas las filas; COUNT(columna) cuenta solo los valores
# no nulos. La diferencia entre ambos da los nulos de cada variable.
# Todo se resuelve en una sola lectura del archivo.
consulta_conteos <- paste0(
  "SELECT COUNT(*) AS filas, ",
  paste0("COUNT(", columnas, ") AS nn_", columnas, collapse = ", "),
  ", COUNT(DISTINCT Reporter) AS reporters",
  ", COUNT(DISTINCT CASE WHEN type_Reporter = 'c' THEN Reporter END) AS reporters_paises",
  ", COUNT(DISTINCT CASE WHEN type_Reporter = 'g' THEN Reporter END) AS reporters_agregados",
  ", COUNT(DISTINCT Partner) AS partners",
  ", COUNT(DISTINCT Item_code) AS items",
  ", MIN(Year) AS anio_min, MAX(Year) AS anio_max",
  " FROM ", tabla_batis
)

conteos <- dbGetQuery(con, consulta_conteos)

# Unidad de observación de la base completa. Hipótesis: cada fila es un
# informante x socio x flujo x categoría x año. Si es así, la cantidad de
# combinaciones distintas de esas cinco columnas es igual a la cantidad de
# filas (no hay duplicados).
consulta_unidad <- paste0(
  "SELECT COUNT(*) AS combinaciones FROM (",
  "SELECT DISTINCT Reporter, Partner, Flow, Item_code, Year FROM ",
  tabla_batis, ")"
)

combinaciones <- dbGetQuery(con, consulta_unidad)$combinaciones

dimension_completa <- tibble(
  filas                = conteos$filas,
  columnas             = length(columnas),
  combinaciones_unicas = combinaciones,
  filas_duplicadas     = conteos$filas - combinaciones,
  reporters            = conteos$reporters,
  reporters_paises     = conteos$reporters_paises,
  reporters_agregados  = conteos$reporters_agregados,
  partners             = conteos$partners,
  items                = conteos$items,
  anio_min             = conteos$anio_min,
  anio_max             = conteos$anio_max
)

nulos_completa <- tibble(
  variable = columnas,
  no_nulos = as.numeric(unlist(conteos[1, paste0("nn_", columnas)]))
) |>
  mutate(
    nulos     = conteos$filas - no_nulos,
    pct_nulos = round(100 * nulos / conteos$filas, 2)
  )

print(dimension_completa)
print(nulos_completa)


# 2. EXTRACCIÓN DE LA BASE DE TRABAJO ---------------------------------------

# Mismos filtros que el script original del grupo
# (auxiliar/BATIS_original_companero.R), pero conservando las 12 columnas:
# - Reporter: AR, BR, CL, UY (según la hoja "economies" del diccionario)
# - Partner = WL: el mundo (total de destinos)
# - Flow = X: exportaciones
# - Item_code: S (total de servicios) y SA a SL (las 12 categorías principales
#   de EBOPS 2010; las subcategorías como SC1 o SJ2 quedan afuera)
paises <- c("AR", "BR", "CL", "UY")
items  <- c("S", "SA", "SB", "SC", "SD", "SE", "SF",
            "SG", "SH", "SI", "SJ", "SK", "SL")

consulta_filtro <- paste0(
  "SELECT * FROM ", tabla_batis,
  " WHERE Reporter IN (", paste0("'", paises, "'", collapse = ", "), ")",
  " AND Partner = 'WL' AND Flow = 'X'",
  " AND Year BETWEEN 2005 AND 2024",
  " AND Item_code IN (", paste0("'", items, "'", collapse = ", "), ")",
  " ORDER BY Reporter, Year, Item_code"
)

batis_filtrada <- as_tibble(dbGetQuery(con, consulta_filtro))

dbDisconnect(con, shutdown = TRUE)


# 3. CONTROLES --------------------------------------------------------------

# Esperamos 4 países x 20 años x 13 ítems = 1.040 filas.
# Si falta una combinación, no aparece como NA: directamente no hay fila.
# Por eso comparamos contra la grilla completa de combinaciones esperadas.
esperadas <- expand_grid(Reporter = paises, Year = 2005:2024, Item_code = items)

faltantes <- anti_join(esperadas, batis_filtrada,
                       by = c("Reporter", "Year", "Item_code"))

cat("Filas de la base de trabajo:", nrow(batis_filtrada), "(esperadas: 1040)\n")
cat("Combinaciones faltantes:", nrow(faltantes), "\n")
if (nrow(faltantes) > 0) print(faltantes, n = Inf)

glimpse(batis_filtrada)


# 4. GUARDADO ---------------------------------------------------------------

# La base de trabajo va en formato CSV estándar (la leen los scripts
# siguientes); las tablas de resultados, en formato Excel argentino.
write_csv(batis_filtrada, "input/batis_filtrada.csv")
guardar_tabla(dimension_completa, "output/tablas/01_dimension_base_completa.csv")
guardar_tabla(nulos_completa,     "output/tablas/01_nulos_base_completa.csv")
