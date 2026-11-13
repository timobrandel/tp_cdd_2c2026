# -----------------------------------------------------------------
# Función     preparar_entorno_graficos()
# Objetivo    Corregir dos variables del proceso en Windows antes de cargar
#             paquetes: arquitectura para cli y codificación para los títulos
# Entrada     Configuración del proceso actual; no cambia archivos del sistema
# Salida      La sesión puede renderizar acentos y cerrar sin el fallo de cli
# -----------------------------------------------------------------
preparar_entorno_graficos <- function() {
  if (.Platform$OS.type == "windows") {
    # Algunos lanzadores omiten esta variable habitual de Windows.
    # cli 3.6.6 la consulta al cerrar su temporizador y falla si no existe.
    # No reemplazamos el valor cuando Windows ya lo proporciona.
    if (!nzchar(Sys.getenv("PROCESSOR_ARCHITECTURE"))) {
      arquitectura <- switch(R.version$arch,
                             x86_64 = "AMD64", aarch64 = "ARM64",
                             i386 = "x86", R.version$arch)
      Sys.setenv(PROCESSOR_ARCHITECTURE = arquitectura)
    }
    # C.UTF-8 es un nombre de locale de Unix, que Windows no reconoce.
    # .UTF-8 es el nombre aceptado por R moderno en Windows.
    if (!isTRUE(l10n_info()[["UTF-8"]])) {
      configuracion <- Sys.setlocale("LC_CTYPE", ".UTF-8")
      if (!nzchar(configuracion)) stop("No se pudo activar UTF-8 para los gráficos.")
    }
  }
  invisible(NULL)
}
