# Revisión de la PPT del grupo contra la consigna (Instancia 1)
Archivo revisado: `Trabajo_Practico_BaTiS_EDA.pptx` (11 diapositivas, versión del 21/09). Consigna: `consignas_instancia_1.md` + checklist del docente (clase 08, sección 9).

## Lo que ya está bien
- 11 diapositivas, dentro del rango de 8 a 12.
- Recorrido ordenado: base → variables → exploración → hallazgos → preguntas.
- Unidad de observación bien identificada (país × categoría × año, exportaciones al mundo).
- 5 hallazgos y 2 preguntas, como pide la consigna.
- La pregunta sobre inflación y PBI apunta bien a la Unidad 3.

## Hay que corregir sí o sí (con cualquiera de las dos medidas)
1. **Diap. 3, variables:** muestra 6 de las 12 variables de la base y no tiene columna de nulos.
   - Dice "ningún valor nulo", pero eso vale solo para las 6 elegidas. `Reported_value` tiene 103 nulos en la base de trabajo (96,5% en la base completa).
   - La consigna pide tipo y nulos por variable, y es uno de los criterios de evaluación. El docente pidió usar todas las variables con valores.
   - Reemplazar por la tabla de 12 variables [`output/tablas/02_tabla_variables.csv`].
2. **Diap. 2, la base:** falta la dimensión de la base completa (49.604.340 filas × 12 variables) y la periodicidad (datos anuales, versión de diciembre de 2025). La consigna pregunta cuántas observaciones y cuántas variables tiene la base.
3. **Diap. 5, descriptivos:** el título dice "dispersión", pero la tabla no tiene ninguna medida de dispersión. Faltan el desvío y el coeficiente de variación [`03_descriptivos_nivel`].
   - La frase "Brasil combina el mayor nivel y la mayor dispersión" vale solo en valores absolutos. En términos relativos (coeficiente de variación), el más disperso es Uruguay.
   - El boxplot de niveles mezcla la tendencia con la dispersión. Conviene reemplazarlo por el de tasas (G4).
4. **Chile 2023–2024 son estimaciones de OCDE-OMC**, y eso no aparece en ninguna diapositiva. Afecta tres afirmaciones:
   - Diap. 6: "Chile… impulsado por el salto de 2022–2024". Ese salto está en los años estimados.
   - Diap. 6 y hallazgo 2: "Argentina, el menor crecimiento relativo del grupo". Con el valor balanceado vale solo si se incluyen los años estimados de Chile. En 2005–2022, Argentina (4,8% anual) crece más que Chile (4,3%) [`03_robustez_crecimiento`].
   - Hallazgo 3: "Chile… la recuperación más fuerte (+114,9%)". Se mide contra 2020, que es un piso (efecto base), y 2024 es estimado. Hay que medirla contra 2019 [`03_pandemia`].
5. **Falta el histograma**, que según recuerda Timothy pidió el docente: usar G3 (tasas de variación anual).
6. **Diap. 4, 7, 8 y 9 tienen gráfico sin frase de interpretación.** La primera advertencia del docente es que ninguna tabla ni gráfico va sin una frase que lo interprete.
7. **Portada:** faltan los integrantes, la materia y la fecha.
8. **Pregunta 1:** "¿qué factores explican…?" tiene formato causal, y el TP no es causal. Mejor: "¿La especialización en servicios de conocimiento es una ventaja comparativa revelada?" (índice de Balassa, Instancia 2).

## Depende de la medida que elija el grupo
- **Con el valor final (D-015, recomendado):** cambian las cifras de las diap. 4 a 10.
  - El hallazgo 5 ("viajes… pese a seguir siendo la principal categoría") pasa a ser falso: en 2024, otros servicios empresariales (34,6%) supera a viajes (29,0%).
  - El hallazgo 3 cambia: la mayor caída de 2020 es la de Argentina (−35,9%), no la de Chile.
  - En el mismo hallazgo 3, con la recuperación medida contra 2019 (punto 4), la más fuerte es la de Brasil (+46,8%), no la de Chile (+38,8%) [`03_pandemia`].
  - El hallazgo 1 ("Brasil exporta casi tres veces más servicios que Argentina o Chile") deja de valer. En promedio 2005–2024, Brasil exporta 2,56 veces lo de Argentina y 3,59 veces lo de Chile [`03_descriptivos_nivel`].
  - Todas las cifras nuevas están en `insumos_ppt_instancia1.md`.
- **Qué afirmaciones cambian según la medida, con las cifras de cada una:** `comparacion_medidas.md` (QA-003).
- **Con el valor balanceado:** las cifras actuales sirven, pero hay que agregar la salvedad de la brecha contra lo que informa cada país. Argentina queda en promedio 11,7% por debajo de su cifra oficial y Chile hasta 57% por encima (gráfico G7). Además, hay que sacar las afirmaciones del punto 4.
