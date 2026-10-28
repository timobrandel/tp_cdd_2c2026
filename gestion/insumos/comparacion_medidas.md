# Comparación de las dos medidas: ¿qué hallazgos se mantienen?

- **Origen:** `script/04_comparacion_medidas.R` (rama `comparacion-medidas`, D-019). Tablas `output/tablas/04_*` y gráficos `output/graficos/04_g1` y `04_g2`. Salvo que se indique otra tabla entre corchetes, las cifras salen de `04_resumen_hallazgos`.
- **Estado:** auditado en QA-003 (APROBADO CON OBSERVACIONES). Esta versión incorpora sus correcciones; falta la validación de Timothy.
- **Unidades:** millones de USD corrientes. Chile 2023–2024 son estimaciones de OCDE-OMC con las dos medidas.

## Resultado
El guion de la PPT (`insumos_ppt_instancia1.md`) tiene 20 afirmaciones que se pueden verificar con los datos. Con el balanceado se cumplen 9. **La medida no es un detalle: cambia 11 de las 20 afirmaciones.**

Que con el valor final se cumplan las 20 no es un argumento a favor del final: el guion se escribió con esa medida, así que es por construcción. La medida se elige por lo que mide (ver "Qué implica para la decisión del grupo").

## Se mantienen con las dos medidas (9)
Orden de las cifras: Argentina · Brasil · Chile · Uruguay. "pp" = puntos porcentuales.

| # | Afirmación | Valor final | Valor balanceado |
|---|---|---|---|
| 1.1 | Otros servicios empresariales gana peso en los 4 países (2005–2024) | +9,8 · +0,6 · +13,6 · +23,7 pp | +7,7 · +4,0 · +6,9 · +10,5 pp |
| 1.2 | Telecom., informática e información gana peso en los 4 | +10,1 · +10,6 · +2,3 · +11,8 pp | +5,2 · +5,4 · +1,3 · +7,6 pp |
| 1.3 | Transporte pierde peso en los 4 | −7,4 · −2,1 · −31,1 · −24,4 pp | −5,8 · −2,4 · −15,8 · −12,0 pp |
| 1.4 | Viajes pierde peso en Argentina, Brasil y Uruguay; en Chile gana | −13,3 · −11,0 · +10,8 · −13,8 pp | −9,2 · −8,4 · +5,6 · −7,9 pp |
| 1.6 | Uruguay tuvo la mayor transformación hacia conocimiento | Uruguay +35,6 pp | Uruguay +18,2 pp |
| 1.8 | La canasta se diversificó en los 4 (las 3 categorías más grandes pesan menos) | −7,3 · −12,5 · −6,7 · −10,0 pp | −7,3 · −6,8 · −3,4 · −9,3 pp |
| 3.4 | El desvío de Argentina no es el más alto: Uruguay y Chile oscilan más | 17,6 · 13,8 · 18,0 · 19,0 | 14,8 · 13,8 · 15,4 · 15,9 |
| 4.2 | Argentina tuvo la menor recuperación (2024 contra 2019) | +15,7 · +46,8 · +38,8 · +25,8% | +16,8 · +33,7 · +41,2 · +39,8% |
| D.1 | Los valores por categoría tienen una distribución muy asimétrica a la derecha | media 1.218,6 · mediana 228,4 | media 1.220,6 · mediana 243,0 |

## Cambian con el balanceado (11)
| # | Afirmación | Valor final | Valor balanceado |
|---|---|---|---|
| 1.5 | En Argentina, conocimiento es más de la mitad de lo que exporta (2024) | 51,0% | 36,5% |
| 1.7 | En Argentina, otros servicios empresariales ya supera a viajes (2024) | Otros servicios empresariales, 34,6% | Viajes, 33,6% |
| 2.1 | Argentina es tercera en crecimiento 2005–2024, detrás de Uruguay y Brasil | UY 9,2 > BR 6,5 > AR 5,3 > CL 3,0% anual | UY 7,3 > BR 6,3 > CL 5,6 > AR 5,2%: Argentina queda última |
| 2.2 | El orden no cambia si se mira solo 2005–2022 | Mismo orden | En 2005–2022, Argentina (4,8%) supera a Chile (4,3%). El orden se invierte al sumar 2023 y 2024, que en Chile son estimados |
| 2.3 | Desde 2006, Argentina exporta más que Chile todos los años | 19 de 19 años (de +7,4% a +74,9%) | 14 de 19 años (de −12,9% a +9,3%). Las dos brechas en contra más grandes son de 2023 (−6,2%) y 2024 (−12,9%), estimados de Chile; en 2006–2022, 14 de 17 años (de −3,1% a +9,3%) [04_argentina_vs_chile] |
| 2.4 | Chile tocó su máximo en 2011 y no lo volvió a superar | 2011 | 2024. No es solo por los años estimados: con el balanceado, Chile supera su nivel de 2011 (11.719) en 2012, 2017, 2018, 2019 y 2022, que son años informados; el máximo de 2005–2022 es el de 2022 (12.761) [04_total_por_anio] |
| 3.1 | Argentina tiene la mediana de crecimiento anual más baja | Argentina, 1,6% | La más baja es la de Uruguay (2,1%); Argentina, 4,2% |
| 3.2 | Argentina es el país con más años de caída | Argentina 8, Chile 7, Brasil 6, Uruguay 5 | Los cuatro, 6 años |
| 3.3 | Los únicos años atípicos son de Argentina: 2020 y 2022 | Solo Argentina 2020 y 2022 | Además, Chile 2020 y Uruguay 2022 |
| 4.1 | Argentina tuvo la mayor caída en 2020 | Argentina −35,9% (Chile −34,4%) | Chile −34,3% (Argentina −31,8%) |
| D.2 | Hay 150 valores en cero en las 960 filas de categorías | 150 | 0: el balanceado no tiene ceros |

Con las dos medidas, en 2005–2022 el orden de crecimiento es el mismo: Uruguay, Brasil, Argentina, Chile [04_crecimiento].

## Dos afirmaciones de la PPT del grupo que también dependen de la medida
La PPT que se entrega hoy (`Trabajo_Practico_BaTiS_EDA.pptx`, hecha con el balanceado) tiene dos afirmaciones que no están en el guion:

| Afirmación de la PPT del grupo | Valor final | Valor balanceado |
|---|---|---|
| Hallazgo 1: "Brasil exporta casi tres veces más servicios que Argentina o Chile" (media 2005–2024) [04_descriptivos_nivel] | 2,56 veces lo de Argentina y 3,59 veces lo de Chile: "casi tres veces" no describe a ninguno | 2,87 y 2,89 veces: se cumple |
| Hallazgo 3: "Chile tuvo la recuperación más fuerte" (2024 contra 2019, como pide la revisión) [04_pandemia] | No: la más fuerte es la de Brasil (+46,8%); Chile queda segundo (+38,8%) | Sí: Chile (+41,2%); segundo, Uruguay (+39,8%) |

**Si el grupo mantiene el final**, esas dos frases pasan a ser: "Brasil exporta en promedio 2,6 veces lo que Argentina y 3,6 veces lo que Chile" y "la recuperación más fuerte respecto de 2019 es la de Brasil". Chile 2024 es estimado con las dos medidas.

## Por qué cambian
1. **El balanceado no es la cifra que informa cada país: es una conciliación.**
   - Combina lo que informa el exportador con lo que declaran sus socios como importaciones (un promedio ponderado de los dos), para que los flujos bilaterales cierren.
   - Por eso cambia el nivel: Argentina queda por debajo de lo que informa todos los años, entre −2,8% y −18,5% [04_total_por_anio], y deja de ser más grande que Chile (2.3).
   - También cambia la composición. En 2024, en los cuatro países, con el balanceado pesan menos servicios empresariales e informática y más transporte y viajes [04_composicion, gráfico 04_g2]. De ahí caen las dos afirmaciones sobre la composición de Argentina en 2024 (1.5 y 1.7).
2. **La corrección cambia en el tiempo, y ese cambio se compone con el crecimiento.**
   - En Chile, el balanceado pasa de 5,7% por debajo del valor final en 2005 a 57,3% por encima en 2021, y queda más de 18% arriba todos los años desde 2014 [04_total_por_anio].
   - El crecimiento del balanceado es el de lo que informa Chile multiplicado por el de la corrección. Entre 2005 y 2024: 2,80 = 1,76 × 1,59 [04_crecimiento, 04_total_por_anio].
   - Por eso, con el balanceado, Chile crece 5,6% anual en vez de 3,0%, supera varias veces su nivel de 2011 (también en años informados) y supera a Argentina en 2005–2024 (2.1, 2.2 y 2.4).
   - En Uruguay, la corrección va al revés: pasa de +44,4% en 2006 a −15,1% en 2019. Eso le baja la mediana de crecimiento (de 4,6% a 2,1%) y le suma un año de caída. En Argentina, la mediana sube de 1,6% a 4,2%. Así caen 3.1 y 3.2 [04_volatilidad].
   - Con los datos de la base no se puede saber cuál de las dos cifras está más cerca de la realidad. Sí se sabe que el crecimiento del balanceado mezcla dos cosas.
3. **Los atípicos y la caída de 2020 dependen de detalles de la regla o de un solo año.**
   - 3.3: con el balanceado hay más atípicos, no menos: 4 (Argentina 2020 y 2022, Chile 2020 y Uruguay 2022) contra 2 [04_volatilidad]. La regla del boxplot mide la dispersión de cada país con su rango intercuartil, que cambia con la medida: si la caja se achica, quedan afuera valores menos extremos.
   - 4.1: es un solo año. La caída de Chile en 2020 es casi igual con las dos medidas (−34,4% y −34,3%). La de Argentina se achica (de −35,9% a −31,8%) porque su corrección fue menor en 2020 (−5,8%) que en 2019 (−11,4%) [04_pandemia, 04_total_por_anio].
   - Con el balanceado, el desvío de las tasas baja en tres de los cuatro países: Argentina de 17,6 a 14,8, Chile de 18,0 a 15,4 y Uruguay de 19,0 a 15,9. En Brasil queda en 13,8 [04_volatilidad]. Pero eso no explica los cambios de 3.1 a 3.3: Uruguay oscila menos y aun así cae más seguido, y hay más atípicos, no menos.
4. **El balanceado no tiene ceros.** OCDE-OMC asigna valores positivos incluso a las categorías que Chile no informa, que con el valor final son ceros [04_distribucion] (D.2).

## Qué implica para la decisión del grupo
- **Lo robusto, que se puede afirmar con cualquiera de las dos medidas:**
  - la dirección del cambio de la composición 2005–2024: conocimiento gana peso, transporte pierde, viajes pierde en Argentina, Brasil y Uruguay y gana en Chile, y Uruguay tiene el giro más grande (1.1 a 1.4 y 1.6);
  - la diversificación de las canastas (1.8);
  - que Uruguay y Chile oscilan más que Argentina (3.4);
  - la recuperación pospandemia más débil de Argentina (4.2).
- **Lo que depende de la medida:**
  - el nivel de la composición de Argentina en 2024: si conocimiento supera la mitad (1.5) y cuál es la categoría principal (1.7);
  - el tamaño de Argentina frente a Chile (2.3);
  - el orden de crecimiento cuando entran 2023 y 2024 (2.1 y 2.2), y el estancamiento de Chile (2.4);
  - la frecuencia de caídas, la mediana y los atípicos de Argentina (3.1 a 3.3);
  - cuál fue la mayor caída de 2020 (4.1);
  - las dos afirmaciones de la PPT del grupo: Brasil "casi tres veces" y la recuperación más fuerte.
- **Con el final, varias afirmaciones se cumplen por poco.** No conviene presentarlas como contundentes:
  - 1.5: conocimiento de Argentina en 2024 = 50,97%, apenas por encima del 50% [04_conocimiento];
  - 3.4: el desvío de Chile (17,95) supera al de Argentina (17,56) por 0,4 [04_volatilidad];
  - 3.2: Argentina tiene 8 años de caída y Chile, 7;
  - 4.1: Argentina cae 35,9% y Chile, 34,4%;
  - 2.4: Chile 2024 (estimado) está en el 98% de su máximo de 2011 [04_total_por_anio];
  - 1.1: en Brasil, otros servicios empresariales gana apenas 0,6 pp.
- **La medida se elige por lo que mide, no por el resultado que da.** La pregunta del TP es cuánto y qué exporta cada país. Eso es la balanza de pagos que informa cada país, el valor final (D-015). El balanceado está pensado para que los flujos bilaterales cierren, y sus correcciones cambian mucho en el tiempo (punto 2).
- **Recomendación de Claude:** mantener D-015 y sumar esta comparación como chequeo de robustez. Frase para el oral: "Elegimos la medida por su definición. Con la otra se mantiene la dirección del cambio en la composición, pero cambian el nivel de la composición de Argentina en 2024, su tamaño frente a Chile y su perfil de caídas".
- **Si el grupo elige el balanceado, no alcanza con cambiar cifras:**
  - hay que reescribir las 11 afirmaciones de la segunda tabla;
  - también los pasajes del guion que justifican el final: la diapositiva 4 ("`Final_value` es la variable principal"), la 5 ("Por eso usamos el valor que informa cada país") y las salvedades;
  - la tabla de variables (`02_tabla_variables`) marca a `Final_value` como variable principal: hay que cambiar esa etiqueta en `script/02_estructura_variables.R` y regenerar la tabla;
  - las cifras con el balanceado para cada diapositiva están en las tablas del 04:
    - diap. 4: `04_distribucion`;
    - diap. 6: `04_descriptivos_nivel` y `04_argentina_vs_chile`;
    - diap. 7: `04_crecimiento`;
    - diap. 8 y 9: `04_volatilidad` y `04_pandemia`;
    - diap. 10: `04_composicion`, `04_conocimiento` y `04_concentracion`;
  - los gráficos 03_g1 a 03_g6 se regeneran cambiando `variable_principal` en el 03. QA-003 lo probó en una copia: corre sin errores, y `03_ceros_detalle` queda vacía porque no hay ceros.

## Contenido opcional para la PPT (lo redacta el grupo, D-007)
Una línea en la diapositiva 5 o una diapositiva de robustez (la consigna sugiere de 8 a 12 diapositivas). Contenido: con el valor balanceado se mantienen 9 de las 20 afirmaciones del guion. Se sostiene la dirección del cambio en la composición; cambian el nivel de la composición de Argentina en 2024, su tamaño frente a Chile y su perfil de caídas. Gráfico sugerido: 04_g2.

## Una frase por tabla y gráfico
- **04_total_por_anio:** total de servicios de cada país con las dos medidas y la diferencia entre ambas, año por año.
  - Argentina queda por debajo con el balanceado los 20 años.
  - En Brasil, las medidas difieren menos de 6%.
  - Uruguay queda por encima hasta 2011 y por debajo desde 2012.
  - La tasa de variación de 2005 queda vacía (8 celdas, una por país y medida) porque no hay año anterior.
- **04_descriptivos_nivel:** con el valor final, el tamaño medio de Argentina es 40% mayor que el de Chile (12.702 contra 9.051 millones de USD); con el balanceado, son casi iguales (11.179 y 11.091).
- **04_argentina_vs_chile:** con el valor final, Argentina supera a Chile todos los años desde 2006. Con el balanceado, en 14 de 19 años y nunca por más de 9,3%; las brechas en contra más grandes, 2023 y 2024, son años estimados de Chile.
- **04_crecimiento:** Uruguay y Brasil encabezan con las dos medidas. El orden entre Argentina y Chile depende de la medida y de si se incluyen 2023 y 2024, que en Chile son estimados.
- **04_volatilidad:** con el balanceado, el desvío baja en Argentina, Chile y Uruguay; los cuatro países tienen 6 años de caída, y hay 4 años atípicos en lugar de 2.
- **04_pandemia:** con las dos medidas, Argentina es la que menos se recuperó respecto de 2019. La mayor caída de 2020 es la de Argentina con el valor final y la de Chile con el balanceado; la recuperación más fuerte es la de Brasil con el final y la de Chile con el balanceado.
- **04_composicion:** en 36 de los 48 pares país-categoría, el cambio 2005–2024 va en la misma dirección con las dos medidas. De los otros 12:
  - 5 cambian de signo: manufactura en Brasil; seguros y personales en Argentina; financieros y propiedad intelectual en Uruguay. Sus cambios son menores a 1 pp, salvo propiedad intelectual en Uruguay (+1,6 pp con el final).
  - Los 7 restantes son categorías que valen cero con el final en 2005 y en 2024.
- **04_conocimiento:** conocimiento gana peso en los cuatro países con las dos medidas. En 2024, su participación es menor con el balanceado en los cuatro (Argentina: 51,0% contra 36,5%).
- **04_concentracion:** la canasta se diversifica en los cuatro países con las dos medidas. La categoría principal de Argentina en 2024 es otros servicios empresariales con el valor final y viajes con el balanceado.
- **04_distribucion:** con las dos medidas, la distribución es muy asimétrica a la derecha (la media es unas cinco veces la mediana). El balanceado no tiene ceros.
- **04_resumen_hallazgos:** de las 20 afirmaciones del guion, 9 se mantienen con el balanceado. Con el final se cumplen las 20, por construcción.
- **04_g1:** con el balanceado, Argentina queda por debajo del valor final todos los años y Chile muy por encima desde 2014; en Brasil, las dos líneas casi coinciden.
- **04_g2:** en 2024, en los cuatro países, el balanceado les da menos peso a servicios empresariales e informática y más a transporte y viajes.
