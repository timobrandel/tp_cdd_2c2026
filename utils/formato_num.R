# -----------------------------------------------------------------
# Función     formato_num()
# Objetivo    Escribir números con formato argentino para textos de
#             tablas, títulos y consola
# Entrada     x: vector numérico; d: cantidad de decimales
# Salida      Vector de texto con punto de miles y coma decimal, sin
#             espacios de relleno (1234,5 → "1.234,5")
# -----------------------------------------------------------------
# trimws(): format() rellena con espacios para que todos los elementos del
# vector tengan el mismo ancho, y en un texto eso deja huecos.

formato_num <- function(x, d = 1) {
  trimws(format(round(x, d), nsmall = d, big.mark = ".", decimal.mark = ",",
                scientific = FALSE))
}
