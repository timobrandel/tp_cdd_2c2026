suppressPackageStartupMessages(library(tidyverse))
options(width = 200, pillar.width = 200, digits = 8)
tipos <- cols(Reporter = col_character(), Partner = col_character(), Item_code = col_character(),
  Year = col_integer(), Reported_value = col_double(), Final_value = col_double(),
  Final_value_methodology = col_character(), Balanced_value = col_double(), .default = col_guess())
b <- read_csv("input/batis_bilateral.csv", na = "", col_types = tipos)
m <- read_csv("input/batis_mundo_sectores.csv", na = "", col_types = tipos)
cat("== dims\n"); print(dim(b)); print(dim(m))
cat("== nulos\n"); print(colSums(is.na(b))); print(colSums(is.na(m)))
cat("== unicidad\n"); print(anyDuplicated(b[c("Reporter","Partner","Item_code","Year")])); print(anyDuplicated(m[c("Reporter","Item_code","Year")]))
cat("pct NA reported:", 100*mean(is.na(b$Reported_value)), 100*mean(is.na(m$Reported_value)), "\n")
cat("== ceros\n"); cat(sum(b$Balanced_value==0), sum(b$Final_value==0), sum(m$Final_value==0), sum(m$Balanced_value==0), "\n")
cat("min bal mundo:", min(m$Balanced_value), "\n")
cat("n socios:", n_distinct(b$Partner), " partners != ROW:", n_distinct(b$Partner[b$Partner!="ROW"]), "\n")
cat("== NA reported mundo por S vs sectores\n"); print(m |> group_by(es_S = Item_code=="S") |> summarise(n=n(), na=sum(is.na(Reported_value))))
cat("== sin valor informado (origen) sectores\n"); print(m |> filter(Item_code!="S") |> count(origen, na_rep = is.na(Reported_value)))

# Brasil: pct estimado por distintas ponderaciones
cat("== pct estimado total S por pais-año, ponderaciones\n")
pe <- b |> filter(Item_code=="S", Year>=2015) |>
  group_by(Reporter, Year) |>
  summarise(bal_conROW = 100*sum(Balanced_value[origen=="Estimado por OCDE-OMC"])/sum(Balanced_value),
            bal_sinROW = 100*sum(Balanced_value[origen=="Estimado por OCDE-OMC" & !es_resto_mundo])/sum(Balanced_value[!es_resto_mundo]),
            fin_conROW = 100*sum(Final_value[origen=="Estimado por OCDE-OMC"])/sum(Final_value),
            fin_sinROW = 100*sum(Final_value[origen=="Estimado por OCDE-OMC" & !es_resto_mundo])/sum(Final_value[!es_resto_mundo]), .groups="drop")
print(pe |> group_by(Reporter) |> summarise(across(-Year, list(min=min, max=max, mean=mean))), width=Inf)

# Indices anuales
idx <- function(v) { s <- v/sum(v); s <- sort(s, decreasing=TRUE); c(cr1=s[1]*100, cr4=sum(s[1:4])*100, hhi=sum(s^2)*1e4) }
an <- b |> filter(!es_resto_mundo, Year>=2015) |> pivot_longer(c(Balanced_value, Final_value), names_to="medida", values_to="v") |>
  group_by(medida, Reporter, Item_code, Year) |> filter(sum(v)>0) |>
  summarise(cr1=idx(v)[1], cr4=idx(v)[2], hhi=idx(v)[3], .groups="drop")
pr <- an |> group_by(medida, Reporter, Item_code) |> summarise(anios=n(), cr1=mean(cr1), cr4=mean(cr4), hhi=mean(hhi), .groups="drop") |> mutate(seq=1e4/hhi)
cat("== total S exacto\n"); print(pr |> filter(Item_code=="S") |> as.data.frame(), digits=8)
cat("== HHI anual S balanceado AR vs CL\n")
print(an |> filter(medida=="Balanced_value", Item_code=="S", Reporter %in% c("AR","CL")) |> select(Reporter, Year, hhi) |> pivot_wider(names_from=Reporter, values_from=hhi) |> mutate(cl_mayor = CL>AR) |> as.data.frame())
cat("== AR balanceado sectores exactos\n"); print(pr |> filter(medida=="Balanced_value", Reporter=="AR") |> arrange(seq) |> as.data.frame(), digits=8)
cat("== CV HHI entre sectores (sin S)\n")
print(pr |> filter(Item_code!="S") |> group_by(medida, Reporter) |> summarise(n=n(), cv=sd(hhi)/mean(hhi), minseq=min(seq), maxseq=max(seq), ratio=max(seq)/min(seq), .groups="drop") |> as.data.frame())
cat("== CV HHI final sin sectores con < 10 anios\n")
print(pr |> filter(Item_code!="S", anios==10) |> group_by(medida, Reporter) |> summarise(n=n(), cv=sd(hhi)/mean(hhi), minseq=min(seq), maxseq=max(seq), ratio=max(seq)/min(seq), .groups="drop") |> as.data.frame())
cat("== UY final SE anios con valor\n"); print(b |> filter(Reporter=="UY", Item_code=="SE", Year>=2015, !es_resto_mundo) |> group_by(Year) |> summarise(fin=sum(Final_value), bal=sum(Balanced_value)))
cat("== UY top 5 socios balanceado promedio participaciones 2015-2024\n")
print(b |> filter(Reporter=="UY", Item_code=="S", Year>=2015, !es_resto_mundo) |> group_by(Year) |> mutate(s=100*Balanced_value/sum(Balanced_value)) |> group_by(Partner) |> summarise(s=mean(s)) |> arrange(desc(s)) |> head(6))
cat("== AR top 5 balanceado\n")
print(b |> filter(Reporter=="AR", Item_code=="S", Year>=2015, !es_resto_mundo) |> group_by(Year) |> mutate(s=100*Balanced_value/sum(Balanced_value)) |> group_by(Partner) |> summarise(s=mean(s)) |> arrange(desc(s)) |> head(6))
cat("== ROW peso max\n"); print(b |> filter(Item_code=="S") |> group_by(Reporter, Year) |> summarise(p=100*sum(Balanced_value[es_resto_mundo])/sum(Balanced_value), pf=100*sum(Final_value[es_resto_mundo])/sum(Final_value), .groups="drop") |> summarise(maxb=max(p), maxf=max(pf)))

# ANOVA base / relacion metodos
base <- m |> filter(Item_code!="S", Year>=2015) |> group_by(Reporter, Item_code) |> summarise(n=n(), v=mean(Final_value), .groups="drop") |> filter(n==10)
cat("== base anova:", nrow(base), n_distinct(base$Reporter), "positivas", sum(base$v>0), "\n")
gm <- base |> filter(v>0) |> group_by(Item_code) |> summarise(gm=exp(mean(log(v))), sdlog=sd(log(v)))
print(gm |> arrange(desc(gm)) |> as.data.frame(), digits=8)
cat("cociente sd:", max(gm$sdlog)/min(gm$sdlog), "\n")
a1 <- aov(log(v) ~ Item_code, data = base |> filter(v>0)); s1 <- summary(a1)[[1]]; print(s1); cat("eta2:", s1[1,2]/sum(s1[,2]), "\n")
a2 <- aov(log(v) ~ Reporter + Item_code, data = base |> filter(v>0)); s2 <- summary(a2)[[1]]; print(s2); cat("pais/SCT:", s2[1,2]/sum(s2[,2]), " sector/SCT:", s2[2,2]/sum(s2[,2]), "\n")
print(oneway.test(log(v) ~ Item_code, data = base |> filter(v>0)))
print(kruskal.test(v ~ factor(Item_code), data = base))
print(TukeyHSD(a1)$Item_code |> as.data.frame() |> summarise(sig=sum(`p adj`<0.05)))
ar_seq <- pr |> filter(medida=="Balanced_value", Reporter=="AR", Item_code!="S") |> select(Item_code, seq)
arv <- base |> filter(Reporter=="AR") |> select(Item_code, v)
rel <- ar_seq |> left_join(gm, by="Item_code") |> left_join(arv, by="Item_code")
print(rel |> arrange(seq) |> as.data.frame())
cat("spearman seq AR vs media geom mundial:", cor(rel$seq, rel$gm, method="spearman"), "\n")
cat("spearman seq AR vs valor AR:", cor(rel$seq, rel$v, method="spearman"), "\n")
cat("cor.test:\n"); print(cor.test(rel$seq, rel$gm, method="spearman", exact=TRUE))
