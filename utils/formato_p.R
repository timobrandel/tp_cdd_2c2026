# -----------------------------------------------------------------
# Función     formato_p()
# Objetivo    Escribir p-valores para tablas y gráficos
# Entrada     p: vector de p-valores
# Salida      Vector de texto: "< 0,001" si p es menor que 0,001; si no,
#             el valor con 3 decimales y coma decimal
# -----------------------------------------------------------------
# Un p-valor redondeado a 0 no es un p-valor posible: por eso los muy chicos
# se escriben como cota.

formato_p <- function(p) {
  dplyr::if_else(p < 0.001, "< 0,001",
                 trimws(format(round(p, 3), nsmall = 3, decimal.mark = ",")))
}
