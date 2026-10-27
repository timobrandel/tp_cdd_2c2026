# -----------------------------------------------------------------
# Script      05_filtrado_bilateral.R
# Objetivo    Extraer de BaTIS las dos bases de la Instancia 2:
#             (a) exportaciones de servicios de Argentina, Brasil, Chile y
#                 Uruguay a cada socio, por sector, 2005-2024;
#             (b) exportaciones al mundo de todos los países, por sector,
#                 2005-2024 (para comparar sectores con un ANOVA)
#             y controlar su cobertura y el origen del dato bilateral
# Entrada     raw/OECD-WTO_BATIS_BPM6_December2025_bulk.csv (~2,98 GB)
#             raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx
# Salida      input/batis_bilateral.csv
#             input/batis_mundo_sectores.csv
#             output/tablas/05_cobertura_bases.csv
#             output/tablas/05_control_suma_socios.csv
#             output/tablas/05_origen_bilateral.csv
#             output/tablas/05_ceros_bilateral.csv
#             output/tablas/05_resto_del_mundo.csv
# -----------------------------------------------------------------
# Requiere haber corrido antes 00_descarga_datos.R.
# Igual que en el 01, DuckDB filtra el CSV grande desde el disco y le pasa
# a R solo las filas que necesitamos (D-011).
#
# Medida: para lo bilateral se usa Balanced_value (D-023). La metodología
# de BaTIS (secciones 5.1 y 6) lo recomienda para los flujos entre pares
# de países: concilia lo que declara el exportador con lo que declara el
# importador y completa los pares que nadie informa. Final_value y
# Reported_value se conservan para diagnosticar el origen del dato.

library(tidyverse)
library(readxl)
library(DBI)     # interfaz para conectar R con bases de datos
library(duckdb)  # motor que consulta el CSV sin cargarlo en memoria

source("utils/guardar_tabla.R")       # tablas listas para Excel argentino
source("utils/clasificar_origen.R")   # informado / derivado / estimado
source("utils/lista_sql.R")           # valores para los filtros IN de SQL

archivo_batis <- "raw/OECD-WTO_BATIS_BPM6_December2025_bulk.csv"
archivo_codigos <- "raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx"
stopifnot(file.exists(archivo_batis), file.exists(archivo_codigos))

dir.create("input", showWarnings = FALSE)
dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)

paises  <- c("AR", "BR", "CL", "UY")
anios   <- 2005:2024
# S = total de servicios; SA a SL = las 12 categorías principales de EBOPS 2010
items   <- c("S", "SA", "SB", "SC", "SD", "SE", "SF",
             "SG", "SH", "SI", "SJ", "SK", "SL")
sectores <- setdiff(items, "S")

con <- dbConnect(duckdb(shared_home = FALSE))

# Mismos tipos declarados que en el 01 (ver ahí el porqué).
tabla_batis <- paste0(
  "read_csv('", archivo_batis, "', header = true, types = {",
  "'Reporter': 'VARCHAR', 'type_Reporter': 'VARCHAR', ",
  "'Partner': 'VARCHAR', 'type_Partner': 'VARCHAR', ",
  "'Flow': 'VARCHAR', 'Item_code': 'VARCHAR', 'type_Item': 'VARCHAR', ",
  "'Year': 'INTEGER', 'Reported_value': 'DOUBLE', 'Final_value': 'DOUBLE', ",
  "'Final_value_methodology': 'VARCHAR', 'Balanced_value': 'DOUBLE'})"
)

# Columnas que se conservan. Flow siempre es X y los type_ son constantes
# dentro de cada base, así que no se guardan.
columnas <- "Reporter, Partner, Item_code, Year, Reported_value,
             Final_value, Final_value_methodology, Balanced_value"


# 1. EXTRACCIÓN ---------------------------------------------------------------

# Una sola lectura del CSV: DuckDB guarda en una tabla temporal las filas
# que sirven a cualquiera de las dos bases y después se separan.
invisible(dbExecute(con, paste0(
  "CREATE TEMP TABLE seleccion AS SELECT * FROM ", tabla_batis,
  " WHERE Flow = 'X'",
  " AND Year BETWEEN ", min(anios), " AND ", max(anios),
  " AND Item_code IN (", lista_sql(items), ")",
  " AND type_Reporter = 'c'",
  " AND ((Reporter IN (", lista_sql(paises), ") AND type_Partner = 'c')",
  "      OR Partner = 'WL')"
)))

# (a) Base bilateral: los 4 países contra cada socio individual.
# type_Partner = 'c' deja afuera al único agregado, WL (el mundo); si se
# sumara junto con los socios, el total quedaría contado dos veces.
# ROW ("Rest of the World") figura como 'c' en el diccionario: es el
# residuo de economías sin dato propio. Se conserva (es parte del total)
# y se marca para decidir en el análisis si entra como socio (sección 4).
bilateral <- as_tibble(dbGetQuery(con, paste0(
  "SELECT ", columnas, " FROM seleccion",
  " WHERE Reporter IN (", lista_sql(paises), ") AND type_Partner = 'c'",
  " ORDER BY Reporter, Year, Item_code, Partner"
)))

# (b) Base de sectores: todos los países informantes al mundo.
mundo_sectores <- as_tibble(dbGetQuery(con, paste0(
  "SELECT ", columnas, " FROM seleccion WHERE Partner = 'WL'",
  " ORDER BY Reporter, Year, Item_code"
)))

dbDisconnect(con, shutdown = TRUE)

# Nombres de países desde la hoja "economies" del diccionario, para que las
# tablas se lean sin buscar los códigos.
economias <- read_excel(archivo_codigos, sheet = "economies") |>
  select(codigo = Code, nombre = `Code description`)

bilateral <- bilateral |>
  left_join(rename(economias, Partner = codigo, nombre_socio = nombre),
            by = "Partner") |>
  mutate(es_resto_mundo = Partner == "ROW",
         origen = clasificar_origen(Final_value_methodology))

mundo_sectores <- mundo_sectores |>
  left_join(rename(economias, Reporter = codigo, nombre_pais = nombre),
            by = "Reporter") |>
  mutate(origen = clasificar_origen(Final_value_methodology))


# 2. CONTROLES DE COBERTURA ---------------------------------------------------

# Una combinación que falta no aparece como NA: directamente no hay fila.
# Por eso se compara contra una grilla esperada.
# La grilla no puede ser "todos los socios en todos los años": BaTIS sigue
# los cambios territoriales y algunas economías existen solo en parte del
# período (Yugoslavia hasta 2005; Serbia y Montenegro desde 2006; Antillas
# Neerlandesas hasta 2010; Curazao y Sint Maarten desde 2011; Kosovo, código
# 888, desde 2008). Una economía "existe" un año si figura ese año como
# informante en la base al mundo.
economias_por_anio <- mundo_sectores |> distinct(Reporter, Year)

# ROW es socio pero nunca informante, así que se agrega a mano como socio
# en todos los años.
socios_por_anio <- economias_por_anio |>
  rename(Partner = Reporter) |>
  bind_rows(tibble(Partner = "ROW", Year = anios))

esperadas_bilateral <- expand_grid(Reporter = paises, Item_code = items) |>
  cross_join(socios_por_anio) |>
  filter(Reporter != Partner)   # un país no se exporta a sí mismo
esperadas_mundo <- economias_por_anio |>
  cross_join(tibble(Item_code = items))

faltan_bilateral <- anti_join(esperadas_bilateral, bilateral,
                              by = c("Reporter", "Partner", "Item_code", "Year"))
faltan_mundo <- anti_join(esperadas_mundo, mundo_sectores,
                          by = c("Reporter", "Item_code", "Year"))

# Control inverso: filas que están en la base pero no en la grilla
# (indicaría un socio o un año inesperado).
sobran_bilateral <- anti_join(bilateral, esperadas_bilateral,
                              by = c("Reporter", "Partner", "Item_code", "Year"))

# Economías con menos de 20 años de datos (por los cambios territoriales).
economias_parciales <- economias_por_anio |>
  count(Reporter, name = "anios_presentes") |>
  filter(anios_presentes < length(anios))
print(economias_parciales)

cobertura <- tibble(
  base              = c("bilateral", "mundo_sectores"),
  filas             = c(nrow(bilateral), nrow(mundo_sectores)),
  filas_esperadas   = c(nrow(esperadas_bilateral), nrow(esperadas_mundo)),
  combinaciones_faltantes = c(nrow(faltan_bilateral), nrow(faltan_mundo)),
  filas_fuera_de_grilla   = c(nrow(sobran_bilateral), 0),
  informantes       = c(n_distinct(bilateral$Reporter),
                        n_distinct(mundo_sectores$Reporter)),
  socios            = c(n_distinct(bilateral$Partner), 1),
  nulos_balanceado  = c(sum(is.na(bilateral$Balanced_value)),
                        sum(is.na(mundo_sectores$Balanced_value))),
  ceros_balanceado  = c(sum(bilateral$Balanced_value == 0, na.rm = TRUE),
                        sum(mundo_sectores$Balanced_value == 0, na.rm = TRUE))
)
print(cobertura)

# Si la grilla no está completa o hay filas inesperadas, el script se frena:
# los índices de concentración supondrían socios que no están.
stopifnot(
  nrow(faltan_bilateral) == 0, nrow(faltan_mundo) == 0,
  nrow(sobran_bilateral) == 0,
  !anyNA(bilateral$Balanced_value), !anyNA(bilateral$Final_value),
  !anyNA(mundo_sectores$Balanced_value), !anyNA(mundo_sectores$Final_value)
)

# La suma de los socios tiene que reproducir el total al mundo (WL) de cada
# país, sector y año. Si no, faltan socios o hay doble conteo.
control_suma <- bilateral |>
  group_by(Reporter, Item_code, Year) |>
  summarise(suma_socios = sum(Balanced_value), .groups = "drop") |>
  inner_join(mundo_sectores |>
               filter(Reporter %in% paises) |>
               select(Reporter, Item_code, Year, total_mundo = Balanced_value),
             by = c("Reporter", "Item_code", "Year")) |>
  mutate(diferencia = suma_socios - total_mundo)

# Tolerancia de 0,001 millones de USD (mil dólares): lo que queda son
# diferencias de redondeo del archivo original.
stopifnot(max(abs(control_suma$diferencia)) < 1e-3)

cat("Máxima diferencia absoluta entre suma de socios y total al mundo:",
    max(abs(control_suma$diferencia)), "millones de USD\n")

# Para la tabla alcanza con el resumen por país.
resumen_suma <- control_suma |>
  group_by(Reporter) |>
  summarise(combinaciones = n(),
            max_dif_absoluta = max(abs(diferencia)),
            .groups = "drop")

# La suma de los 12 sectores tiene que dar el total de servicios (S).
control_sectores <- mundo_sectores |>
  group_by(Reporter, Year) |>
  summarise(dif = sum(Balanced_value[Item_code != "S"]) -
                  sum(Balanced_value[Item_code == "S"]),
            .groups = "drop")
cat("Máxima diferencia entre suma de sectores y total (S):",
    max(abs(control_sectores$dif)), "millones de USD\n")


# 3. ORIGEN DEL DATO BILATERAL ------------------------------------------------

# El balanceado no tiene faltantes porque OCDE-OMC completa los pares que
# ningún país informa. La columna `origen` clasifica el código de
# Final_value_methodology: dice si el país EXPORTADOR declaró su venta a
# cada socio o si la estimó OCDE-OMC. El balanceado nunca es "dato
# informado" a secas, porque combina esa declaración con la del importador
# (metodología, sección 5.1). `origen` mide si la parte del exportador es
# propia o estimada.
# Se mide qué parte del valor exportado (total de servicios) tiene origen
# en una fuente oficial, por país y año.
origen_bilateral <- bilateral |>
  filter(Item_code == "S") |>
  group_by(Reporter, Year) |>
  summarise(
    valor_total         = sum(Balanced_value),
    pct_valor_informado = 100 * sum(Balanced_value[origen == "Informado por fuente oficial"]) /
                          valor_total,
    pct_valor_derivado  = 100 * sum(Balanced_value[origen == "Derivado de datos informados"]) /
                          valor_total,
    pct_valor_estimado  = 100 * sum(Balanced_value[origen == "Estimado por OCDE-OMC"]) /
                          valor_total,
    socios_con_dato_oficial = sum(origen == "Informado por fuente oficial"),
    .groups = "drop"
  )

print(origen_bilateral |>
        filter(Year %in% c(2005, 2010, 2015, 2020, 2024)),
      n = Inf)


# 4. CEROS Y RESTO DEL MUNDO --------------------------------------------------

# Un cero es una venta a ese socio que no se registra ni se estima: puede
# declararlo el país, o estimarlo OCDE-OMC (despreciable, E0, o un cero de
# su modelo). La mayoría son del modelo (06_diagnostico_resumen).
# En el HHI pesa cero; la tabla muestra cuántos socios no compran nada.
ceros_bilateral <- bilateral |>
  filter(Year == max(anios)) |>
  group_by(Reporter, Item_code) |>
  summarise(socios = n(),
            socios_con_cero = sum(Balanced_value == 0),
            pct_ceros = 100 * socios_con_cero / socios,
            .groups = "drop")

# Peso de ROW en el total de cada país: si es chico, excluirlo del cálculo
# de concentración no cambia los resultados.
resto_mundo <- bilateral |>
  filter(Item_code == "S") |>
  group_by(Reporter, Year) |>
  summarise(pct_resto_mundo = 100 * sum(Balanced_value[es_resto_mundo]) /
                              sum(Balanced_value),
            .groups = "drop")

cat("Peso máximo de ROW en el total de un país-año:",
    round(max(resto_mundo$pct_resto_mundo), 2), "%\n")


# 5. GUARDADO -----------------------------------------------------------------

# Bases de trabajo en CSV estándar (las leen los scripts siguientes);
# tablas de resultados en formato Excel argentino (D-016).
# Trampa: el código ISO de Namibia es "NA", el mismo texto con el que R
# escribe y lee los faltantes. Por eso los faltantes se guardan como celda
# vacía (na = "") y los scripts siguientes leen con na = "": así "NA" solo
# puede ser Namibia.
write_csv(bilateral, "input/batis_bilateral.csv", na = "")
write_csv(mundo_sectores, "input/batis_mundo_sectores.csv", na = "")

guardar_tabla(cobertura,        "output/tablas/05_cobertura_bases.csv")
guardar_tabla(resumen_suma,     "output/tablas/05_control_suma_socios.csv")
guardar_tabla(origen_bilateral, "output/tablas/05_origen_bilateral.csv")
guardar_tabla(ceros_bilateral,  "output/tablas/05_ceros_bilateral.csv")
guardar_tabla(resto_mundo,      "output/tablas/05_resto_del_mundo.csv")
