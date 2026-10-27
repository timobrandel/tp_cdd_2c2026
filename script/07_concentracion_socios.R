# -----------------------------------------------------------------
# Script      07_concentracion_socios.R
# Objetivo    Medir cuán concentradas en pocos socios están las
#             exportaciones de servicios de Argentina, Brasil, Chile y
#             Uruguay, en el total y por sector (CR1, CR4, HHI), y la
#             diversidad de su canasta de servicios (sectores con ventaja
#             comparativa revelada)
# Entrada     input/batis_bilateral.csv
#             input/batis_mundo_sectores.csv
# Salida      output/tablas/07_concentracion_anual.csv
#             output/tablas/07_comparacion_medidas.csv
#             output/tablas/07_contraste_hipotesis.csv
#             output/tablas/07_concentracion_sectores.csv
#             output/tablas/07_sensibilidad_periodo.csv
#             output/tablas/07_principales_socios.csv
#             output/tablas/07_rca_sectores.csv
#             output/tablas/07_diversidad.csv
#             output/graficos/07_g1_hhi_total.png
#             output/graficos/07_g2_socios_equivalentes_sectores.png
#             output/graficos/07_g3_rca_sectores.png
# -----------------------------------------------------------------
# Requiere haber corrido antes 05_filtrado_bilateral.R.
# Responde las dos primeras partes de la hipótesis (D-024): si Argentina
# concentra sus exportaciones en menos socios que sus vecinos y si esa
# concentración difiere según el sector. Es el método cuantitativo de la
# Instancia 2 (Unidad 3, clase 12), tal como lo propuso la devolución.
#
# Decisiones (ver 06_diagnostico_resumen, D-026 y D-029):
# - Medida principal: Balanced_value (D-023). Combina lo que declara el
#   exportador con lo que declara el importador, así que mide a los cuatro
#   países de la misma manera. No es "dato informado" (metodología, 5.1).
# - Sensibilidad: Final_value, lo que declara cada país a cada socio o, si
#   no lo declara, lo que estima OCDE-OMC. Es
#   dato propio en Argentina desde 2015, en parte en Brasil, y estimación de
#   OCDE-OMC (modelo de gravedad) en Chile y Uruguay (D-029).
# - Período principal: 2015-2024, los años en que Argentina declara por socio.
# - ROW (resto del mundo) se excluye: es un residuo de socios no
#   identificados, no un comprador.
# - Los índices se calculan año por año y después se promedian: así un año
#   raro no domina el resultado.
# - Valores en millones de USD corrientes (sin deflactar).

library(tidyverse)
library(scales)

source("utils/guardar_tabla.R")
source("utils/calcular_cr.R")
source("utils/calcular_hhi.R")
source("utils/n_equivalente.R")
source("utils/calcular_rca.R")
source("utils/promediar_indices.R")
source("utils/escalar_indices.R")
source("utils/formato_num.R")

dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)
dir.create("output/graficos", recursive = TRUE, showWarnings = FALSE)

# na = "": el código de Namibia es "NA" (ver el 05)
bilateral <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mundo     <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)

etiquetas_paises <- c(AR = "Argentina", BR = "Brasil", CL = "Chile", UY = "Uruguay")

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
  SI = "Telecom., informática e información",
  SJ = "Otros servicios empresariales",
  SK = "Personales, culturales y recreativos",
  SL = "Bienes y servicios del gobierno"
)
sectores <- setdiff(names(etiquetas_servicios), "S")

etiquetas_medidas <- c(
  balanceado = "Balanceado (exportador + importador)",
  final      = "Final (declarado por el país o estimado por OCDE-OMC)"
)

periodo_analisis <- 2015:2024

fuente <- paste0("Fuente: elaboración propia con datos de OECD-WTO BaTIS ",
                 "(BPM6, versión dic. 2025).")
tema_tp <- theme_minimal() +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.caption          = element_text(hjust = 0, size = 8, color = "grey30"),
    legend.position       = "bottom"
  )


# 1. PARTICIPACIÓN DE CADA SOCIO, CON LAS DOS MEDIDAS --------------------------

# Participación = lo que se le vende a ese socio / lo que se le vende a todos,
# dentro de cada medida, país, sector y año. Las dos medidas se apilan en una
# columna `valor` para calcular todo una sola vez.
participaciones <- bilateral |>
  filter(Partner != "ROW") |>
  pivot_longer(c(Balanced_value, Final_value), names_to = "medida", values_to = "valor") |>
  mutate(medida = if_else(medida == "Balanced_value", "balanceado", "final")) |>
  group_by(medida, Reporter, Item_code, Year) |>
  mutate(total = sum(valor)) |>
  ungroup() |>
  # Un país-sector-año sin exportaciones no tiene participaciones (0 / 0).
  filter(total > 0) |>
  mutate(participacion = valor / total)

# Control: las participaciones de cada grupo suman 1.
control_participaciones <- participaciones |>
  group_by(medida, Reporter, Item_code, Year) |>
  summarise(suma = sum(participacion), .groups = "drop")
stopifnot(all(abs(control_participaciones$suma - 1) < 1e-9))


# 2. ÍNDICES DE CONCENTRACIÓN, AÑO POR AÑO -------------------------------------

# CR1: cuánto se lleva el socio principal. CR4: los cuatro principales.
# HHI: suma de participaciones al cuadrado (de 0 a 1; x 10.000 en la escala
# de defensa de la competencia). Socios equivalentes: 1 / HHI, la cantidad
# de socios de igual tamaño que darían la misma concentración.
# CR4 y HHI pueden ordenar distinto a los países: el CR4 solo mira a los
# cuatro primeros; el HHI, a toda la distribución, y pesa mucho al primero.
concentracion_anual <- participaciones |>
  group_by(medida, Reporter, Item_code, Year) |>
  summarise(
    valor_total       = first(total),
    socios_con_ventas = sum(valor > 0),
    socio_principal   = Partner[which.max(participacion)],
    cr1               = calcular_cr(participacion, k = 1),
    cr4               = calcular_cr(participacion, k = 4),
    hhi               = calcular_hhi(participacion),
    # Parte del valor cuya venta a cada socio NO declara el exportador (la
    # estimó OCDE-OMC; código del valor final, D-025). En el balanceado, esa
    # parte se combina con lo que declara el importador.
    pct_estimado      = 100 * sum(participacion[origen == "Estimado por OCDE-OMC"]),
    .groups = "drop"
  ) |>
  mutate(socios_equivalentes = n_equivalente(hhi))


# 3. TOTAL DE SERVICIOS: COMPARACIÓN DE LOS CUATRO PAÍSES ----------------------

# Promedio 2015-2024 de los índices anuales, con las dos medidas, y el
# puesto de cada país (1 = el más concentrado).
comparacion_medidas <- concentracion_anual |>
  filter(Item_code == "S", Year %in% periodo_analisis) |>
  group_by(medida, Reporter) |>
  promediar_indices() |>
  group_by(medida) |>
  mutate(puesto_hhi = min_rank(desc(hhi)),
         puesto_cr4 = min_rank(desc(cr4))) |>
  ungroup() |>
  mutate(Pais = unname(etiquetas_paises[Reporter]), .after = Reporter) |>
  arrange(medida, puesto_hhi)

print(comparacion_medidas |>
        select(medida, Pais, hhi, cr1, cr4, socios_equivalentes, puesto_hhi,
               puesto_cr4, pct_estimado))

# Contraste directo de la hipótesis: Argentina contra cada vecino, con cada
# medida y cada índice. Además del promedio, cuántos de los diez años
# Argentina estuvo más concentrada que ese país.
anual_largo <- concentracion_anual |>
  filter(Item_code == "S", Year %in% periodo_analisis) |>
  select(medida, Reporter, Year, hhi, cr4) |>
  pivot_longer(c(hhi, cr4), names_to = "indice", values_to = "valor")

contraste_hipotesis <- anual_largo |>
  filter(Reporter != "AR") |>
  rename(vecino = Reporter, valor_vecino = valor) |>
  inner_join(anual_largo |>
               filter(Reporter == "AR") |>
               select(medida, Year, indice, valor_argentina = valor),
             by = c("medida", "Year", "indice")) |>
  group_by(medida, indice, vecino) |>
  summarise(
    argentina         = mean(valor_argentina),
    vecino_promedio   = mean(valor_vecino),
    anios_ar_mayor    = sum(valor_argentina > valor_vecino),
    anios             = n(),
    .groups = "drop"
  ) |>
  mutate(
    ar_mas_concentrada = argentina > vecino_promedio,
    # en la escala de las tablas: HHI x 10.000, CR4 en %
    across(c(argentina, vecino_promedio), ~ if_else(indice == "hhi", 10000 * .x, 100 * .x)),
    Vecino = unname(etiquetas_paises[vecino]),
    .after = vecino
  ) |>
  arrange(vecino, medida, indice)

print(contraste_hipotesis, width = Inf)

# Sensibilidad al período, en tres tramos. La única comparación válida es la
# de Brasil entre 2010-2014 y 2015-2024: declara su total por socio desde
# 2010. Antes de cada fecha de inicio, OCDE-OMC retroproyecta hacia atrás la
# estructura que el país declara después (código E8.2, D-025): son los
# años 2005-2009 de Brasil y 2005-2014 de Argentina, sin información propia
# sobre sus socios (QA-004, M4; QA-004b, m4). Chile y Uruguay son modelo en
# todos los tramos.
sensibilidad <- concentracion_anual |>
  filter(Item_code == "S") |>
  mutate(periodo = case_when(Year >= 2015 ~ "2015-2024",
                             Year >= 2010 ~ "2010-2014",
                             TRUE         ~ "2005-2009")) |>
  group_by(medida, Reporter, periodo) |>
  promediar_indices() |>
  mutate(Pais = unname(etiquetas_paises[Reporter]), .after = Reporter)

# Principales socios de cada país en 2015-2024 (sobre el valor acumulado).
principales_socios <- participaciones |>
  filter(Item_code == "S", Year %in% periodo_analisis) |>
  group_by(medida, Reporter, Partner, nombre_socio) |>
  summarise(valor = sum(valor), .groups = "drop") |>
  group_by(medida, Reporter) |>
  mutate(participacion_pct = 100 * valor / sum(valor)) |>
  slice_max(participacion_pct, n = 5) |>
  mutate(puesto = row_number()) |>
  ungroup() |>
  mutate(Pais = unname(etiquetas_paises[Reporter]), .after = Reporter) |>
  rename(valor_musd_corrientes = valor)

print(principales_socios |>
        filter(medida == "balanceado") |>
        select(Pais, puesto, nombre_socio, participacion_pct), n = 20)

# Gráfico: HHI del total de servicios, año por año, con las dos medidas. Los
# puntos huecos marcan los años en que el exportador no declara a quién le
# vende más de la mitad del valor (lo estima OCDE-OMC).
datos_g1 <- concentracion_anual |>
  filter(Item_code == "S") |>
  mutate(Pais = factor(unname(etiquetas_paises[Reporter]),
                       levels = unname(etiquetas_paises)),
         Medida = factor(unname(etiquetas_medidas[medida]),
                         levels = unname(etiquetas_medidas)),
         dato = if_else(pct_estimado > 50,
                        "El país no declara sus socios (estima OCDE-OMC)",
                        "El país declara sus socios"))

# Cifras del título, calculadas: en cuántos de los 10 años Argentina supera
# a Chile con cada medida.
anios_ar_cl <- contraste_hipotesis |>
  filter(vecino == "CL", indice == "hhi") |>
  select(medida, anios_ar_mayor) |>
  deframe()

# Frase sobre Brasil, calculada y acotada a 2015-2024 (en 2005-2014 Brasil
# llegó a estar arriba de Argentina).
br_debajo <- contraste_hipotesis |>
  filter(vecino == "BR", indice == "hhi") |>
  pull(anios_ar_mayor)
frase_brasil <- if (all(br_debajo == length(periodo_analisis))) {
  "En 2015-2024, Brasil queda debajo de Argentina todos los años, con las dos medidas."
} else {
  paste0("En 2015-2024, Argentina supera a Brasil en ", min(br_debajo), " a ",
         max(br_debajo), " de 10 años, según la medida.")
}

g_hhi <- ggplot(datos_g1, aes(Year, hhi * 10000, color = Pais)) +
  annotate("rect", xmin = 2014.5, xmax = 2024.5, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.5) +
  geom_line(linewidth = 0.9) +
  geom_point(aes(shape = dato), size = 2, fill = "white", stroke = 1) +
  facet_wrap(~ Medida) +
  scale_shape_manual(values = c("El país no declara sus socios (estima OCDE-OMC)" = 21,
                                "El país declara sus socios" = 16)) +
  scale_x_continuous(breaks = seq(2005, 2024, 5)) +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  # El título encabeza con la medida principal (D-029); la sensibilidad va
  # después y aclara que en el final Chile es un modelo.
  labs(title = paste0("Con el balanceado, Argentina supera a Chile en concentración por ",
                      "socio en ", anios_ar_cl[["balanceado"]], " de 10 años; con el ",
                      "valor final,\nen ", anios_ar_cl[["final"]], " de 10, pero ahí ",
                      "los socios de Chile salen de un modelo de OCDE-OMC"),
       subtitle = paste0("Índice de Herfindahl-Hirschman (HHI) de los socios, total de ",
                         "servicios: de 0 (muy repartido) a 10.000 (un solo comprador).\n",
                         frase_brasil, " Sombreado: período del análisis."),
       x = NULL, y = "HHI (0 a 10.000)", color = NULL, shape = NULL,
       caption = paste0(fuente, " Sin ROW.\nEn el valor final, los socios de Chile y ",
                        "Uruguay salen de un modelo de gravedad de OCDE-OMC. Los años ",
                        "2023-2024 de Chile son estimados.")) +
  tema_tp +
  theme(plot.title = element_text(size = 11)) +
  guides(color = guide_legend(order = 1), shape = guide_legend(order = 2, nrow = 2))


# 4. CONCENTRACIÓN POR SECTOR (2015-2024) ---------------------------------------

concentracion_sectores <- concentracion_anual |>
  filter(Year %in% periodo_analisis) |>
  group_by(medida, Reporter, Item_code) |>
  promediar_indices() |>
  left_join(
    # socio principal más frecuente del período
    concentracion_anual |>
      filter(Year %in% periodo_analisis) |>
      count(medida, Reporter, Item_code, socio_principal, sort = TRUE) |>
      distinct(medida, Reporter, Item_code, .keep_all = TRUE) |>
      select(medida, Reporter, Item_code, socio_principal),
    by = c("medida", "Reporter", "Item_code")
  ) |>
  mutate(Pais = unname(etiquetas_paises[Reporter]),
         Servicio = unname(etiquetas_servicios[Item_code]),
         dato_propio = pct_estimado <= 50,
         .after = Item_code)

# ¿Cuánto varía la concentración entre sectores dentro de cada país?
# Rango y coeficiente de variación del HHI de los 12 sectores.
variacion_sectores <- concentracion_sectores |>
  filter(Item_code %in% sectores) |>
  group_by(medida, Reporter) |>
  summarise(socios_eq_min = min(socios_equivalentes),
            socios_eq_max = max(socios_equivalentes),
            sector_mas_concentrado = Item_code[which.max(hhi)],
            sector_menos_concentrado = Item_code[which.min(hhi)],
            cv_hhi = sd(hhi) / mean(hhi),
            .groups = "drop")
print(variacion_sectores)

# Cifras del gráfico, calculadas (medida principal).
var_ar <- variacion_sectores |> filter(medida == "balanceado", Reporter == "AR")
cv_mayor <- variacion_sectores |>
  filter(medida == "balanceado") |>
  slice_max(cv_hhi, n = 1)

# Gráfico: socios equivalentes por país y sector, con la medida principal.
# Se usa 1 / HHI y no el HHI porque "vende como si tuviera 5 socios iguales"
# se entiende sin fórmulas.
datos_g2 <- concentracion_sectores |>
  filter(medida == "balanceado") |>
  mutate(Pais = factor(Pais, levels = unname(etiquetas_paises)),
         Servicio = factor(Servicio, levels = rev(unname(etiquetas_servicios))),
         # asterisco: más de la mitad del valor con socios estimados
         etiqueta = paste0(formato_num(socios_equivalentes, 1),
                           if_else(dato_propio, "", "*")))

g_sectores <- ggplot(datos_g2, aes(Pais, Servicio, fill = socios_equivalentes)) +
  geom_tile(color = "white") +
  geom_text(aes(label = etiqueta), size = 3.2) +
  scale_fill_distiller(palette = "YlOrRd", direction = -1, trans = "log10",
                       labels = label_number(decimal.mark = ",", accuracy = 1)) +
  scale_x_discrete(position = "top") +
  # str_wrap corta el título en renglones de hasta 75 caracteres
  labs(title = str_wrap(paste0("En Argentina, la concentración por socio va de ",
                      formato_num(var_ar$socios_eq_min, 1), " socios equivalentes en ",
                      tolower(etiquetas_servicios[[var_ar$sector_mas_concentrado]]),
                      " a ", formato_num(var_ar$socios_eq_max, 1), " en ",
                      tolower(etiquetas_servicios[[var_ar$sector_menos_concentrado]])), 75),
       subtitle = paste0("Socios equivalentes (1 / HHI medio 2015-2024). Más rojo = más ",
                         "concentrado.\n", unname(etiquetas_paises[cv_mayor$Reporter]),
                         " es el país donde más varía entre sectores. ",
                         "* Más de la mitad del valor con socios\nque no declara el ",
                         "exportador (los estima OCDE-OMC)."),
       x = NULL, y = NULL, fill = "Socios equivalentes",
       caption = paste(fuente, "Medida: valor balanceado. Sin ROW.")) +
  tema_tp +
  theme(panel.grid = element_blank(),
        plot.title = element_text(size = 11),
        legend.key.width = unit(1.5, "cm"))


# 5. DIVERSIDAD: SECTORES CON VENTAJA COMPARATIVA REVELADA ----------------------

# Igual que en la clase 12, la diversidad es la cantidad de rubros en los
# que un país tiene ventaja comparativa revelada (RCA de Balassa > 1). Acá
# los rubros son los 12 sectores de servicios y el "mundo" son las
# economías presentes los diez años (199: Corea del Norte informa cero en
# todo), con el valor final (D-015) promediado en 2015-2024.
# Es diversidad de SECTORES, no de socios: responde el pedido del docente
# ("pueden ver el índice de diversidad también"), no la parte de la
# hipótesis sobre socios.
base_rca <- mundo |>
  filter(Item_code %in% sectores, Year %in% periodo_analisis) |>
  group_by(Reporter, nombre_pais, Item_code) |>
  summarise(anios = n(), valor = mean(Final_value), .groups = "drop") |>
  filter(anios == length(periodo_analisis)) |>
  rename(pais = Reporter, sector = Item_code) |>
  # una economía sin exportaciones de servicios no tiene canasta
  group_by(pais) |>
  filter(sum(valor) > 0) |>
  ungroup()

rca <- calcular_rca(base_rca)

diversidad_mundo <- rca |>
  group_by(pais, nombre_pais) |>
  summarise(sectores_con_ventaja = sum(rca > 1), .groups = "drop") |>
  # percent_rank: qué parte de las economías tiene ESTRICTAMENTE menos
  # sectores con ventaja (los empates no cuentan)
  mutate(pct_economias_con_menos = 100 * percent_rank(sectores_con_ventaja))

diversidad <- diversidad_mundo |>
  filter(pais %in% names(etiquetas_paises)) |>
  left_join(rca |>
              filter(rca > 1) |>
              group_by(pais) |>
              summarise(sectores = paste(sector, collapse = ", ")),
            by = "pais") |>
  mutate(Pais = unname(etiquetas_paises[pais]), .after = pais)

cat("Economías en la base de RCA:", n_distinct(rca$pais), "\n")
cat("Mediana mundial de sectores con ventaja:",
    median(diversidad_mundo$sectores_con_ventaja), "\n")
print(diversidad)

rca_sectores <- rca |>
  filter(pais %in% names(etiquetas_paises)) |>
  mutate(Pais = unname(etiquetas_paises[pais]),
         Servicio = unname(etiquetas_servicios[sector])) |>
  select(pais, Pais, sector, Servicio, valor_medio_musd_corrientes = valor, rca)

div_ar <- diversidad |> filter(pais == "AR")

g_rca <- rca_sectores |>
  mutate(Pais = factor(Pais, levels = unname(etiquetas_paises)),
         Servicio = factor(Servicio, levels = rev(unname(etiquetas_servicios[sectores]))),
         ventaja = if_else(rca > 1, "Con ventaja (RCA > 1)", "Sin ventaja")) |>
  ggplot(aes(Pais, Servicio, fill = ventaja)) +
  geom_tile(color = "white") +
  geom_text(aes(label = formato_num(rca, 2)), size = 3.2) +
  scale_fill_manual(values = c("Con ventaja (RCA > 1)" = "#7FB77E",
                               "Sin ventaja" = "grey92")) +
  scale_x_discrete(position = "top") +
  labs(title = paste0("Argentina tiene ventaja comparativa en ",
                      div_ar$sectores_con_ventaja, " de 12 sectores, más que sus vecinos"),
       subtitle = paste0("Ventaja comparativa revelada de Balassa, promedio 2015-2024, ",
                         "contra ", n_distinct(rca$pais), " economías.\nDiversidad = cantidad de ",
                         "sectores con RCA > 1 (mediana mundial: ",
                         median(diversidad_mundo$sectores_con_ventaja), ")."),
       x = NULL, y = NULL, fill = NULL,
       caption = paste0(fuente, "\nMedida: valor final (informado por el país o estimado ",
                        "por OCDE-OMC), USD corrientes.\nChile nunca informa manufactura, ",
                        "mantenimiento, construcción ni gobierno: OCDE-OMC los completa con ",
                        "cero (RCA = 0, no interpretable).\nSus años 2023-2024 son estimados.")) +
  tema_tp +
  theme(panel.grid = element_blank())


# 6. GUARDAR --------------------------------------------------------------------

# En las tablas, el HHI va en la escala 0-10.000 y los CR en % (ver
# utils/escalar_indices.R).
guardar_tabla(escalar_indices(concentracion_anual),    "output/tablas/07_concentracion_anual.csv")
guardar_tabla(escalar_indices(comparacion_medidas),    "output/tablas/07_comparacion_medidas.csv")
guardar_tabla(contraste_hipotesis,                     "output/tablas/07_contraste_hipotesis.csv")
guardar_tabla(escalar_indices(concentracion_sectores), "output/tablas/07_concentracion_sectores.csv")
guardar_tabla(escalar_indices(sensibilidad),           "output/tablas/07_sensibilidad_periodo.csv")
guardar_tabla(principales_socios,     "output/tablas/07_principales_socios.csv")
guardar_tabla(rca_sectores,           "output/tablas/07_rca_sectores.csv")
guardar_tabla(diversidad,             "output/tablas/07_diversidad.csv")

ggsave("output/graficos/07_g1_hhi_total.png", g_hhi,
       width = 10, height = 5.8, dpi = 200, bg = "white")
ggsave("output/graficos/07_g2_socios_equivalentes_sectores.png", g_sectores,
       width = 8.5, height = 7, dpi = 200, bg = "white")
ggsave("output/graficos/07_g3_rca_sectores.png", g_rca,
       width = 8.5, height = 7, dpi = 200, bg = "white")
