# -----------------------------------------------------------------
# Script      06_faltantes_atipicos.R
# Objetivo    Diagnosticar faltantes, ceros, datos estimados y valores
#             atípicos de las dos bases de la Instancia 2, y dejar
#             justificada la decisión que se toma con cada caso
# Entrada     input/batis_bilateral.csv
#             input/batis_mundo_sectores.csv
# Salida      output/tablas/06_origen_por_sector.csv
#             output/tablas/06_ceros_mundo_sectores.csv
#             output/tablas/06_faltantes_valor_final.csv
#             output/tablas/06_atipicos_mundo_sectores.csv
#             output/tablas/06_atipicos_mundo_detalle.csv
#             output/tablas/06_atipicos_bilateral.csv
#             output/tablas/06_diagnostico_resumen.csv
#             output/graficos/06_g1_origen_bilateral.png
#             output/graficos/06_g2_boxplot_sectores.png
# -----------------------------------------------------------------
# Requiere haber corrido antes 05_filtrado_bilateral.R.
#
# Las dos bases miden cosas distintas y por eso usan medidas distintas:
# - bilateral (país x socio): Balanced_value (D-023), es la que se usa para
#   la concentración por socio (script 07);
# - al mundo (país x sector, todos los países): Final_value (D-015), es la
#   que se usa para el ANOVA entre sectores (3.4). El balanceado sirve para
#   los pares de países, pero en los totales de economías chicas se aparta
#   mucho del valor final (Gabón 2024: 38 millones de valor final, que
#   estima OCDE-OMC porque Gabón no informa, contra 2.497 balanceados).
#
# El período del análisis es 2015-2024 (hipótesis, D-024): son los años en
# que Argentina informa su comercio por socio.
# Todos los valores están en millones de USD corrientes (sin deflactar).

library(tidyverse)
library(scales)

source("utils/guardar_tabla.R")
source("utils/formato_num.R")
source("utils/texto_origen_sectores.R")

dir.create("output/tablas", recursive = TRUE, showWarnings = FALSE)
dir.create("output/graficos", recursive = TRUE, showWarnings = FALSE)

# na = "": el código de Namibia es "NA" (ver el 05)
bilateral <- read_csv("input/batis_bilateral.csv", na = "", show_col_types = FALSE)
mundo     <- read_csv("input/batis_mundo_sectores.csv", na = "", show_col_types = FALSE)

etiquetas_paises <- c(AR = "Argentina", BR = "Brasil", CL = "Chile", UY = "Uruguay")

etiquetas_servicios <- c(
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
sectores <- names(etiquetas_servicios)

periodo_analisis <- 2015:2024

formato_ar <- label_number(big.mark = ".", decimal.mark = ",")
fuente <- paste0("Fuente: elaboración propia con datos de OECD-WTO BaTIS ",
                 "(BPM6, versión dic. 2025).")
tema_tp <- theme_minimal() +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.caption          = element_text(hjust = 0, size = 8, color = "grey30"),
    legend.position       = "bottom"
  )


# 1. ORIGEN DEL DATO BILATERAL, POR SECTOR ------------------------------------

# El 05 midió el origen para el total de servicios. Acá se abre por sector:
# que Argentina informe por socio desde 2015 en el total no garantiza que lo
# haga en cada sector.
# Se excluye ROW (resto del mundo): no es un socio identificado (ver 4).
origen_por_sector <- bilateral |>
  filter(Item_code %in% sectores, Partner != "ROW") |>
  mutate(periodo = if_else(Year < 2015, "2005-2014", "2015-2024")) |>
  group_by(Reporter, Item_code, periodo) |>
  summarise(
    valor_total        = sum(Balanced_value),
    pct_valor_estimado = 100 * sum(Balanced_value[origen == "Estimado por OCDE-OMC"]) /
                         sum(Balanced_value),
    .groups = "drop"
  ) |>
  mutate(Pais = unname(etiquetas_paises[Reporter]),
         Servicio = unname(etiquetas_servicios[Item_code]))

print(origen_por_sector |>
        filter(periodo == "2015-2024") |>
        select(Reporter, Item_code, pct_valor_estimado) |>
        pivot_wider(names_from = Reporter, values_from = pct_valor_estimado))

# Gráfico: qué parte del valor exportado (total de servicios) tiene la
# distribución por socio estimada, por país y año.
origen_anual <- bilateral |>
  filter(Item_code == "S", Partner != "ROW") |>
  group_by(Reporter, Year) |>
  summarise(pct_estimado = 100 * sum(Balanced_value[origen == "Estimado por OCDE-OMC"]) /
                           sum(Balanced_value),
            .groups = "drop") |>
  mutate(Pais = factor(unname(etiquetas_paises[Reporter]),
                       levels = unname(etiquetas_paises)))

g_origen <- ggplot(origen_anual, aes(Year, pct_estimado, color = Pais)) +
  annotate("rect", xmin = 2014.5, xmax = 2024.5, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.5) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  # expand_limits y no limits: con limits = c(0, 100), los años con 100%
  # que por redondeo dan 100,0000001 quedarían afuera del gráfico.
  scale_y_continuous(labels = label_percent(scale = 1)) +
  expand_limits(y = c(0, 100)) +
  scale_x_continuous(breaks = seq(2005, 2024, 3)) +
  labs(title = "Solo Argentina y Brasil declaran a quién le venden sus servicios",
       subtitle = paste0("Parte del valor exportado (total de servicios) cuya distribución ",
                         "por socio no declara el país y estima OCDE-OMC.\nChile y Uruguay: ",
                         "100% todos los años (líneas superpuestas). Sombreado: período del análisis."),
       x = NULL, y = "% del valor exportado", color = NULL,
       caption = paste0(fuente, "\nOrigen: código del valor final (lo que declara el ",
                        "exportador), ponderado con el valor balanceado. Sin ROW.")) +
  tema_tp


# 2. FALTANTES Y CEROS EN LA BASE AL MUNDO (para el ANOVA y el RCA) -----------

# El valor final no tiene nulos, pero eso no quiere decir que todo esté
# informado: cuando el país no informa (Reported_value vacío), OCDE-OMC
# completa el valor final con una estimación (E2, E3, E5...) o con cero
# (E0, "despreciable"). Esos son los faltantes reales de esta base.
faltantes_final <- mundo |>
  filter(Item_code %in% sectores) |>
  mutate(periodo = if_else(Year %in% periodo_analisis, "2015-2024", "2005-2014")) |>
  group_by(periodo, Item_code) |>
  summarise(
    filas                 = n(),
    sin_valor_informado   = sum(is.na(Reported_value)),
    pct_sin_informar      = 100 * mean(is.na(Reported_value)),
    completados_con_cero  = sum(is.na(Reported_value) & Final_value == 0),
    .groups = "drop"
  ) |>
  mutate(Servicio = unname(etiquetas_servicios[Item_code]), .after = Item_code)

cat("Filas sin valor informado en la base al mundo (12 sectores, 2005-2024):",
    sum(faltantes_final$sin_valor_informado), "de", sum(faltantes_final$filas), "\n")

# Unidad del ANOVA: país x sector, con el promedio anual 2015-2024. Así cada
# país aparece una vez por sector (no diez veces, una por año).
# Se toman solo las economías presentes los diez años.
base_anova <- mundo |>
  filter(Item_code %in% sectores, Year %in% periodo_analisis) |>
  group_by(Reporter, nombre_pais, Item_code) |>
  summarise(
    anios           = n(),
    valor_medio     = mean(Final_value),
    pct_estimado    = 100 * mean(origen == "Estimado por OCDE-OMC"),
    anios_informados = sum(!is.na(Reported_value)),
    anios_en_cero   = sum(Final_value == 0),
    algun_e0        = any(Final_value_methodology == "E0"),
    .groups = "drop"
  ) |>
  filter(anios == length(periodo_analisis)) |>
  # Una celda con promedio cero tiene los diez años en cero. Según quién
  # puso ese cero, significa cosas distintas:
  mutate(tipo_cero = case_when(
    valor_medio > 0                            ~ NA_character_,
    anios_informados == length(periodo_analisis) ~ "Cero informado los 10 años",
    anios_informados > 0                       ~ "Mixto: algunos años informados",
    algun_e0                                   ~ "Nunca informado: OCDE-OMC lo estima despreciable (E0)",
    TRUE                                       ~ "Nunca informado: OCDE-OMC lo completa con cero"
  ))

# Solo el primer tipo es un "no exportó" declarado por el país. Los dos
# últimos son, en la práctica, faltantes completados con cero (el caso de
# Chile en manufactura, mantenimiento, construcción y gobierno). Igual que
# los demás ceros, quedan fuera del ANOVA sobre log(valor), porque log(0) no
# existe. Pero entran en el Kruskal-Wallis con ceros, en el RCA y en los
# percentiles del 08 como "no exportó": eso se aclara en cada resultado.
ceros_mundo <- base_anova |>
  group_by(Item_code) |>
  summarise(
    paises            = n(),
    paises_con_cero   = sum(valor_medio == 0),
    pct_ceros         = 100 * mean(valor_medio == 0),
    cero_informado    = sum(tipo_cero %in% "Cero informado los 10 años"),
    cero_mixto        = sum(tipo_cero %in% "Mixto: algunos años informados"),
    cero_e0           = sum(tipo_cero %in% "Nunca informado: OCDE-OMC lo estima despreciable (E0)"),
    cero_completado   = sum(tipo_cero %in% "Nunca informado: OCDE-OMC lo completa con cero"),
    pct_celdas_estimadas = mean(pct_estimado),
    .groups = "drop"
  ) |>
  mutate(Servicio = unname(etiquetas_servicios[Item_code]), .after = Item_code)

print(ceros_mundo)
print(count(base_anova, tipo_cero))


# 3. ATÍPICOS EN LA BASE AL MUNDO ---------------------------------------------

# Criterio de 1,5 veces el rango intercuartílico (RIC), sobre el logaritmo
# del valor y dentro de cada sector. El logaritmo hace falta porque los
# valores van de menos de un millón a cientos de miles de millones: sin él,
# casi cualquier país grande sería atípico.
positivos <- base_anova |>
  filter(valor_medio > 0) |>
  mutate(log_valor = log(valor_medio))

limites <- positivos |>
  group_by(Item_code) |>
  summarise(
    q1  = quantile(log_valor, 0.25),
    q3  = quantile(log_valor, 0.75),
    .groups = "drop"
  ) |>
  mutate(ric = q3 - q1,
         limite_inferior = q1 - 1.5 * ric,
         limite_superior = q3 + 1.5 * ric)

positivos <- positivos |>
  left_join(limites, by = "Item_code") |>
  mutate(tipo_atipico = case_when(
    log_valor < limite_inferior ~ "bajo",
    log_valor > limite_superior ~ "alto",
    TRUE                        ~ NA_character_
  ))

atipicos_mundo <- positivos |>
  group_by(Item_code) |>
  summarise(
    paises_con_valor = n(),
    atipicos_bajos   = sum(tipo_atipico == "bajo", na.rm = TRUE),
    atipicos_altos   = sum(tipo_atipico == "alto", na.rm = TRUE),
    .groups = "drop"
  ) |>
  left_join(limites |>
              transmute(Item_code,
                        # Los límites vuelven a dólares con exp() y se
                        # expresan en MILES de USD: en millones, los
                        # inferiores quedarían en "0,00" al redondear a 2
                        # decimales y se leerían como "exporta cero".
                        limite_inferior_miles_usd_corrientes = 1000 * exp(limite_inferior),
                        limite_superior_miles_usd_corrientes = 1000 * exp(limite_superior)),
            by = "Item_code") |>
  mutate(Servicio = unname(etiquetas_servicios[Item_code]), .after = Item_code)

print(atipicos_mundo)

atipicos_mundo_detalle <- positivos |>
  filter(!is.na(tipo_atipico)) |>
  transmute(Item_code,
            Servicio = unname(etiquetas_servicios[Item_code]),
            Reporter, nombre_pais, tipo_atipico,
            # en miles de USD, por el mismo motivo que los límites
            valor_medio_miles_usd_corrientes = 1000 * valor_medio, pct_estimado,
            # un promedio bajo puede venir de varios años en cero (serie
            # intermitente), no de una economía chica
            anios_en_cero, anios_informados) |>
  arrange(Item_code, tipo_atipico, desc(valor_medio_miles_usd_corrientes))

print(atipicos_mundo_detalle |> count(tipo_atipico))

# Gráfico: distribución del log del valor por sector, con los cuatro países
# del TP marcados.
orden_sectores <- positivos |>
  group_by(Item_code) |>
  summarise(mediana = median(log_valor)) |>
  arrange(mediana) |>
  pull(Item_code)

datos_box <- positivos |>
  mutate(Servicio = factor(unname(etiquetas_servicios[Item_code]),
                           levels = unname(etiquetas_servicios[orden_sectores])))

g_box <- ggplot(datos_box, aes(x = valor_medio, y = Servicio)) +
  geom_boxplot(outlier.color = "grey40", outlier.size = 0.8, fill = "grey95") +
  geom_point(data = filter(datos_box, Reporter %in% names(etiquetas_paises)) |>
               mutate(Pais = factor(unname(etiquetas_paises[Reporter]),
                                    levels = unname(etiquetas_paises))),
             aes(color = Pais), size = 2.2) +
  # Cortes en potencias de 100 y etiquetas con decimales para los valores
  # menores a 1 (si no, 0,01 se mostraría como 0).
  scale_x_log10(breaks = 10^seq(-2, 6, 2),
                labels = label_number(big.mark = ".", decimal.mark = ",",
                                      drop0trailing = TRUE)) +
  labs(title = "Los sectores difieren en cuánto exporta el país típico",
       subtitle = paste0("Exportación media anual 2015-2024 por país, en millones ",
                         "de USD corrientes (escala logarítmica).\nCada caja resume ",
                         "hasta 200 economías."),
       x = "Millones de USD corrientes (escala log.)", y = NULL, color = NULL,
       caption = paste0(fuente, " Medida: valor final (informado por el país ",
                        "o estimado por OCDE-OMC).\n",
                       "Sin los países que exportan cero en el sector. ",
                       "Puntos grises: atípicos con 1,5 RIC sobre el log.")) +
  tema_tp


# 4. ATÍPICOS EN LA BASE BILATERAL --------------------------------------------

# Mismo criterio, aplicado a los flujos hacia cada socio de 2024, dentro de
# cada país y sector. Acá un atípico alto es un socio que compra mucho más
# que el resto: es justamente lo que mide la concentración, así que no se
# corrige. La tabla muestra qué parte del valor se llevan esos socios.
flujos_2024 <- bilateral |>
  filter(Year == 2024, Item_code %in% sectores, Partner != "ROW",
         Balanced_value > 0) |>
  mutate(log_valor = log(Balanced_value)) |>
  group_by(Reporter, Item_code) |>
  mutate(
    ric = IQR(log_valor),
    tipo_atipico = case_when(
      log_valor < quantile(log_valor, 0.25) - 1.5 * ric ~ "bajo",
      log_valor > quantile(log_valor, 0.75) + 1.5 * ric ~ "alto",
      TRUE                                              ~ NA_character_
    )
  ) |>
  ungroup()

atipicos_bilateral <- flujos_2024 |>
  group_by(Reporter, Item_code) |>
  summarise(
    socios_con_valor   = n(),
    atipicos_altos     = sum(tipo_atipico == "alto", na.rm = TRUE),
    atipicos_bajos     = sum(tipo_atipico == "bajo", na.rm = TRUE),
    pct_valor_atipicos_altos = 100 * sum(Balanced_value[tipo_atipico %in% "alto"]) /
                               sum(Balanced_value),
    socios_atipicos_altos = paste(Partner[tipo_atipico %in% "alto"], collapse = ", "),
    .groups = "drop"
  ) |>
  mutate(Pais = unname(etiquetas_paises[Reporter]),
         Servicio = unname(etiquetas_servicios[Item_code]), .after = Item_code)

print(atipicos_bilateral |>
        select(Reporter, Item_code, socios_con_valor, atipicos_altos,
               pct_valor_atipicos_altos), n = 48)


# 5. RESUMEN DEL DIAGNÓSTICO Y DECISIONES --------------------------------------

# Las magnitudes se calculan acá para que la tabla no quede desactualizada si
# cambian los datos.
estimado_argentina <- origen_anual |>
  filter(Reporter == "AR", Year %in% periodo_analisis) |>
  pull(pct_estimado) |> max()
estimado_brasil <- origen_anual |>
  filter(Reporter == "BR", Year %in% periodo_analisis) |>
  pull(pct_estimado) |> range()

peso_row <- bilateral |>
  filter(Item_code == "S") |>
  group_by(Reporter, Year) |>
  summarise(pct = 100 * sum(Balanced_value[Partner == "ROW"]) / sum(Balanced_value),
            .groups = "drop") |>
  pull(pct) |> max()
ceros_bilateral <- bilateral |>
  filter(Item_code %in% sectores, Year %in% periodo_analisis, Partner != "ROW")
sin_informar_anova <- 100 * (1 - sum(base_anova$anios_informados) /
                               (nrow(base_anova) * length(periodo_analisis)))
atipicos_bajos_detalle <- atipicos_mundo_detalle |> filter(tipo_atipico == "bajo")

diagnostico <- tribble(
  ~tema, ~magnitud, ~decision, ~justificacion,
  "Faltantes en el valor balanceado y en el final (nulos)",
  "0 nulos en las dos medidas; grilla completa (05_cobertura_bases)",
  "Nada que imputar",
  "Las combinaciones ausentes son economías que no existían ese año (Yugoslavia, Serbia, Montenegro, Antillas Neerlandesas, Curazao, Sint Maarten, Kosovo).",

  "Faltantes reales en la base al mundo (sin valor informado)",
  paste0(formato_num(sum(faltantes_final$sin_valor_informado), 0), " de ",
         formato_num(sum(faltantes_final$filas), 0),
         " filas país-sector-año sin valor informado (2005-2024); ",
         formato_num(sin_informar_anova, 1), "% de los años de la base del ANOVA"),
  "Se usa el valor final, que los completa con estimaciones de OCDE-OMC",
  "No hay nulos porque OCDE-OMC completa lo que el país no informa (06_faltantes_valor_final). Imputar de nuevo no agregaría información; se informa cuánto pesa lo estimado.",

  "Distribución por socio estimada (Argentina)",
  paste0("Total: 100% hasta 2014 y como máximo ", formato_num(estimado_argentina, 1),
         "% en 2015-2024. Por sector (2015-2024): ",
         texto_origen_sectores(origen_por_sector, "AR")),
  "El análisis principal usa 2015-2024; 2005-2014 no se usa como comparación para Argentina",
  "Desde 2015 Argentina declara a quién le vende. Antes, OCDE-OMC retroproyecta esa misma estructura hacia atrás (código E8.2): no es información propia de esos años. Los sectores con más de 50% estimado se leen con cautela.",

  "Distribución por socio estimada (Brasil)",
  paste0("Total: 100% hasta 2009 y entre ", formato_num(estimado_brasil[1], 1), "% y ",
         formato_num(estimado_brasil[2], 1), "% en 2015-2024. Por sector: ",
         texto_origen_sectores(origen_por_sector, "BR")),
  "Se compara el total, con la salvedad; por sector, solo como referencia",
  "Declara por socio el total de servicios de sus 37 socios principales, pero no la apertura por sector: esa la estima OCDE-OMC.",

  "Distribución por socio estimada (Chile)",
  paste0("Total: 100% todos los años. Por sector (2015-2024): ",
         texto_origen_sectores(origen_por_sector, "CL")),
  "Se compara, con la salvedad; transporte, viajes y otros empresariales son los únicos sectores con dato propio",
  "No declara el total por socio, pero sí parte de tres sectores. En el resto, la parte del exportador sale del modelo de gravedad de OCDE-OMC; el balanceado la combina con lo que declaran sus compradores.",

  "Distribución por socio estimada (Uruguay)",
  "100% en el total y en todos los sectores, todos los años",
  "Se compara, con la salvedad en cada tabla y gráfico",
  "No declara su comercio de servicios por socio. En el valor final, su distribución es el modelo de gravedad de OCDE-OMC; el balanceado la combina con lo que declaran sus compradores.",

  "Resto del mundo (ROW)",
  paste0("Como máximo ", formato_num(peso_row, 1), "% del valor"),
  "Se excluye de la concentración",
  "Es un residuo de socios no identificados: contarlo como un socio más inventaría un comprador que no existe. Pesa poco, así que no cambia los índices.",

  "Ceros en la base bilateral",
  paste0(formato_num(sum(ceros_bilateral$Balanced_value == 0), 0),
         " flujos país-socio-sector-año en cero en 2015-2024: ",
         formato_num(sum(ceros_bilateral$Balanced_value == 0 &
                           ceros_bilateral$origen == "Informado por fuente oficial"), 0),
         " declarados por el país, ",
         formato_num(sum(ceros_bilateral$Balanced_value == 0 &
                           ceros_bilateral$Final_value_methodology == "E0"), 0),
         " estimados despreciables (E0) y el resto, ceros de otras estimaciones de OCDE-OMC"),
  "Se conservan",
  "Son ventas no registradas ni estimadas; en su mayoría, ceros del modelo de OCDE-OMC, no un \"no exportó\" declarado. En el HHI pesan cero y no cambian ningún índice; tampoco cuentan como socios con ventas.",

  "Ceros en la base al mundo",
  paste0(sum(base_anova$valor_medio == 0), " de ", formato_num(nrow(base_anova), 0),
         " celdas país-sector con promedio cero: ",
         sum(base_anova$tipo_cero %in% "Cero informado los 10 años"), " informadas los diez años, ",
         sum(base_anova$tipo_cero %in% "Mixto: algunos años informados"), " mixtas, ",
         sum(base_anova$tipo_cero %in% "Nunca informado: OCDE-OMC lo estima despreciable (E0)"),
         " nunca informadas y estimadas despreciables (E0) y ",
         sum(base_anova$tipo_cero %in% "Nunca informado: OCDE-OMC lo completa con cero"),
         " nunca informadas y completadas con cero por OCDE-OMC"),
  "Quedan fuera del ANOVA sobre log(valor); entran en el Kruskal-Wallis, el RCA y los percentiles como \"no exportó\", con la salvedad",
  "El logaritmo de cero no existe. Solo los ceros informados son un \"no exportó\" declarado; los nunca informados son faltantes completados con cero (Chile en manufactura, mantenimiento, construcción y gobierno). Por eso, el RCA y el percentil de Chile en esos sectores no se interpretan, y el Kruskal-Wallis se presenta con y sin ceros.",

  "Atípicos en la base al mundo (1,5 RIC sobre el log)",
  paste0(sum(atipicos_mundo$atipicos_bajos), " bajos y ",
         sum(atipicos_mundo$atipicos_altos), " alto(s), sobre ", formato_num(nrow(positivos), 0),
         " celdas; ", sum(atipicos_bajos_detalle$anios_en_cero > 0), " de los ",
         nrow(atipicos_bajos_detalle), " bajos tienen años en cero dentro del promedio"),
  "Se conservan",
  "No son errores de carga. Los bajos son, sobre todo, series intermitentes: países con varios años en cero, cuyo promedio queda muy bajo (06_atipicos_mundo_detalle). El alto es EE.UU. en gobierno. El logaritmo reduce su influencia y el Kruskal-Wallis no depende de ellos. Efecto de la regla: una celda con nueve años en cero entra al ANOVA y una con diez queda afuera.",

  "Atípicos en la base bilateral (1,5 RIC sobre el log, 2024)",
  paste0(sum(atipicos_bilateral$atipicos_altos), " socios atípicos altos en ",
         sum(atipicos_bilateral$atipicos_altos > 0), " de ",
         nrow(atipicos_bilateral), " combinaciones país-sector"),
  "Se conservan",
  "Un socio que compra mucho más que el resto es la concentración que se quiere medir. Que el criterio marque tan pocos muestra que, en log, los flujos por socio varían mucho; por eso la concentración se mide con CR y HHI, no con atípicos."
)

print(diagnostico |> select(tema, magnitud))


# 6. GUARDAR ------------------------------------------------------------------

guardar_tabla(origen_por_sector,      "output/tablas/06_origen_por_sector.csv")
guardar_tabla(ceros_mundo,            "output/tablas/06_ceros_mundo_sectores.csv")
guardar_tabla(faltantes_final,        "output/tablas/06_faltantes_valor_final.csv")
guardar_tabla(atipicos_mundo,         "output/tablas/06_atipicos_mundo_sectores.csv")
guardar_tabla(atipicos_mundo_detalle, "output/tablas/06_atipicos_mundo_detalle.csv")
guardar_tabla(atipicos_bilateral,     "output/tablas/06_atipicos_bilateral.csv")
guardar_tabla(diagnostico,            "output/tablas/06_diagnostico_resumen.csv")

ggsave("output/graficos/06_g1_origen_bilateral.png", g_origen,
       width = 8, height = 5.5, dpi = 200, bg = "white")
ggsave("output/graficos/06_g2_boxplot_sectores.png", g_box,
       width = 9, height = 6.5, dpi = 200, bg = "white")
