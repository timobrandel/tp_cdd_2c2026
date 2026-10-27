# -----------------------------------------------------------------
# Función     lista_sql()
# Objetivo    Armar la lista de valores de un filtro IN de SQL
# Entrada     x: vector de texto (por ejemplo, códigos de países)
# Salida      Un solo texto con los valores entre comillas simples y
#             separados por comas: 'AR', 'BR', 'CL'
# -----------------------------------------------------------------
# Se usa para escribir las consultas de DuckDB que filtran el CSV grande.

lista_sql <- function(x) {
  paste0("'", x, "'", collapse = ", ")
}
