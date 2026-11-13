# -----------------------------------------------------------------
# Función     tema_tp()
# Objetivo    Dar a todos los gráficos del TP el mismo aspecto: el "tema
#             de la casa" de la clase 22 con el lenguaje de Our World in
#             Data de la clase 24
# Entrada     base_size: tamaño de letra base, en puntos
# Salida      Un tema de ggplot2 para sumar con "+ tema_tp()"
# -----------------------------------------------------------------
# Decisiones de diseño (clases 21, 22 y 24):
# - título en negrita y alineado con el borde de la imagen; admite palabras
#   de color (ggtext), que reemplazan a la leyenda;
# - subtítulo y fuente en gris, para que no compitan con el título;
# - sin grilla menor y con fondo blanco (el JPG no tiene transparencia);
# - leyenda abajo, cuando hace falta.

tema_tp <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.title    = ggtext::element_markdown(face = "bold", size = ggplot2::rel(1.4),
                                               lineheight = 1.2,
                                               margin = ggplot2::margin(b = 8)),
      plot.subtitle = ggplot2::element_text(color = "gray30", size = ggplot2::rel(0.95),
                                            lineheight = 1.2,
                                            margin = ggplot2::margin(b = 14)),
      plot.caption  = ggplot2::element_text(color = "gray40", size = ggplot2::rel(0.68),
                                            hjust = 0, lineheight = 1.2,
                                            margin = ggplot2::margin(t = 12)),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position  = "bottom",
      plot.background  = ggplot2::element_rect(fill = "white", color = NA),
      plot.margin      = ggplot2::margin(14, 16, 10, 14)
    )
}
