# -----------------------------------------------------------------
# Función     test_levene()
# Objetivo    Contrastar si los grupos tienen varianzas iguales
#             (supuesto de homogeneidad del ANOVA)
# Entrada     y: vector numérico; grupo: vector con el grupo de cada valor
# Salida      Lista con el estadístico F, los grados de libertad y el
#             p-valor
# -----------------------------------------------------------------
# Es el test de Levene centrado en la mediana (variante de Brown-Forsythe),
# el que corre por defecto car::leveneTest(), escrito con R base porque car
# no está instalado. La idea: si las varianzas son iguales, la distancia
# promedio de cada valor a la mediana de su grupo tiene que ser parecida en
# todos los grupos. Por eso es un ANOVA sobre esas distancias.
# H0: varianzas iguales. Un p-valor chico indica que no lo son.

test_levene <- function(y, grupo) {
  grupo     <- factor(grupo)
  distancia <- abs(y - stats::ave(y, grupo, FUN = stats::median))
  tabla     <- summary(stats::aov(distancia ~ grupo))[[1]]
  list(
    estadistico = tabla$`F value`[1],
    gl_entre    = tabla$Df[1],
    gl_dentro   = tabla$Df[2],
    p_valor     = tabla$`Pr(>F)`[1]
  )
}
