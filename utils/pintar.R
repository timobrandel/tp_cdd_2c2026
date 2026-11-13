# -----------------------------------------------------------------
# Función     pintar()
# Objetivo    Escribir una palabra de un color dentro de un título o una
#             anotación, para que el texto haga de leyenda (clase 24)
# Entrada     texto: lo que se quiere pintar; color: color en hexadecimal;
#             negrita: TRUE para resaltarlo además en negrita
# Salida      El texto envuelto en HTML, que ggtext sabe dibujar
# -----------------------------------------------------------------
# Solo funciona en elementos de tipo ggtext::element_markdown() (el título
# de tema_tp()) y en geom_richtext().

pintar <- function(texto, color, negrita = TRUE) {
  if (negrita) texto <- paste0("<b>", texto, "</b>")
  sprintf("<span style='color:%s'>%s</span>", color, texto)
}
