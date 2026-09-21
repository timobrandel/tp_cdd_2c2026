# -----------------------------------------------------------------
# Función     guardar_tabla()
# Objetivo    Guardar una tabla de resultados lista para abrir con doble
#             clic en un Excel con configuración argentina
# Entrada     tabla: data frame; archivo: ruta del CSV de salida
# Salida      CSV separado por ";" con coma decimal y codificación UTF-8
#             con marca BOM (así Excel reconoce los acentos). Los números
#             con decimales se redondean a 2 decimales.
# -----------------------------------------------------------------
# Para volver a leer estas tablas desde R se usa readr::read_csv2().

guardar_tabla <- function(tabla, archivo) {
  tabla |>
    dplyr::mutate(dplyr::across(dplyr::where(is.double), ~ round(.x, 2))) |>
    readr::write_excel_csv2(archivo)
}
