# -----------------------------------------------------------------
# Función     promediar_indices()
# Objetivo    Resumir en un período los índices de concentración anuales
# Entrada     datos: tabla agrupada (group_by) con una fila por año y las
#             columnas cr1, cr4, hhi, socios_con_ventas y pct_estimado
# Salida      Una fila por grupo con el promedio de cada índice y los
#             socios equivalentes del HHI promedio
# -----------------------------------------------------------------
# Los socios equivalentes se calculan como 1 / (HHI promedio) y no como el
# promedio de los 1 / HHI anuales. Así la tabla cumple siempre
# socios_equivalentes = 1 / hhi. Promediar los inversos da otro número
# (desigualdad de Jensen): en un año muy repartido, 1 / HHI se dispara y
# arrastra el promedio (QA-004, M3).

promediar_indices <- function(datos) {
  datos |>
    dplyr::summarise(
      anios             = dplyr::n(),
      cr1               = mean(cr1),
      cr4               = mean(cr4),
      hhi               = mean(hhi),
      socios_con_ventas = mean(socios_con_ventas),
      pct_estimado      = mean(pct_estimado),
      .groups = "drop"
    ) |>
    dplyr::mutate(socios_equivalentes = 1 / hhi)
}
