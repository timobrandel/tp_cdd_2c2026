# -----------------------------------------------------------------
# Función     calcular_hhi()
# Objetivo    Medir la concentración de una distribución con el índice de
#             Herfindahl-Hirschman (HHI)
# Entrada     participaciones: vector de participaciones que suman 1
# Salida      Número entre 1/N (todos iguales) y 1 (un solo socio)
# -----------------------------------------------------------------
# Adaptada de CURSO/clases/clase12/01_concentracion_baci.R.
# Es la suma de los cuadrados de las participaciones: al elevar al cuadrado,
# los socios grandes pesan mucho más que los chicos.
# Ejemplo: 0,5 / 0,3 / 0,2 -> 0,25 + 0,09 + 0,04 = 0,38 (3.800 en la escala
# 0-10.000 que usan los organismos de competencia).

calcular_hhi <- function(participaciones) {
  sum(participaciones^2)
}
