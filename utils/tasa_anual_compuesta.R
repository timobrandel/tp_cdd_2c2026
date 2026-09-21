# -----------------------------------------------------------------
# Función     tasa_anual_compuesta()
# Objetivo    Traducir un crecimiento acumulado a un ritmo anual
#             equivalente, comparable entre países y períodos
# Entrada     valor_inicial, valor_final: niveles al principio y al final
#             anios: cantidad de años entre ambos (2005 a 2024 = 19)
# Salida      Tasa anual compuesta, en porcentaje
# -----------------------------------------------------------------
# Fórmula: ((valor_final / valor_inicial)^(1 / anios) - 1) * 100.
# Ejemplo: pasar de 100 a 200 en 10 años equivale a crecer 7,18% por año.

tasa_anual_compuesta <- function(valor_inicial, valor_final, anios) {
  ((valor_final / valor_inicial)^(1 / anios) - 1) * 100
}
