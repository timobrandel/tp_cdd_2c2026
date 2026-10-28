suppressPackageStartupMessages(library(tidyverse)); options(width=250)
print(as.data.frame(suppressMessages(read_csv2("output/tablas/04_crecimiento.csv", show_col_types=FALSE))))
