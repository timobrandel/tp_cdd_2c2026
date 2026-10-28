suppressPackageStartupMessages(library(tidyverse))
options(width = 250)
d <- "output/tablas/"
rd <- function(f) suppressMessages(read_csv2(paste0(d, f, ".csv"), show_col_types = FALSE, na = ""))
for (f in c("03_crecimiento","03_pandemia","03_robustez_composicion","02_unidad_observacion","06_atipicos_mundo_detalle")) { cat("\n=====", f, "\n"); print(as.data.frame(rd(f))) }
p <- rd("08_comparaciones_pares"); cat("\n===== pares\n"); print(names(p)); print(as.data.frame(p))
