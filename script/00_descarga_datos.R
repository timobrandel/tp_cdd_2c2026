# -----------------------------------------------------------------
# Script      00_descarga_datos.R
# Objetivo    Descargar de la OMC los archivos originales de BaTIS
#             (BPM6, version publicada el 08/12/2025) y descomprimirlos
# Entrada     URLs oficiales de la OMC (wto.org)
# Salida      raw/OECD-WTO_BATIS_data_BPM6-1.zip  (509 MB) + CSV adentro (~2,8 GB)
#             raw/OECD-WTO_BATIS_codes_BPM6-1.zip (diccionario de codigos)
#             raw/OECD-WTO_Batis_methodology_BPM6.pdf (metodologia oficial)
# -----------------------------------------------------------------
# Se corre una sola vez: si un archivo ya esta en raw/, no lo vuelve a bajar.
# Abrir antes el proyecto tp_cdd_2c2026.Rproj, asi la carpeta de trabajo
# es la raiz del proyecto y la ruta relativa "raw/" funciona en cualquier compu.

# download.file() corta a los 60 segundos por defecto; el zip de datos
# pesa 509 MB, asi que subimos el limite a una hora.
options(timeout = 3600)

url_base <- "https://www.wto.org/english/res_e/statis_e/daily_update_e/"

archivos <- c(
  "OECD-WTO_BATIS_data_BPM6-1.zip",
  "OECD-WTO_BATIS_codes_BPM6-1.zip",
  "OECD-WTO_Batis_methodology_BPM6.pdf"
)

dir.create("raw", showWarnings = FALSE)

for (archivo in archivos) {
  destino <- file.path("raw", archivo)
  if (!file.exists(destino)) {
    # mode = "wb" (binario) es obligatorio en Windows: sin eso el zip se corrompe
    download.file(paste0(url_base, archivo), destfile = destino, mode = "wb")
  }
}

# Descomprimimos cada zip en raw/ solo si su contenido todavia no esta extraido
zips <- file.path("raw", archivos[grepl("\\.zip$", archivos)])

for (zip in zips) {
  contenido_zip <- unzip(zip, list = TRUE)$Name
  if (!all(file.exists(file.path("raw", contenido_zip)))) {
    unzip(zip, exdir = "raw")
  }
}

# Control: que quedo en raw/ y cuanto pesa cada archivo (en MB)
tamanios <- file.info(list.files("raw", full.names = TRUE, recursive = TRUE))
print(round(tamanios["size"] / 1e6, 1))
