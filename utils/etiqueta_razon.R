# -----------------------------------------------------------------
# Función     etiqueta_razon()
# Objetivo    Rotular una escala en log2 como razón entre dos valores
# Entrada     x: vector numérico en log2 (0 = iguales, 3 = 8 veces más,
#             -3 = 8 veces menos)
# Salida      Vector de texto: "x8" para 8 veces más, "/8" para 8 veces
#             menos, "x1" para iguales
# -----------------------------------------------------------------
# Se usa en la leyenda de 08_g3, con la misma notación que las celdas.

etiqueta_razon <- function(x) {
  dplyr::if_else(x >= 0, paste0("x", 2^x), paste0("/", 2^-x))
}
