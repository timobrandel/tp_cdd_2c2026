# -----------------------------------------------------------------
# Función     escalar_indices()
# Objetivo    Pasar los índices de concentración a escalas legibles antes
#             de guardar una tabla
# Entrada     tabla: data frame que puede tener cr1, cr4 (de 0 a 1) y hhi
#             (de 0 a 1)
# Salida      La misma tabla con cr1_pct y cr4_pct (en %) y hhi_x10000
#             (escala 0 a 10.000), sin las columnas originales
# -----------------------------------------------------------------
# guardar_tabla() redondea a 2 decimales, que no alcanzan para un HHI de 0 a
# 1: 0,0878 y 0,0897 quedarían iguales.

escalar_indices <- function(tabla) {
  tabla |>
    dplyr::mutate(dplyr::across(dplyr::any_of(c("cr1", "cr4")), ~ 100 * .x,
                                .names = "{.col}_pct"),
                  dplyr::across(dplyr::any_of("hhi"), ~ 10000 * .x,
                                .names = "{.col}_x10000")) |>
    dplyr::select(-dplyr::any_of(c("cr1", "cr4", "hhi")))
}
