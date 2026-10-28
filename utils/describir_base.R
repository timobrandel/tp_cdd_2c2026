# -----------------------------------------------------------------
# Función     describir_base()
# Objetivo    Resumir cada variable de una base para la tabla de
#             variables de la presentación (checklist de la clase 08)
# Entrada     datos: data frame; nombre_base: texto que identifica la base
# Salida      Tibble con una fila por variable: clase en R, valores
#             distintos, nulos (cantidad y %), ceros (solo numéricas con
#             decimales) y un resumen de los valores
# -----------------------------------------------------------------
# Requiere utils/resumir_valores.R. Para las categóricas con más de 13
# valores (socios, países) se informa la cantidad y los primeros 5, para
# que la tabla entre en una diapositiva.

describir_base <- function(datos, nombre_base) {
  tibble::tibble(
    base              = nombre_base,
    variable          = names(datos),
    clase_en_R        = purrr::map_chr(datos, ~ class(.x)[1]),
    valores_distintos = purrr::map_int(datos, dplyr::n_distinct),
    nulos             = purrr::map_int(datos, ~ sum(is.na(.x))),
    pct_nulos         = 100 * nulos / nrow(datos),
    ceros             = purrr::map_int(datos, ~ if (is.double(.x)) sum(.x == 0, na.rm = TRUE) else NA_integer_),
    valores           = purrr::map_chr(datos, function(x) {
      if (is.character(x) && dplyr::n_distinct(x) > 13) {
        paste0(dplyr::n_distinct(x), " valores (primeros: ",
               paste(head(sort(unique(x)), 5), collapse = ", "), ")")
      } else {
        resumir_valores(x)
      }
    })
  )
}
