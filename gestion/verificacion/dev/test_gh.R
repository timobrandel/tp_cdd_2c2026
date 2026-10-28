source("utils/games_howell.R"); source("utils/test_levene.R")
set.seed(1)
g <- rep(c("a","b","c","d"), each = 400)
y <- rnorm(1600, mean = c(a=0,b=0.1,c=0.3,d=0.35)[g], sd = 1)
gh <- games_howell(y, g)
tk <- as.data.frame(TukeyHSD(aov(y ~ g))$g)
print(cbind(gh[, c("group1","group2","estimate","p.adj")], tukey_diff = tk$diff, tukey_p = tk$`p adj`))
# Levene: con varianzas iguales p alto; con distintas, p chico
print(test_levene(y, g)$p_valor)
y2 <- y * c(a=1,b=1,c=2,d=3)[g]
print(test_levene(y2, g)$p_valor)
