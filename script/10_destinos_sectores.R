# -----------------------------------------------------------------
# Script      10_destinos_sectores.R
# Objetivo    Mostrar a quién le vende cada sector de servicios: cuánto de
#             lo exportado compran Estados Unidos y el resto de América del
#             Sur, y armar con eso los dos gráficos de la Instancia 3 (uno
#             exploratorio y uno comunicativo)
# Entrada     input/batis_bilateral.csv
#             output/tablas/07_concentracion_sectores.csv
# Salida      output/tablas/10_destinos_sectores.csv
#             output/graficos/grupo_26_exploratorio.jpg
#             output/graficos/grupo_26_comunicativo.jpg
# -----------------------------------------------------------------
# Requiere haber corrido antes 05_filtrado_bilateral.R y
# 07_concentracion_socios.R.
#
# Hallazgo que se comunica (D-034): a quién le vende Argentina depende de
# qué vende. Comparamos el peso de EE.UU. y Sudamérica dentro de cada
# sector, sin afirmar que sean los únicos destinos ni medir aquí el HHI.
# Sudamérica supera a EE.UU. en viajes; el orden se invierte en los cuatro
# rubros del conocimiento. No es una explicación causal.
#
# Decisiones (D-036):
# - Mismo método que el 07: participación de cada socio en lo exportado.
#   Acá se suman dos grupos de socios: Estados Unidos y el resto de América
#   del Sur.
# - "Resto de América del Sur": los doce países soberanos del subcontinente,
#   sin contar al exportador. Es la misma definición para los cuatro países,
#   así que el gráfico exploratorio los compara con la misma vara.
# - La participación se calcula sobre el valor acumulado de 2015-2024, como
#   en 07_principales_socios: responde "de cada 100 dólares exportados en el
#   período, cuántos compró cada destino".
# - Medida principal: Balanced_value (D-023, D-029). El valor final se
#   calcula al lado y el script frena si el hallazgo no se sostiene con las
#   dos medidas.
# - ROW (resto del mundo) se excluye: es un residuo, no un comprador.
# - Valores en millones de USD corrientes (sin deflactar).

# Preparación del proceso, antes de cargar paquetes (ver QA-007 y D-037).
source("utils/preparar_entorno_graficos.R")
preparar_entorno_graficos()

library(tidyverse)
library(scales)
library(ggtext)    # palabras de color en el título (clase 24)
library(ggrepel)   # etiquetas que no se pisan (clases 22 y 24)

source("utils/guardar_tabla.R")
source("utils/formato_num.R")
source("utils/tema_tp.R")
source("utils/pintar.R")

dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)
dir.create("output/graficos", recursive = TRUE, showWarnings = FALSE)

# na = "": el código de Namibia es "NA" (ver el 05)
bilateral <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)

# Las tablas de output/tablas/ están en formato Excel argentino (D-016):
# separador ";" y coma decimal
concentracion_sectores <- read_delim(
  "output/tablas/07_concentracion_sectores.csv", delim = ";",
  locale = locale(decimal_mark = ",", grouping_mark = "."),
  show_col_types = FALSE
)


# 1. PARÁMETROS ------------------------------------------------------------------

periodo_analisis <- 2015:2024

etiquetas_paises <- c(AR = "Argentina", BR = "Brasil", CL = "Chile", UY = "Uruguay")

# Nombres cortos: tienen que entrar como etiqueta dentro del gráfico
etiquetas_servicios <- c(
  S  = "Total de servicios",
  SA = "Manufactura sobre insumos de terceros",
  SB = "Mantenimiento y reparación",
  SC = "Transporte",
  SD = "Viajes",
  SE = "Construcción",
  SF = "Seguros y pensiones",
  SG = "Financieros",
  SH = "Propiedad intelectual",
  SI = "Telecomunicaciones, informática e información",
  SJ = "Otros servicios empresariales",
  SK = "Personales, culturales y recreativos",
  SL = "Bienes y servicios del gobierno"
)

# Nombres todavía más cortos, para rotular los círculos del exploratorio
etiquetas_cortas <- c(
  SA = "Serv. de\nmanufactura", SB = "Mantenimiento", SC = "Transporte", SD = "Viajes",
  SE = "Construcción", SF = "Seguros", SG = "Financieros",
  SH = "Prop. intelectual", SI = "Telecomunicaciones,\ninformática e\ninformación",
  SJ = "Empresariales", SK = "Personales,\nculturales y\nrecreativos", SL = "Gobierno"
)

etiquetas_medidas <- c(Balanced_value = "balanceado", Final_value = "final")

# Los doce países soberanos de América del Sur (códigos ISO de dos letras)
america_del_sur <- c("AR", "BO", "BR", "CL", "CO", "EC", "GY", "PY", "PE",
                     "SR", "UY", "VE")

# La agrupación amplia de servicios del conocimiento reúne SH, SI, SJ y SK.
# El CEI la usa para comparar países con estas doce categorías agregadas.
# No equivale a la definición desagregada ni a servicios prestados por internet.
# Fuente: CEI, Comercio de servicios de Argentina en 2025, p. 5:
# https://cancilleria.gob.ar/userfiles/ut/2026-06_analisis_del_comercio_de_servicios_de_la_argentina_2026.pdf
tipos_servicio <- c(
  SD = "Presenciales (viajes y transporte)",
  SC = "Presenciales (viajes y transporte)",
  SH = "Basados en el conocimiento",
  SI = "Basados en el conocimiento",
  SJ = "Basados en el conocimiento",
  SK = "Basados en el conocimiento"
)
niveles_tipo <- c("Presenciales (viajes y transporte)",
                  "Basados en el conocimiento", "Otros servicios")
sectores_conocimiento <- names(tipos_servicio)[tipos_servicio == "Basados en el conocimiento"]

# Colores con función (clase 21): un color por destino en el comunicativo y
# un color por tipo de servicio en el exploratorio. Se distinguen también en
# escala de grises y no dependen del par rojo-verde.
color_eeuu   <- "#D95F02"   # naranja
color_region <- "#1F5FA8"   # azul
colores_tipo <- c("Presenciales (viajes y transporte)" = "#3B8F86",
                  "Basados en el conocimiento"         = "#352050",
                  "Otros servicios"                    = "#B8B8B8")

fuente <- paste0("Fuente: elaboración propia con datos de OECD-WTO BaTIS ",
                 "(BPM6, versión dic. 2025).")

# Tamaño de la imagen: se fija en centímetros y se exporta a 300 dpi. Si se
# cambia el tamaño, las letras quedan desproporcionadas (clase 24).
# Diego: editá textos y colores en esta sección y en los bloques 4 y 5.
# Mantené las escalas comunes del exploratorio y ejecutá el archivo completo.
# Los cálculos están en el bloque 2; los controles económicos, en el bloque 3.
ancho_cm <- 24
alto_exploratorio_cm <- 29.5
alto_comunicativo_cm <- 19.5
resolucion_dpi <- 300


# 2. DESTINO DE LO EXPORTADO POR PAÍS Y SECTOR -----------------------------------

destinos <- bilateral |>
  filter(Year %in% periodo_analisis, !es_resto_mundo) |>
  pivot_longer(c(Balanced_value, Final_value),
               names_to = "medida", values_to = "valor") |>
  mutate(medida = unname(etiquetas_medidas[medida])) |>
  group_by(medida, Reporter, Item_code) |>
  summarise(
    valor_musd_corrientes = sum(valor, na.rm = TRUE),
    valor_eeuu            = sum(valor[Partner == "US"], na.rm = TRUE),
    # El exportador no se cuenta como comprador de sí mismo
    valor_region          = sum(valor[Partner %in% america_del_sur & Partner != Reporter],
                                na.rm = TRUE),
    .groups = "drop"
  ) |>
  # Chile nunca informa cuatro sectores chicos: en el valor final suman cero
  # y no se puede calcular una participación
  filter(valor_musd_corrientes > 0) |>
  group_by(medida, Reporter) |>
  mutate(peso_pct = 100 * valor_musd_corrientes /
                    valor_musd_corrientes[Item_code == "S"]) |>
  ungroup() |>
  mutate(
    pct_eeuu   = 100 * valor_eeuu / valor_musd_corrientes,
    pct_region = 100 * valor_region / valor_musd_corrientes,
    Pais       = unname(etiquetas_paises[Reporter]),
    Servicio   = unname(etiquetas_servicios[Item_code]),
    tipo       = coalesce(unname(tipos_servicio[Item_code]), "Otros servicios"),
    tipo       = if_else(Item_code == "S", "Total", tipo)
  ) |>
  # Parte del valor cuya venta a cada socio no declara el exportador (07)
  left_join(
    concentracion_sectores |> select(medida, Reporter, Item_code, pct_estimado),
    by = c("medida", "Reporter", "Item_code")
  ) |>
  select(medida, Reporter, Pais, Item_code, Servicio, tipo, valor_musd_corrientes,
         peso_pct, pct_eeuu, pct_region, pct_estimado) |>
  arrange(medida, Reporter, desc(peso_pct))

guardar_tabla(destinos, "output/tablas/10_destinos_sectores.csv")

cat("\nDestino de lo exportado por Argentina, 2015-2024:\n")
print(destinos |> filter(Reporter == "AR") |>
        select(medida, Servicio, peso_pct, pct_eeuu, pct_region), n = Inf)


# 3. CONTROLES: EL HALLAZGO SE SOSTIENE CON LAS DOS MEDIDAS ----------------------

# El título del comunicativo afirma dos cosas. Si alguna deja de cumplirse
# (por ejemplo, con una versión nueva de la base), el script frena: se cambia
# el título, no los datos (clase 24).
argentina <- destinos |> filter(Reporter == "AR")

viajes_transporte_a_la_region <- argentina |>
  filter(Item_code %in% c("SD", "SC")) |>
  summarise(cumple = n() == 4L && all(pct_region > pct_eeuu)) |>
  pull(cumple)

conocimiento_a_eeuu <- argentina |>
  filter(Item_code %in% sectores_conocimiento) |>
  summarise(cumple = n() == 8L && all(pct_eeuu > pct_region)) |>
  pull(cumple)

stopifnot(
  "Viajes/transporte: revisar cobertura o predominio de Sudamérica" = viajes_transporte_a_la_region,
  "Conocimiento: EE.UU. ya no supera a América del Sur con las dos medidas" = conocimiento_a_eeuu
)
cat("\nControl: el hallazgo se cumple con el valor balanceado y con el final.\n")


# 4. GRÁFICO EXPLORATORIO --------------------------------------------------------

# Un panel por país, con escalas idénticas y números en todos los ejes.
# La diagonal es la única referencia: y = x. No representa una regresión.
# Conservamos el criterio de cobertura del 07: promedio anual, sin ponderar.
explorar <- destinos |>
  filter(medida == "balanceado", Item_code != "S") |>
  mutate(
    Pais = factor(Pais, levels = unname(etiquetas_paises)),
    tipo = factor(tipo, levels = niveles_tipo),
    dato = if_else(pct_estimado > 50, "Más de 50%", "Hasta 50%"),
    etiqueta = if_else(peso_pct >= 3 | pct_eeuu >= 40 | pct_region >= 35,
                       unname(etiquetas_cortas[Item_code]), NA_character_)
  )

# Posiciones iniciales de las etiquetas, en las unidades de los ejes.
# Solo mueven textos: los círculos conservan sus coordenadas calculadas.
# Diego puede ajustar estas posiciones; ggrepel evita superposiciones finales.
posiciones_etiquetas <- tribble(
  ~Reporter, ~Item_code, ~rotulo_x, ~rotulo_y,
  "AR", "SA", 14, 57,  "AR", "SD", 19, 48,
  "AR", "SC", 13, 35,  "AR", "SI", 36, 30,
  "AR", "SJ", 23, 8,   "AR", "SH", 49, 15,
  "AR", "SK", 67, 22,  "AR", "SG", 55, 3,
  "BR", "SD", 17, 27,  "BR", "SC", 11, 15,
  "BR", "SJ", 15, 2,   "BR", "SI", 33, 18,
  "BR", "SK", 52, 21,  "BR", "SG", 64, 5,
  "CL", "SD", 12, 40,  "CL", "SC", 45, 17,
  "CL", "SJ", 14, 4,   "CL", "SI", 27, 27,
  "CL", "SK", 65, 14,
  "UY", "SA", 13, 52,  "UY", "SD", 24, 41,
  "UY", "SC", 10, 32,  "UY", "SJ", 13, 10,
  "UY", "SI", 29, 28,  "UY", "SG", 36, 15
)
explorar <- explorar |>
  left_join(posiciones_etiquetas, by = c("Reporter", "Item_code")) |>
  mutate(desplazar_x = coalesce(rotulo_x - pct_eeuu, 0),
         desplazar_y = coalesce(rotulo_y - pct_region, 0))

subtitulo_exp <- paste(
  "Cada círculo es un sector del país exportador; su área indica su peso en las exportaciones totales.",
  "El eje horizontal muestra qué porcentaje de lo exportado por el sector compró Estados Unidos.",
  "El eje vertical muestra qué porcentaje compró el resto de América del Sur.",
  "Las participaciones se calculan sobre el valor acumulado entre 2015 y 2024.",
  "Sobre la diagonal ambos destinos pesan igual; por encima pesa más Sudamérica y por debajo, Estados Unidos.",
  sep = "\n"
)

pie_exp <- paste(
  "Fuente: OECD-WTO BaTIS (BPM6, dic. 2025). Balanceado; USD corrientes acumulados; socios identificados (sin ROW).",
  "Sudamérica: los otros once países. Conocimiento: aproximación agregada de cuatro rubros (CEI).",
  "*Valor estimado: sin declaración bilateral del exportador, en promedio anual. No mide todo el ajuste del balanceado.",
  "Chile: OCDE-OMC estima todos los sectores en 2023–2024; además, cuatro sectores carecen de declaración en todo el período.",
  sep = "\n"
)

g_exploratorio <- ggplot(explorar, aes(pct_eeuu, pct_region)) +
  geom_abline(slope = 1, intercept = 0, color = "gray65", linewidth = 0.45) +
  # Relleno: hasta 50% estimado; vacío: más de 50%. No significa ausencia total.
  geom_point(aes(size = peso_pct, color = tipo, shape = dato),
             stroke = 1, alpha = 1) +
  geom_text_repel(aes(label = etiqueta, point.size = peso_pct), size = 3.15,
                  color = "gray15", bg.color = "white", bg.r = 0.12,
                  seed = 2026, na.rm = TRUE, force = 1, show.legend = FALSE,
                  nudge_x = explorar$desplazar_x, nudge_y = explorar$desplazar_y,
                  box.padding = 0.45, point.padding = 0.25,
                  min.segment.length = 0.1, segment.color = "gray55",
                  segment.size = 0.25, max.overlaps = Inf,
                  max.time = Inf, max.iter = 20000) +
  facet_wrap(~ Pais, ncol = 2, axes = "all", axis.labels = "all") +
  scale_x_continuous(labels = label_number(suffix = "%"), breaks = seq(0, 80, 20)) +
  scale_y_continuous(labels = label_number(suffix = "%"), breaks = seq(0, 60, 20)) +
  # Igual longitud física por punto porcentual: la diagonal queda a 45 grados.
  coord_fixed(ratio = 1, xlim = c(0, 80), ylim = c(0, 65),
              expand = FALSE, clip = "off") +
  continuous_scale(aesthetics = c("size", "point.size"), palette = abs_area(11),
                   rescaler = rescale_max, breaks = c(5, 20, 40),
                   labels = label_number(suffix = "%")) +
  scale_color_manual(values = colores_tipo,
                     labels = c("Viajes y transporte", "Conocimiento (4 rubros)", "Otros servicios")) +
  scale_shape_manual(values = c("Hasta 50%" = 16, "Más de 50%" = 1),
                     breaks = c("Hasta 50%", "Más de 50%")) +
  guides(
    color = guide_legend(order = 1, ncol = 1, override.aes = list(size = 3.5, shape = 16)),
    size = guide_legend(order = 2, nrow = 1, override.aes = list(color = "gray50", shape = 16)),
    shape = guide_legend(order = 3, ncol = 1, override.aes = list(size = 3.5, color = "gray25"))
  ) +
  labs(
    title = paste0(
      "¿A quién le vende cada sector? Peso de Estados Unidos y de América del Sur<br>",
      "en las exportaciones de servicios de Argentina, Brasil, Chile y Uruguay"
    ),
    subtitle = subtitulo_exp,
    x = "Parte de lo exportado que compra Estados Unidos (%)",
    y = "Parte de lo exportado que compra el resto de América del Sur (%)",
    color = "Tipo de servicio", size = "Peso del sector", shape = "Valor estimado*",
    caption = pie_exp
  ) +
  tema_tp(base_size = 11.5) +
  theme(
    strip.text = element_text(face = "bold", size = 12.5, hjust = 0,
                              margin = margin(b = 8, t = 4)),
    # Espacio independiente entre paneles, números y nombres de los ejes.
    panel.spacing.x = unit(1.1, "cm"),
    panel.spacing.y = unit(1.2, "cm"),
    panel.grid.major = element_line(color = "gray93", linewidth = 0.3),
    axis.text = element_text(size = 9.5, color = "gray25"),
    axis.text.x = element_text(margin = margin(t = 8)),
    axis.text.y = element_text(margin = margin(r = 8)),
    axis.title = element_text(size = 11, color = "gray20"),
    axis.title.x = element_text(margin = margin(t = 18)),
    axis.title.y = element_text(margin = margin(r = 18)),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9.5),
    legend.box = "horizontal", legend.box.just = "top",
    legend.box.margin = margin(t = 12),
    legend.title.position = "top", legend.spacing.x = unit(0.8, "cm"),
    plot.caption = element_text(size = 9, color = "gray30", hjust = 0,
                               lineheight = 1.15, margin = margin(t = 16))
  )

# Dispositivo explícito: Cairo escribe también los metadatos físicos de 300 dpi.
ggsave("output/graficos/grupo_26_exploratorio.jpg", g_exploratorio,
       device = grDevices::jpeg, type = "cairo", quality = 95,
       width = ancho_cm, height = alto_exploratorio_cm, units = "cm", dpi = resolucion_dpi)


# 5. GRÁFICO COMUNICATIVO --------------------------------------------------------

sectores_comunicar <- c("S", "SD", "SC", sectores_conocimiento)

# Los saltos de línea mejoran la lectura sin cambiar las categorías de la base.
rotulos_comunicativo <- etiquetas_servicios
rotulos_comunicativo["SK"] <- "Personales, culturales<br>y recreativos"
rotulos_comunicativo["SI"] <- "Telecomunicaciones, informática<br>e información"

comunicar <- argentina |>
  filter(medida == "balanceado", Item_code %in% sectores_comunicar) |>
  mutate(grupo = factor(tipo, levels = c("Total", niveles_tipo[1:2]))) |>
  arrange(grupo, desc(peso_pct)) |>
  mutate(
    fila = row_number() * 1.25 + (as.integer(grupo) - 1) * 1.15,
    y = max(fila) - fila + 1,
    rotulo_eje = if_else(
      Item_code == "S", "<b>Total de servicios</b>",
      paste0("<b>", unname(rotulos_comunicativo[Item_code]),
             "</b><br><span style='color:#666666;font-size:8.5pt'>",
             formato_num(peso_pct, 0), "% de las exportaciones totales</span>")
    )
  )

encabezados <- comunicar |>
  filter(grupo != "Total") |>
  group_by(grupo) |>
  summarise(y = max(y) + 1.05, .groups = "drop") |>
  mutate(rotulo_eje = paste0("<span style='color:#555555;font-size:9pt'><b>",
                             c("VIAJES Y TRANSPORTE", "SERVICIOS DEL CONOCIMIENTO"),
                             "</b></span>"))

eje_y <- bind_rows(comunicar |> select(y, rotulo_eje), encabezados |> select(y, rotulo_eje))

puntos <- comunicar |>
  pivot_longer(c(pct_eeuu, pct_region), names_to = "destino", values_to = "pct") |>
  group_by(Item_code) |>
  mutate(
    es_mayor = pct == max(pct),
    empate = abs(diff(pct)) < 2,
    y_punto = if_else(empate, y + if_else(destino == "pct_eeuu", 0.14, -0.14), y)
  ) |>
  ungroup()

total <- comunicar |> filter(Item_code == "S")
viajes <- comunicar |> filter(Item_code == "SD")
peso_mostrado <- sum(comunicar$peso_pct[comunicar$Item_code != "S"])

nota_total <- if (round(total$pct_eeuu) == round(total$pct_region)) {
  paste0("Casi iguales en el total: ", formato_num(total$pct_eeuu, 0),
         "% cada uno.\nEl destino cambia al mirar los sectores.")
} else {
  paste0("En el total: ", formato_num(total$pct_eeuu, 0), "% y ",
         formato_num(total$pct_region, 0), "%.")
}

titulo_com <- paste0(
  "Argentina: ", pintar("Sudamérica", color_region), " pesa más en viajes;<br>",
  pintar("Estados Unidos", color_eeuu), ", en servicios del conocimiento"
)
subtitulo_com <- paste(
  "Comparación entre ambos destinos: porcentaje de las exportaciones de cada sector.",
  "Valor acumulado entre 2015 y 2024; los demás destinos completan el 100%.", sep = "\n"
)
pie_com <- paste(
  "Fuente: OECD-WTO BaTIS (BPM6, dic. 2025). Valor balanceado; USD corrientes; socios identificados (sin ROW).",
  paste0("Sudamérica: los otros once países. Los seis sectores reúnen ", formato_num(peso_mostrado, 0),
         "% de las exportaciones argentinas."),
  "En los seis sectores, el orden entre destinos se mantiene con el valor final; sus porcentajes cambian.",
  "Servicios del conocimiento: aproximación agregada de cuatro rubros, según el CEI.", sep = "\n"
)

g_comunicativo <- ggplot(puntos, aes(pct, y_punto)) +
  geom_line(aes(group = Item_code), color = "gray78", linewidth = 1.3) +
  geom_point(aes(color = destino), size = 4.4) +
  geom_text(data = filter(puntos, !empate),
            aes(label = paste0(formato_num(pct, 0), "%"), color = destino,
                hjust = if_else(es_mayor, -0.45, 1.45)),
            size = 3.8, fontface = "bold") +
  annotate("text", x = viajes$pct_region, y = viajes$y + 0.58, label = "Sudamérica",
           color = color_region, fontface = "bold", size = 3.6) +
  annotate("text", x = viajes$pct_eeuu, y = viajes$y + 0.58, label = "Estados Unidos",
           color = color_eeuu, fontface = "bold", size = 3.6) +
  annotate("text", x = max(total$pct_eeuu, total$pct_region) + 3, y = total$y,
           label = nota_total, hjust = 0, size = 3.5, color = "gray25", lineheight = 1.1) +
  scale_color_manual(values = c(pct_eeuu = color_eeuu, pct_region = color_region)) +
  scale_x_continuous(limits = c(0, 80), breaks = seq(0, 80, 20),
                     labels = label_number(suffix = "%"), expand = c(0, 0)) +
  scale_y_continuous(breaks = eje_y$y, labels = eje_y$rotulo_eje,
                     limits = c(0.35, max(comunicar$y) + 0.7), expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
  labs(title = titulo_com, subtitle = subtitulo_com,
       x = "Participación del destino en las exportaciones del sector (%)",
       y = NULL, caption = pie_com) +
  tema_tp(base_size = 12) +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "gray92", linewidth = 0.3),
    axis.text.y.left = element_markdown(hjust = 0, color = "gray10", size = 10.5,
                                        lineheight = 1.05, margin = margin(r = 12)),
    axis.text.x = element_text(size = 10, margin = margin(t = 8)),
    axis.title.x = element_text(size = 10.5, color = "gray30", margin = margin(t = 18)),
    axis.ticks.y = element_blank(),
    plot.caption = element_text(size = 9, color = "gray30", hjust = 0,
                               lineheight = 1.15, margin = margin(t = 12))
  )

ggsave("output/graficos/grupo_26_comunicativo.jpg", g_comunicativo,
       device = grDevices::jpeg, type = "cairo", quality = 95,
       width = ancho_cm, height = alto_comunicativo_cm, units = "cm", dpi = resolucion_dpi)

cat("\nListo: tabla en output/tablas/ y los dos JPG en output/graficos/.\n")
