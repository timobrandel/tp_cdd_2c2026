suppressPackageStartupMessages(library(tidyverse))
options(width = 250, pillar.width = 250)
d <- "output/tablas/"
for (f in c("05_origen_bilateral","06_diagnostico_resumen","06_faltantes_valor_final","07_comparacion_medidas","07_contraste_hipotesis","07_concentracion_sectores","07_diversidad","07_sensibilidad_periodo","08_tests","08_descriptivos_sectores","08_posicion_paises","09_unidad_observacion","09_tabla_variables","06_atipicos_mundo_sectores")) {
  cat("\n=====", f, "\n")
  x <- read_csv2(paste0(d, f, ".csv"), show_col_types = FALSE, na = "")
  print(as.data.frame(x))
}
