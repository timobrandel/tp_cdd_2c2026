# -----------------------------------------------------------------
# Función     clasificar_origen()
# Objetivo    Agrupar los códigos de metodología de BaTIS según el origen
#             del dato: informado por el país, derivado o estimado
# Entrada     codigo: vector de texto con Final_value_methodology
# Salida      Vector de texto con tres categorías posibles
# -----------------------------------------------------------------
# Códigos según la hoja "methodology codes" del diccionario y el Anexo H de
# raw/OECD-WTO_Batis_methodology_BPM6.pdf:
# - "R_..." (R_IMF, R_NAT, R_OECD, etc.): dato informado por una fuente
#   oficial (FMI, fuente nacional, OCDE, Eurostat)
# - "E1": derivación simple a partir de datos informados
# - el resto (E0, E2, E3, E5, M..., etc.): estimaciones de OCDE-OMC
#   (ceros, crecimiento de la balanza de pagos, participaciones pasadas,
#   tasas regionales, modelos de gravedad)

clasificar_origen <- function(codigo) {
  dplyr::case_when(
    stringr::str_starts(codigo, "R_") ~ "Informado por fuente oficial",
    codigo == "E1"                    ~ "Derivado de datos informados",
    TRUE                              ~ "Estimado por OCDE-OMC"
  )
}
