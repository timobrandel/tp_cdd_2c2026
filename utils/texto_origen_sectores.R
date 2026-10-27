# -----------------------------------------------------------------
# Función     texto_origen_sectores()
# Objetivo    Resumir en una línea qué parte de cada sector de un país
#             tiene la distribución por socio estimada por OCDE-OMC
# Entrada     origen_por_sector: tabla del script 06 con las columnas
#             Reporter, Item_code, periodo y pct_valor_estimado;
#             pais: código del país ("AR", "BR", "CL" o "UY")
# Salida      Un texto como "SA 100%, SB 56%, SC 0%, ..."
# -----------------------------------------------------------------
# Se usa para la columna de magnitudes de 06_diagnostico_resumen.

texto_origen_sectores <- function(origen_por_sector, pais) {
  origen_por_sector |>
    dplyr::filter(Reporter == pais, periodo == "2015-2024") |>
    dplyr::mutate(texto = paste0(Item_code, " ", round(pct_valor_estimado), "%")) |>
    dplyr::pull(texto) |>
    paste(collapse = ", ")
}
