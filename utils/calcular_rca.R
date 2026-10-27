# -----------------------------------------------------------------
# Función     calcular_rca()
# Objetivo    Calcular la ventaja comparativa revelada de Balassa (RCA)
#             de cada país en cada sector
# Entrada     datos: data frame con una fila por país y sector y las
#             columnas pais, sector y valor (valor exportado)
# Salida      El mismo data frame con la columna rca
# -----------------------------------------------------------------
# Adaptada de CURSO/clases/clase12/02_comercio_baci.R.
# RCA = (peso del sector en las exportaciones del país) /
#       (peso del sector en las exportaciones del mundo).
# RCA > 1: el país se especializa en ese sector más que el promedio mundial.
# El "mundo" son todos los países que hay en `datos`.

calcular_rca <- function(datos) {
  total_mundo <- sum(datos$valor)
  datos |>
    dplyr::group_by(pais) |>
    dplyr::mutate(peso_en_pais = valor / sum(valor)) |>
    dplyr::group_by(sector) |>
    dplyr::mutate(peso_en_mundo = sum(valor) / total_mundo) |>
    dplyr::ungroup() |>
    dplyr::mutate(rca = peso_en_pais / peso_en_mundo) |>
    dplyr::select(-peso_en_pais, -peso_en_mundo)
}
