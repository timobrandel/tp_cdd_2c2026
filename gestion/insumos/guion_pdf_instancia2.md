# Guion del PDF · Instancia 2 (métodos)

- **Consigna:** `CURSO/trabajo_practico/consignas_instancia_2.md`. PDF de 10 a 15 diapositivas sin contar carátula y cierre; sin código. Vence el **jueves 29/10 a las 23:59**. Envío a nsidicaro.fce@gmail.com, asunto `curso_2c_2026_grupo_XX_instancia_2`, un integrante envía con los demás en copia.
- **Hilo que pide la consigna:** ¿de dónde venimos? → ¿qué hicimos con faltantes y outliers? → ¿qué método aplicamos y por qué? → ¿qué encontramos? → ¿qué significa para la hipótesis?
- **Quién arma qué (D-007):** este archivo es material e interpretación. La redacción y el diseño de las diapositivas los hace el grupo con sus palabras.
- **Origen de cada cifra:** entre corchetes, el archivo de `output/tablas/` o `output/graficos/`. Las tablas se abren con doble clic en Excel (D-016). Ninguna cifra sale de memoria: todas se cotejaron contra esas tablas (sección final).
- **Unidades:** millones de USD corrientes. Período del análisis: 2015-2024 (D-024).
- **Medidas (D-023, D-029):** concentración por socio con el **valor balanceado** (principal) y el **valor final** (sensibilidad). ANOVA y diversidad con el **valor final** al mundo (D-026).

**Recuento:** 14 diapositivas de contenido + carátula + anexo. Si sobra espacio, la 5 y la 6 se pueden unir; si falta, la 11 (diversidad) pasa al anexo.

---

## 0. Carátula
Título del TP, integrantes (Brenda Firmano, Diego Sebastián Díez de Los Ríos, Timothy Brandel), materia, "Instancia 2: métodos estadísticos y cuantitativos", fecha. Fuente: OECD-WTO BaTIS, BPM6, versión diciembre 2025.

---

## 1. De dónde venimos: síntesis de la Instancia 1
**Material:** sin gráfico, o una miniatura de `03_g5_composicion_2005_2024.png`.

**Cifras** (de la PPT entregada; respaldo en `gestion/insumos/insumos_ppt_instancia1.md`):
- Base: OECD-WTO BaTIS, BPM6, versión 12/2025. Base de trabajo de la Instancia 1: 1.040 filas = 4 países × 20 años × 13 categorías, exportaciones al mundo. Unidad: país × año × categoría [02_unidad_observacion].
- Pregunta guía: cómo evolucionaron el nivel y la composición de las exportaciones de servicios de Argentina 2005-2024 frente a Brasil, Chile y Uruguay.
- Medida de la Instancia 1: **valor final** al mundo (D-015). Todas las cifras de esta diapositiva son con esa medida; Chile 2023-2024 son estimaciones de OCDE-OMC.
- Hallazgos:
  - Argentina creció +165% nominal (5,3% anual), tercera de cuatro; Uruguay +430%, Brasil +228% [03_crecimiento]. Con el balanceado queda cuarta (+161%; Chile pasa a +180%) [04_crecimiento]: así lo mostró la diapositiva de robustez de la Instancia 1.
  - Mayor caída en 2020 (−35,9%) y menor recuperación a 2024 contra 2019 (+15,7%; vecinos de +25,8% a +46,8%; Chile 2024 estimado) [03_pandemia].
  - Giro a servicios de conocimiento: en Argentina, de 31% a 51% del total entre 2005 y 2024 [03_robustez_composicion].

**Interpretación:** la Instancia 1 describió cuánto y qué exporta cada país al mundo. Le faltaba lo propio de BaTIS: a quién le vende cada país.

---

## 2. Qué cambiamos por la devolución
**Material:** tabla de tres columnas: "Qué pidió el docente" / "Qué hicimos" / "Dónde está".

| Pidió el docente (nota 7/10) | Qué hicimos | Diapositiva |
|---|---|---|
| Aprovechar el comercio bilateral | Nueva base país × socio: 4 países × 202 socios × 13 ítems × 20 años | 4 |
| Concentración de socios por país y sector, con cualquier índice | CR1, CR4 y HHI por país, sector y año | 8 a 10 |
| Índice de diversidad | Sectores con ventaja comparativa revelada (RCA > 1), como en la clase 12 | 11 |
| ANOVA con todos los países para ver si los sectores difieren en el valor | ANOVA de log(valor) entre 12 sectores, 200 economías, con robustez | 12 y 13 |

**Otros cambios:**
- La pregunta guía pasó a ser una hipótesis contrastable (diapositiva 3).
- Para lo bilateral se usa el **valor balanceado** (D-023): concilia lo que declaran exportador e importador y es la medida que la metodología de BaTIS recomienda para los flujos entre pares (secciones 5.1 y 6). Para los totales al mundo sigue el valor final, como en la Instancia 1 (D-015).

**Observaciones de la devolución no incorporadas:** ninguna; las tres herramientas que sugirió el docente están aplicadas tal como las propuso (D-024). *Antes de entregar, el grupo tiene que cotejar esta tabla con el texto de la devolución: no está transcripto en el repo, solo resumido en la hoja de ruta (paso 2.1) y en D-023. Si la devolución tenía otra observación, va acá con lo que se hizo o por qué no.*

**Además, qué quedó pendiente de nuestros propios "próximos pasos" de la Instancia 1:**
- **Test pareado de crecimiento entre países:** se priorizó el ANOVA entre sectores que pidió el docente, que responde una parte de la hipótesis. Queda para la entrega final.
- **Deflactar:** los índices de concentración no cambian, porque son participaciones dentro de cada año y un deflactor común se cancela. El ANOVA sigue en USD corrientes: va como limitación (diapositiva 13).
- **Balassa en servicios de conocimiento:** el RCA se calculó para los 12 sectores (diapositiva 11). En Argentina, telecom. e informática (SI) y otros empresariales (SJ) tienen RCA > 1 [07_diversidad].

---

## 3. Hipótesis de trabajo y cómo la contrastamos
**Material:** la hipótesis destacada y un esquema de tres partes → método.

**Hipótesis (D-024), textual:** "Entre 2015 y 2024, las exportaciones de servicios de Argentina se concentran en menos socios que las de Brasil, Chile y Uruguay, y tanto esa concentración como el valor exportado difieren según el sector."

| Parte | Método | Tipo |
|---|---|---|
| "Se concentran en menos socios" | CR1, CR4 y HHI del total de servicios, por país | Cuantitativo (Unidad 3) |
| "Esa concentración difiere según el sector" | Los mismos índices abiertos por sector | Cuantitativo |
| "El valor exportado difiere según el sector" | ANOVA de log(valor) entre 12 sectores, todos los países | Inferencia (Unidad 2) |

**Por qué 2015-2024:** es el período en que Argentina declara a quién le vende (diapositiva 5).
**Advertencia que va en la diapositiva:** el análisis describe asociaciones, no causas.

---

## 4. Las bases nuevas: estructura y variables
**Material:** [09_tabla_variables] (recortar a las columnas variable, tipo, nulos, ceros y uso) y [09_unidad_observacion].

**Cifras** [09_unidad_observacion, 09_tabla_variables]:
- `batis_bilateral`: 207.480 filas × 11 variables. Unidad: país informante × socio × sector × año. 4 países, 203 socios (202 economías + ROW, "resto del mundo"), 13 ítems (total + 12 sectores), 20 años. 207.480 combinaciones únicas: cero duplicados.
- `batis_mundo_sectores`: 51.870 filas × 10 variables. Unidad: país × sector × año, socio = mundo. 202 países, 13 ítems, 20 años. 51.870 combinaciones únicas.
- Nulos: solo `Reported_value` (95,18% en la bilateral, 18,44% en la base al mundo). `Final_value` y `Balanced_value` tienen 0 nulos. El 18,44% es sobre toda la base al mundo (202 países, 2005-2024, con el total S incluido); la diapositiva 6 mide los faltantes sobre otra base (los 12 sectores, sin el total), por eso los porcentajes no coinciden.
- Ceros: `Balanced_value` bilateral 19.869; `Final_value` bilateral 53.707; `Final_value` al mundo 10.119.
- Medidas por base: bilateral → balanceado (principal) y final (sensibilidad); al mundo → final.

**Interpretación:** no hay nulos en las medidas porque OCDE-OMC completa lo que nadie informa. El faltante real no se ve como NA: está escondido en el origen del dato y en los ceros, que se analizan en las diapositivas 5 y 6.

**Nota de lectura de la tabla:** `Balanced_value` al mundo figura con "mín. 0" y 0 ceros. No es una contradicción: el mínimo es positivo, pero menor a 0,005 y se redondea a 0 con dos decimales.

---

## 5. Faltantes (I): ¿quién declara a quién le vende?
**Material:** `06_g1_origen_bilateral.png`.

**Cifras** [06_diagnostico_resumen, que coincide con el gráfico; 05_origen_bilateral; 07_comparacion_medidas]:
- Parte del valor exportado cuya distribución por socio estima OCDE-OMC (no la declara el exportador). Igual que el gráfico: el valor se pondera con el balanceado y sin ROW.
  - Argentina: 100% en 2005-2014; en 2015-2024, como máximo 0,4%. Con dato propio: entre 141 y 167 socios por año [05_origen_bilateral].
  - Brasil: 100% hasta 2009; en 2015-2024, entre 29,7% y 37,3%. Declara 37 socios.
  - Chile y Uruguay: 100% todos los años.
- Si se pondera con el valor final, la parte estimada de Brasil en 2015-2024 sube a 43,7% en promedio [07_comparacion_medidas, `pct_estimado`]. Es lo que significa el "56% propio" de D-029. La cifra cambia con la ponderación porque Brasil declara sus 37 socios principales y el resto lo estima OCDE-OMC; si en el PDF va una sola cifra, que sea la del gráfico y con la aclaración.
- En 2005-2014, el dato de Argentina es una retroproyección de la estructura que declara desde 2015 (código E8.2).

**Estrategia:** restringir el período a 2015-2024 y conservar los estimados, con la salvedad explícita (la consigna lista "restringir el período" y "mantener los faltantes"). No se imputa nada: OCDE-OMC ya completó y repetirlo no agrega información.

**Consecuencias:** con el valor final, comparar Argentina con Chile y Uruguay es comparar un dato declarado con un modelo de gravedad. Por eso la medida principal es el balanceado, que mide a los cuatro de la misma forma: incluye lo que declaran sus compradores (D-029).

**Frase:** solo Argentina y Brasil declaran a quién le venden; en Chile y Uruguay, la distribución por socio la estima OCDE-OMC.

---

## 6. Faltantes (II): ceros y años sin informar en la base al mundo
**Material:** [06_faltantes_valor_final] (columna `pct_sin_informar` de 2015-2024) y [06_diagnostico_resumen] (filas de ceros).

**Cifras:**
- 2015-2024: el porcentaje de filas país-año sin valor informado va de 9,4% (viajes) a 31,25% (manufactura sobre insumos de terceros: 625 de 2.000) [06_faltantes_valor_final]. En toda la base 2005-2024, 9.263 de 47.880 filas país-sector-año; en la base del ANOVA, el 17,8% de los años [06_diagnostico_resumen].
- Ceros en la base al mundo: 318 de 2.400 celdas país-sector con promedio cero. Por origen: 73 informadas como cero los diez años, 101 mixtas, 17 nunca informadas y estimadas despreciables (E0), 127 nunca informadas y completadas con cero [06_diagnostico_resumen].
- Ceros bilaterales 2015-2024: 7.978 flujos; solo 144 los declaró el país, 1.043 son E0 y el resto, ceros de otras estimaciones de OCDE-OMC [06_diagnostico_resumen].

**Estrategia:**
- Base al mundo: se usa el valor final, que completa lo no informado; se informa cuánto pesa lo estimado. Los ceros quedan fuera del ANOVA sobre log(valor), porque log(0) no existe, y entran en el Kruskal-Wallis, el Friedman y el RCA.
- Bilateral: los ceros se conservan. En el HHI pesan cero y no cambian ningún índice.

**Consecuencias:** el ANOVA compara solo celdas con valor positivo, así que en los sectores con muchos ceros (manufactura sobre insumos de terceros: 78 países) describe a los países que sí exportan. Por eso se presenta también el Kruskal-Wallis con ceros. Chile nunca informa manufactura, mantenimiento, construcción y gobierno: su posición en esos sectores no se interpreta [08_posicion_paises, columna `interpretable`].

**Frase:** un cero no siempre es "no exportó": la mayoría son faltantes que OCDE-OMC completa con cero.

---

## 7. Valores atípicos
**Material:** `06_g2_boxplot_sectores.png`.

**Criterio:** regla del boxplot, 1,5 rangos intercuartiles, sobre el **logaritmo** del valor y **dentro de cada sector**. El log porque la distribución es muy asimétrica (ya se vio en la Instancia 1); por sector porque cada sector tiene su propia escala.

**Cifras:**
- Base al mundo: 17 atípicos sobre 2.082 celdas con valor: 16 bajos y 1 alto (EE.UU. en gobierno). 14 de los 16 bajos tienen años en cero dentro del promedio [06_diagnostico_resumen, 06_atipicos_mundo_sectores].
- Bilateral, 2024: 9 socios atípicos altos en 7 de las 48 combinaciones país-sector [06_diagnostico_resumen].

**¿Errores o genuinos?** Genuinos. 14 de los 16 bajos son series intermitentes (países con varios años en cero, cuyo promedio queda muy bajo), no errores de carga. Los otros dos (Papúa Nueva Guinea en viajes y Tuvalu en gobierno) no tienen años en cero: son valores chicos de economías chicas, informados por el país 9 de los 10 años [06_atipicos_mundo_detalle]. En lo bilateral, un socio que compra mucho más que el resto es justamente la concentración que se quiere medir.

**Estrategia:** se conservan todos. El log reduce su influencia en el ANOVA y el Kruskal-Wallis no depende de ellos.

**Consecuencias:** el ANOVA es sensible a los extremos; por eso se contrasta con métodos por rangos (diapositiva 13). Efecto de la regla que hay que poder explicar: una celda con nueve años en cero entra al ANOVA y una con diez queda afuera.

---

## 8. Método cuantitativo: concentración por socio
**Material:** sin gráfico, o la fórmula del HHI con un ejemplo.

**Justificación:** la hipótesis habla de "concentrarse en menos socios". CR y HHI (clase 12) miden eso directamente con las participaciones de cada socio.

**Decisiones metodológicas** (D-026, D-029):
- **Índices:** CR1 (participación del primer socio), CR4 (de los cuatro primeros), HHI = suma de las participaciones al cuadrado, en escala 0 a 10.000 (10.000 = un solo comprador). **Socios equivalentes** = 10.000 / HHI: cuántos socios del mismo tamaño darían esa concentración.
- **Medida:** balanceado como principal (mide igual a los cuatro países); valor final como sensibilidad.
- **ROW excluido:** es un residuo de socios no identificados; contarlo inventaría un comprador. Pesa como máximo 0,7%.
- **Cálculo:** índices año por año y promedio 2015-2024. Los socios equivalentes salen del HHI promedio.
- **Unidad:** el total de servicios para la comparación entre países; los 12 sectores para la segunda parte de la hipótesis.

**Limitaciones:**
- El HHI depende de la medida: con el balanceado y con el final, los resultados frente a Chile y Uruguay cambian (diapositiva 10).
- En Chile y Uruguay la distribución por socio es estimada.
- El CR4 y el HHI pueden ordenar distinto: el CR4 mira solo los cuatro primeros socios y el HHI, a todos.

---

## 9. Resultado: concentración del total de servicios, 2015-2024
**Material:** `07_g1_hhi_total.png` y la tabla de abajo.

**Cifras** [07_comparacion_medidas]:

| Medida | Índice | Argentina | Brasil | Chile | Uruguay |
|---|---|---|---|---|---|
| Balanceado (principal) | HHI | 878 | 649 | 897 | 674 |
| Balanceado (principal) | CR4 | 42,3% | 35,6% | 50,1% | 47,0% |
| Balanceado (principal) | CR1 | 25,7% | 22,3% | 22,8% | 15,9% |
| Balanceado (principal) | Socios equivalentes | 11,4 | 15,4 | 11,1 | 14,8 |
| Final (sensibilidad) | HHI | 1.196 | 787 | 913 | 676 |
| Final (sensibilidad) | CR4 | 51,9% | 35,7% | 45,4% | 42,3% |

- El primer socio es EE.UU. en Argentina, Brasil y Chile; en Uruguay es Argentina [07_concentracion_sectores, columna `socio_principal`].

**Interpretación:** con la medida principal, Argentina es la que concentra la mayor parte de sus ventas en su primer comprador (CR1 25,7%), pero en el HHI queda casi igual que Chile y por encima de Brasil y Uruguay. Con el valor final, Argentina es la más concentrada con los dos índices, pero ahí los socios de Chile y Uruguay salen de un modelo.

**Atención al redactar:** el valor final no es "lo que declara cada país": es lo que declara el país o, si no lo declara, lo que estima OCDE-OMC. Y el balanceado tampoco es "dato informado": combina lo que declaran exportador e importador.

---

## 10. Veredicto de la primera parte de la hipótesis, por vecino
**Material:** tabla de [07_contraste_hipotesis] (columnas `anios_ar_mayor` / `anios`) y la frase de veredicto.

**Años 2015-2024 en que Argentina está más concentrada que el vecino** [07_contraste_hipotesis]:

| Vecino | HHI balanceado | CR4 balanceado | HHI final | CR4 final |
|---|---|---|---|---|
| Brasil | 10 de 10 | 10 de 10 | 10 de 10 | 10 de 10 |
| Uruguay | 10 de 10 | 1 de 10 | 10 de 10 | 10 de 10 |
| Chile | 5 de 10 | 0 de 10 | 10 de 10 | 10 de 10 |

**Veredicto (D-029 y D-027; formular así, sin suavizar ni reforzar):**
- **Frente a Brasil**, la hipótesis se cumple con las dos medidas y los dos índices.
- **Frente a Uruguay**, se cumple con el HHI y no con el CR4 del balanceado. Uruguay reparte casi la mitad entre sus cuatro primeros socios (CR4 47,0%), con tamaños parecidos, y el resto muy disperso.
- **Frente a Chile**, con la medida principal, Argentina no está más concentrada con ningún índice. En el HHI empatan en años (Argentina arriba en 5 de 10; Chile arriba en 2019 y 2021-2024, con 2021 casi igual: 965 contra 951, y 2023-2024 estimados), y Chile queda algo arriba en promedio (897 contra 878). En el CR4, Chile está más concentrado los 10 años (50,1% contra 42,3%). Con el valor final, Argentina está más concentrada que Chile con los dos índices, pero el valor final de Chile es un modelo de gravedad.
- **Síntesis:** frente a Brasil se cumple; frente a Chile y Uruguay, depende de la medida y del índice.

**Interpretación:** el resultado se reporta como sale, sin ajustar la hipótesis (D-027). Elegir la medida que confirma la hipótesis (el valor final) no se puede defender, porque compara un dato declarado con un modelo.

**Para el oral:** "¿por qué no usan el valor final, si ahí se cumple?" → porque en Chile y Uruguay el valor final por socio es 100% estimado; el balanceado mide a los cuatro países de la misma manera (D-029).

---

## 11. La concentración difiere según el sector (y la diversidad de la canasta)
**Material:** `07_g2_socios_equivalentes_sectores.png`. Opcional al costado: `07_g3_rca_sectores.png`.

**Cifras** [07_concentracion_sectores; el coeficiente de variación se calcula sobre la columna `hhi_x10000` de los sectores (sin el total S) que tienen valor los 10 años]:
- Argentina, balanceado: de **2,0 socios equivalentes** en personales, culturales y recreativos (EE.UU. 67,1% del valor) a **18,9** en transporte, empatado con mantenimiento y reparación (18,9; este último con más de la mitad estimado).
- Otros sectores concentrados en Argentina: manufactura sobre insumos de terceros 4,0 (Paraguay 40,5%; 98% del valor con socios estimados, se lee con cautela), financieros 4,4 y propiedad intelectual 4,5 socios equivalentes, estos dos con EE.UU. como primer socio (43,7% y 41,9%).
- Coeficiente de variación del HHI entre sectores, balanceado: Argentina 0,84, Brasil 0,71, Chile 0,65, Uruguay 0,36. Con el valor final, con los mismos sectores que los cocientes de abajo (los que tienen valor los 10 años): Brasil 0,59, Argentina 0,55, Uruguay 0,36, Chile 0,31.
- **Diversidad** (sectores con RCA de Balassa > 1, promedio 2015-2024, contra 199 economías) [07_diversidad]: Argentina 5 de 12 (viajes, telecom. e informática, otros empresariales, personales y culturales, gobierno), más que el 82,8% de las economías; Brasil 4; Chile 3; Uruguay 3.

**Interpretación:**
- "La concentración difiere según el sector" se cumple con las dos medidas. Con el balanceado (12 sectores con los 10 años en los cuatro países), el sector que más reparte tiene entre 3,6 y 9,3 veces los socios equivalentes del más concentrado. Rangos: Argentina 2,0 a 18,9; Brasil 3,2 a 20,1; Chile 2,5 a 16,8; Uruguay 5,8 a 20,9.
- Con el valor final, el cociente es de 3,0 a 7,9 veces, contando solo los sectores con valor los 10 años: Argentina 2,4 a 16,4; Brasil 4,4 a 35,0; Chile 5,5 a 17,2; Uruguay 6,3 a 18,8 (2,96 veces, el más chico). Con el final hay menos sectores: Chile tiene valor en 8, Uruguay en 11 (y construcción, con un solo año, queda afuera de la comparación), y en Argentina manufactura tiene 4 años y construcción 9 [07_concentracion_sectores, columna `anios`].
- "Argentina es la que más varía entre sectores" vale solo con el balanceado; con el valor final, Brasil varía más.
- La diversidad mide la canasta de **sectores**, no de socios: Argentina tiene la canasta más diversa de los cuatro aunque esté entre los más concentrados en socios. No responde la primera parte de la hipótesis.

**Limitaciones:** los sectores marcados con * en el gráfico tienen más de la mitad del valor con socios estimados. En Brasil, toda la apertura por sector es estimada (declara el total por socio, no los sectores). Las 4 ventajas en cero de Chile (manufactura, mantenimiento, construcción y gobierno) son faltantes completados y no se interpretan.

---

## 12. Método de inferencia: ANOVA entre sectores. Pregunta, hipótesis y supuestos
**Material:** `08_g2_qq_residuos.png` y las filas de supuestos de [08_tests].

**Pregunta:** ¿el valor que exporta un país típico difiere entre los 12 sectores de servicios? Responde la tercera parte de la hipótesis.

**Por qué ANOVA:** variable numérica (valor exportado) contra una categórica con 12 grupos (sector). Es lo que sugirió el docente.

**Base** (D-026, D-028): 200 economías presentes los diez años × 12 sectores, una observación por país y sector con el promedio anual 2015-2024 del valor final. Así cada país aparece una vez por sector y no diez. El ANOVA usa las 2.082 celdas positivas sobre log(valor); en logaritmos se comparan medias geométricas, el valor de un "país típico" [08_descriptivos_sectores].

**Hipótesis:**
- H0: el valor medio (en log) que exporta un país típico es igual en los 12 sectores.
- H1: al menos un sector difiere.

**Supuestos** [08_tests]:
- Normalidad de los residuos: Shapiro-Wilk W = 0,99, p < 0,001; asimetría −0,31. El QQ-plot sigue a la normal en el centro y se aparta en las colas. Shapiro rechaza en buena parte por el tamaño de la muestra (n = 2.082): con tantas observaciones, cualquier desvío chico es "significativo".
- Homogeneidad de varianzas: Levene (centrado en la mediana) F = 13,89 (11 y 2.070 gl), p < 0,001. Cociente entre el desvío máximo y el mínimo: 1,90, debajo de la regla de 2 de la clase 10.
- Independencia: el mismo país aparece en hasta 12 sectores (limitación, diapositiva 13).

**Qué hicimos ante los supuestos (criterio fijado antes de ver los resultados, D-028):** si el cociente supera 2 o Levene rechaza, el test principal es Welch y los pares se comparan con Games-Howell. Levene rechazó → Welch y Games-Howell. Además, Kruskal-Wallis (no paramétrico) y, por la independencia, un ANOVA con el país como bloque y el test de Friedman.

---

## 13. Resultados del ANOVA y robustez
**Material:** `08_g1_medias_sectores.png` (principal); tabla resumida de [08_tests]; `08_g3_pares_sectores.png` al anexo si no entra.

**Cifras** [08_tests]:

| Test | Estadístico | gl | p-valor | Efecto |
|---|---|---|---|---|
| ANOVA de un factor | F = 38,87 | 11 y 2.070 | < 0,001 | eta² = 0,17 |
| ANOVA de Welch | F = 43,82 | 11 y 790,6 | < 0,001 | — |
| Kruskal-Wallis con ceros | 513,84 | 11 | < 0,001 | epsilon² = 0,21 |
| Kruskal-Wallis sin ceros | 348,48 | 11 | < 0,001 | epsilon² = 0,17 |
| ANOVA con el país como bloque | F = 154,32 | 11 y 1.872 | < 0,001 | eta² = 0,20 (sobre la SC total) |
| Friedman (con ceros) | chi² = 1.220,84 | 11 | < 0,001 | W de Kendall = 0,55 |

- Medias geométricas (millones de USD por año, promedio 2015-2024) [08_descriptivos_sectores]: viajes 919,6 (IC 95%: 665,9 a 1.269,9), transporte 451,0, otros empresariales 319,4, telecom. e informática 184,0 → grupo alto. Las más bajas: mantenimiento 11,9 y propiedad intelectual 9,8. En un país típico, viajes supera 94 veces a propiedad intelectual (919,55 / 9,82 = 93,6).
- Comparaciones de a pares (Games-Howell): 41 de 66 pares difieren al 5% [08_comparaciones_pares]. Con Tukey serían 42: la conclusión no depende del método.
- Tres bloques: los cuatro sectores grandes, que no difieren entre sí salvo viajes, que sí supera a otros empresariales y a telecom. e informática; uno medio (gobierno, financieros, construcción, manufactura y seguros), sin diferencias entre ellos; y uno bajo (personales, mantenimiento y propiedad intelectual). El medio y el bajo se solapan: solo gobierno, financieros y construcción superan a parte del bloque bajo (D-028).

**Interpretación:** se rechaza H0 con todos los métodos: el valor exportado difiere según el sector, y la tercera parte de la hipótesis se cumple. El sector explica el 17% de la variabilidad del log del valor (eta²); el 83% restante es variación dentro de cada sector, sobre todo entre países de distinto tamaño. La diferencia también es relevante en términos económicos, no solo estadística: en un país típico, viajes genera unas 94 veces lo que propiedad intelectual.
- Con el país como bloque, el país explica el 57% de la variabilidad y el sector, el 20,3% de la SC total: la diferencia entre sectores no viene de que haya países grandes y chicos. El Friedman (W = 0,55) muestra lo mismo por rangos: los países ordenan sus sectores de forma parecida.
- No comparar el eta² parcial del modelo con bloque (0,48) con el 0,17: tiene otro denominador (D-028).

**Limitaciones:**
- **Independencia:** las celdas de un mismo país no son independientes. Como el país está cruzado con el sector, ignorarlo infla el error: el ANOVA de un factor es conservador, no optimista (la F sube de 38,9 a 154,3 al descontar el país).
- Los residuos del modelo con bloque cumplen peor los supuestos (Shapiro W = 0,96, asimetría −0,84; cociente de desvíos 3,01); por eso se agregó el Friedman.
- El modelo con bloque es aditivo: con una observación por país y sector, la interacción no se puede estimar.
- USD corrientes, sin deflactar. El valor final incluye estimaciones de OCDE-OMC en el 17,8% de los años.
- Rechazar H0 describe una asociación entre sector y valor, no una causa.

---

## 14. Síntesis y próximos pasos
**Material:** tabla de tres filas, una por parte de la hipótesis.

| Parte de la hipótesis | Resultado | Método |
|---|---|---|
| Argentina se concentra en menos socios que sus vecinos | Frente a Brasil se cumple; frente a Chile y Uruguay, depende de la medida y del índice | CR, HHI (cuantitativo) |
| La concentración difiere según el sector | Se cumple con las dos medidas (Argentina, de 2,0 a 18,9 socios equivalentes) | CR, HHI por sector |
| El valor exportado difiere según el sector | Se cumple con todos los métodos (F = 38,9; eta² = 0,17) | ANOVA y robustez (inferencia) |

**Cómo se relacionan los dos métodos:** son complementarios y responden partes distintas de la hipótesis. El ANOVA muestra que los sectores difieren en **cuánto** exporta un país típico; la concentración, que también difieren en **a cuántos socios** les venden. Con estos resultados no se puede afirmar que los sectores más chicos sean los más concentrados: en Argentina hay sectores grandes que reparten mucho (transporte, viajes) y otros que están en la mitad concentrada (telecom. e informática 8,1 y otros empresariales 9,1 socios equivalentes), y sectores chicos que reparten mucho (mantenimiento). Es una pregunta para la entrega final, no una conclusión.

**Veredicto global:** la hipótesis se **matiza**: se confirma frente a Brasil y en las dos partes sectoriales, y frente a Chile y Uruguay depende de la medida y del índice.

**Próximos pasos (entrega final):**
- Relacionar la concentración por socio con el tamaño del sector (¿los sectores chicos están más concentrados?).
- Retomar el test pareado de crecimiento entre países que quedó de la Instancia 1.
- Evaluar el ANOVA en valores reales o relativos al tamaño de cada país.
- Revisar si el resultado frente a Chile cambia sin los años estimados (2023-2024).

---

## Anexo (opcional, no cuenta en las 10-15)
- `08_g3_pares_sectores.png`: los 41 pares significativos.
- [07_principales_socios]: los cinco primeros socios de cada país, con las dos medidas.
- [07_sensibilidad_periodo]: solo vale para Brasil, 2010-2014 contra 2015-2024: HHI 781 → 649 con el balanceado y 882 → 787 con el final. Para Argentina no sirve: 2005-2014 es retroproyección.
- [08_posicion_paises]: percentil de cada país en cada sector. Brasil, entre el 56 y el 91 (56,28 a 91,46); Argentina, del 39 (construcción) al 84 (personales y culturales).

---

## Salvedades que tienen que aparecer en el PDF
- Millones de USD corrientes, sin deflactar.
- Chile y Uruguay: distribución por socio 100% estimada por OCDE-OMC; Chile 2023-2024 estimado.
- El valor final no es "lo que declara cada país", y el balanceado no es "dato informado".
- Descriptivo, no causal.
- Toda tabla y gráfico con una frase que lo interprete (advertencia del docente, clase 08).

---

## Verificación de las cifras
Cada cifra del guion se cotejó contra la tabla que se cita, leída con `readr::read_csv2()`. Las que no están directamente en una tabla:
- **Rangos de socios equivalentes por país y medida** (diapositiva 11): mínimo y máximo de `socios_equivalentes` en [07_concentracion_sectores], sin el total S. Balanceado: los 12 sectores, todos con `anios` = 10; cocientes máx./mín. de 3,6 (Uruguay) a 9,3 (Argentina). Final: solo los sectores con `anios` = 10 (Chile 8, Uruguay 10 sin construcción, Argentina 10 sin manufactura ni construcción); cocientes de 2,96 (Uruguay, 18,78 / 6,34) a 7,9 (Brasil).
- **Coeficiente de variación del HHI entre sectores** (AR / BR / CL / UY: balanceado 0,84 / 0,71 / 0,65 / 0,36; final 0,55 / 0,59 / 0,31 / 0,36): calculado como `sd(hhi_x10000) / mean(hhi_x10000)` en [07_concentracion_sectores], sin el total S y solo con los sectores con `anios` = 10. Con el balanceado son los 12 sectores en los cuatro países; con el final, Argentina 10, Brasil 12, Chile 8 y Uruguay 10. Si se incluyeran los sectores con menos años, Uruguay daría 0,42 (por construcción, con un solo año); el orden entre países no cambia (corregido por QA-005b, m-a).
- **HHI de 2021** (Chile 965, Argentina 951) y **años en que Chile supera a Argentina** (2019, 2021-2024): [07_concentracion_anual], ítem S, balanceado.
- **Tukey = 42 pares:** lo imprime `script/08_anova_sectores.R` en consola ("Con Tukey serían 42 pares"); no se guarda en una tabla.
- **Composición de los bloques de Games-Howell y el 57% / 20,3% del modelo con bloque:** D-028, auditado en QA-004b; las cifras salen de la consola del script 08.
- **Brasil 2015-2024 estimado entre 29,7% y 37,3% y Argentina como máximo 0,4%:** [06_diagnostico_resumen], sin ROW, como el gráfico 06_g1. [05_origen_bilateral] da 30,0% a 37,6% porque incluye a ROW; de ahí sale solo la cantidad de socios con dato propio de Argentina (141 a 167).
- **Redondeos que parecen no coincidir con la tabla:** Chile figura con 11,15 socios equivalentes en [07_comparacion_medidas], pero el valor exacto es 10.000 / 897,20 = 11,146, es decir 11,1 (como en D-027 y en el gráfico 07_g2). El CR4 final de Brasil figura 35,75 y se informa 35,7, como en D-027.
- **Chequeo automático:** un script temporal (fuera del proyecto) comparó 23 grupos de cifras del guion con las tablas; todas coinciden, salvo los redondeos de arriba.
