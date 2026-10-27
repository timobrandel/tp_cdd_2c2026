# -----------------------------------------------------------------
# Función     games_howell()
# Objetivo    Comparar todos los pares de grupos después de un ANOVA
#             cuando las varianzas no son parecidas (alternativa a Tukey)
# Entrada     y: vector numérico; grupo: vector con el grupo de cada valor;
#             nivel: nivel de confianza de los intervalos (0,95)
# Salida      Tibble con una fila por par: group1, group2, n1, n2,
#             estimate (media de group2 - media de group1), conf.low,
#             conf.high, p.adj
# -----------------------------------------------------------------
# Es el test que la clase 10 corre con rstatix::games_howell_test(), escrito
# con R base porque rstatix no está instalado. Misma convención de signo.
# Diferencia con Tukey: cada par usa sus propias varianzas y sus grados de
# libertad de Welch, en vez de una varianza común a todos los grupos.
# El p-valor sale de la distribución del rango estudentizado (ptukey), la
# misma de Tukey, así que el 5% vale para el conjunto de pares.

games_howell <- function(y, grupo, nivel = 0.95) {
  grupo   <- as.character(grupo)
  niveles <- sort(unique(grupo))
  k       <- length(niveles)

  n     <- tapply(y, grupo, length)[niveles]
  media <- tapply(y, grupo, mean)[niveles]
  varz  <- tapply(y, grupo, var)[niveles]

  pares <- utils::combn(niveles, 2)

  purrr::map_dfr(seq_len(ncol(pares)), function(j) {
    a <- pares[1, j]
    b <- pares[2, j]
    va <- varz[[a]] / n[[a]]
    vb <- varz[[b]] / n[[b]]

    diferencia <- media[[b]] - media[[a]]
    error      <- sqrt((va + vb) / 2)
    # Grados de libertad de Welch-Satterthwaite para el par
    gl <- (va + vb)^2 / (va^2 / (n[[a]] - 1) + vb^2 / (n[[b]] - 1))

    q_critico <- stats::qtukey(nivel, k, gl)
    tibble::tibble(
      group1    = a,
      group2    = b,
      n1        = n[[a]],
      n2        = n[[b]],
      estimate  = diferencia,
      conf.low  = diferencia - q_critico * error,
      conf.high = diferencia + q_critico * error,
      p.adj     = stats::ptukey(abs(diferencia) / error, k, gl, lower.tail = FALSE)
    )
  })
}
