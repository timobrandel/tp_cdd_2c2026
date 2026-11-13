# Script   verificar_entorno_graficos.R
# Objetivo Reproducir las condiciones que rompían cli y el texto de los gráficos
# Entrada  utils/preparar_entorno_graficos.R; paquetes del script 10
# Salida   Mensaje de control y código de salida 0
# Ejecutar en una sesión nueva desde la raíz del proyecto.

if (.Platform$OS.type == "windows") {
  # Reproduce el lanzador defectuoso; solamente cambia este proceso de prueba.
  Sys.unsetenv("PROCESSOR_ARCHITECTURE")
  invisible(Sys.setlocale("LC_CTYPE", "C"))
}

source("utils/preparar_entorno_graficos.R")
preparar_entorno_graficos()

if (.Platform$OS.type == "windows") {
  stopifnot(nzchar(Sys.getenv("PROCESSOR_ARCHITECTURE")),
            isTRUE(l10n_info()[["UTF-8"]]))
}

# Antes de la corrección, cargar cli provocaba 0xC0000005 al cerrar R.
library(cli)
library(ggtext)
archivo_temporal <- tempfile(fileext = ".pdf")
grDevices::pdf(archivo_temporal)
rotulo <- gridtext::richtext_grob("¿A quién? <b>Argentina</b>")
stopifnot(inherits(rotulo, "grob"))
invisible(grDevices::dev.off())
unlink(archivo_temporal)
cat("OK: arquitectura disponible y texto con acentos renderizable.\n")
# No forzar quit(status=0): el proceso debe ejecutar sus finalizadores normalmente.
