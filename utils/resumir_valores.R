# -----------------------------------------------------------------
# Función     resumir_valores()
# Objetivo    Resumir en una frase los valores que toma una variable,
#             para la tabla de variables de la presentación
# Entrada     x: vector (una columna de la base)
# Salida      Texto. Enteros (como el año): mínimo y máximo sin separador
#             de miles. Numéricas: mínimo y máximo con 2 decimales en
#             formato argentino. Categóricas: los valores distintos
#             (hasta 13).
# -----------------------------------------------------------------

resumir_valores <- function(x) {
  if (is.integer(x)) {
    paste0("mín. ", min(x, na.rm = TRUE), " / máx. ", max(x, na.rm = TRUE))
  } else if (is.numeric(x)) {
    formato <- function(v) {
      format(round(v, 2), big.mark = ".", decimal.mark = ",", scientific = FALSE)
    }
    paste0("mín. ", formato(min(x, na.rm = TRUE)),
           " / máx. ", formato(max(x, na.rm = TRUE)))
  } else {
    valores <- sort(unique(x))
    paste(head(valores, 13), collapse = ", ")
  }
}
