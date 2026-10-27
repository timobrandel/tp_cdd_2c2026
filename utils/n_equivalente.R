# -----------------------------------------------------------------
# Función     n_equivalente()
# Objetivo    Traducir el HHI a una cantidad de socios fácil de interpretar
# Entrada     hhi: HHI entre 0 y 1
# Salida      Cantidad de socios de igual tamaño que darían ese mismo HHI
# -----------------------------------------------------------------
# Adaptada de CURSO/clases/clase12/01_concentracion_baci.R.
# Ejemplo: HHI = 0,25 equivale a vender lo mismo a 4 socios (1 / 0,25).

n_equivalente <- function(hhi) {
  1 / hhi
}
