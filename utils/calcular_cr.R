# -----------------------------------------------------------------
# Función     calcular_cr()
# Objetivo    Medir cuánto del total se llevan los k socios más grandes
#             (razón de concentración CR_k)
# Entrada     participaciones: vector de participaciones que suman 1
#             k: cantidad de socios a sumar (CR1 = el principal, CR4 = los
#             cuatro principales)
# Salida      Número entre 0 y 1
# -----------------------------------------------------------------
# Adaptada de CURSO/clases/clase12/01_concentracion_baci.R. Si hay menos de
# k socios, suma todos (y da 1).
# Ejemplo: participaciones 0,5 / 0,3 / 0,2 -> CR1 = 0,5; CR4 = 1.

calcular_cr <- function(participaciones, k = 4) {
  ordenadas <- sort(participaciones, decreasing = TRUE)
  sum(ordenadas[seq_len(min(k, length(ordenadas)))])
}
