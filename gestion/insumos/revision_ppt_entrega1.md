# Revisión de "Presentation entrega 1.pptx" contra las cifras auditadas
21/09/2026, 21:15 hora argentina.

**Estado (21:30): aplicada.** Todo lo de esta revisión se aplicó en el archivo del grupo (D-021): obligatorias, recomendadas, lo recuperado de la original y la diapositiva de robustez. Además, se corrigió el gráfico estirado de la diapositiva de composición. Respaldo de la versión anterior: `Presentation entrega 1 - respaldo del grupo 21.13.pptx`. Desde ahora, la numeración es de 12 diapositivas: robustez es la 11 y hallazgos, la 12.
- **Versión revisada:** la guardada a las 21:13, de 11 diapositivas. Los números de diapositiva son los de ese archivo.
- **Cifras de referencia:** outputs de los scripts 01 a 04, auditados en QA-002 y QA-003. Cada corrección cita su tabla entre corchetes.

## Veredicto
La PPT está bien armada y usa el valor final (D-015). Las cifras de las diapositivas 2 a 10 coinciden con los outputs; la 11 tiene dos errores (obligatorias 1 y 2). Los 7 gráficos son los auditados: idénticos, byte a byte, a los de `output/graficos/`. Además ya resolvió varias correcciones de `revision_ppt_grupo.md`: la dimensión de la base, el histograma, la salvedad de Chile en los gráficos, la pregunta no causal y los integrantes en la portada.

**Antes de entregar hay 6 correcciones obligatorias:** dos errores en los hallazgos, y cuatro faltantes que tocan criterios de evaluación o advertencias del docente.

## Obligatorias
1. **Diap. 11, "Brasil domina en escala": la cifra está mal.** "Casi cuatro veces Uruguay" es falso: la mediana de Brasil (33.156) es 6,7 veces la de Uruguay (4.933). La que es 3,7 veces es la de Chile (8.897) [03_descriptivos_nivel].
   → "Su mediana anual es USD 33.156 M: más del doble que Argentina y casi cuatro veces Chile."
2. **Diap. 11, "Argentina creció más que Chile, pero menos que Uruguay": está incompleta.** Brasil también creció más que Argentina (+228% contra +165%) [03_crecimiento].
   → Título: "Argentina creció más que Chile, pero menos que Uruguay y Brasil".
   → Texto: "+165% nominal (5,3% anual): tercera de cuatro, detrás de Uruguay (+430%) y Brasil (+228%)".
3. **Diap. 4, variables: falta la descripción y los nulos de cada variable.** Es un criterio de evaluación: "descripción, tipo y nulos". La tabla agrupa bien las 12 variables, pero no describe ninguna y solo da los nulos de `Reported_value`.
   - Mínimo: una columna "Nulos" con 0 en todas, salvo `Reported_value`: 103 de 1.040 (9,9%). Debajo: "`Reported_value` está vacía cuando el valor no fue informado por el país sino estimado; en la base completa, el 96,5% de las filas" [02_tabla_variables].
   - Ideal: sumar la columna "Descripción" como en la PPT original (diap. 3), con los textos de `02_tabla_variables`.
4. **Faltan medidas de dispersión.** Afectan al criterio "análisis exploratorio" y ya estaban marcadas en el punto 3 de la revisión anterior.
   - **Diap. 8 (volatilidad):** las tarjetas tienen media, mediana y caídas, pero no el desvío, que es la medida de volatilidad. Agregar "desvío 17,6 pp" (Argentina), 13,8 (Brasil), 18,0 (Chile) y 19,0 (Uruguay) [03_descriptivos_tasas]. Sumar a la lectura: "…y su desvío no es el más alto: Uruguay y Chile oscilan más".
   - **Diap. 6 (nivel):** agregar el coeficiente de variación junto a cada mediana: Argentina 0,23 · Brasil 0,26 · Chile 0,20 · Uruguay 0,41 [03_descriptivos_nivel]. Uruguay es el más disperso en términos relativos, por su crecimiento.
5. **Hay gráficos sin frase que los interprete.** Es la advertencia 1 del docente.
   - **Diap. 5 (brecha):** el gráfico no tiene lectura. → "Lectura: la brecha no es pareja. Argentina queda siempre por debajo con el balanceado (entre −2,8% y −18,5%), Chile llega a +57% y Uruguay pasa de +44% a valores negativos desde 2012. En Argentina, Brasil y Uruguay las dos medidas se mueven juntas (correlación 0,98–0,99); en Chile, no (0,67)" [03_brecha_resumen].
   - **Diap. 6 (evolución):** la lectura actual ("la tendencia completa se interpreta en el gráfico") no interpreta el gráfico. → "Lectura: Brasil lidera en escala: su mediana es 2,5 veces la de Argentina. Desde 2006, Argentina supera a Chile (45,8% más en 2024). Los cuatro caen en 2020 y vuelven a crecer" [03_descriptivos_nivel, 03_argentina_vs_chile].
   - **Diap. 9 (atípicos):** falta decir que los atípicos se explican y no se borran (advertencia 2). → "Los años atípicos coinciden con el shock de la pandemia y su rebote: se explican, no se eliminan. La recuperación se mide contra 2019, el nivel previo al shock."
6. **Diap. 1 (portada): falta la fecha** (revisión anterior, punto 7). Conviene también "FCE-UBA" y el rótulo de la entrega, como en la original: "Instancia 1: análisis exploratorio de datos · 21 de septiembre de 2026".

## Recomendadas
7. **Diap. 5, dos frases que no se pueden defender en el oral:**
   - "Informada directamente por su fuente nacional" es inexacto: Argentina y Uruguay informan a través del FMI, Brasil por su fuente nacional y Chile a través de la OCDE. → "informada por una fuente oficial (FMI, fuente nacional u OCDE)".
   - "`Final_value` es la mejor estimación disponible" es una afirmación que la base no respalda. → "`Final_value` es el valor que informa cada país en su balanza de pagos, completado con estimaciones de OCDE-OMC donde falta".
   - Sumar por qué Chile tiene 62,3%: "nunca informa 4 categorías chicas, y sus años 2023–2024 son estimados".
8. **Diap. 4:** decir de dónde salen los 150 ceros: "80 son de Chile, en las categorías que no informa y que OCDE-OMC completa con ceros" [03_ceros_detalle].
9. **Diap. 7:** sumar la robustez frente a los años estimados de Chile: "En 2005–2022, los años que Chile informó, el orden es el mismo" [03_crecimiento].
10. **Diap. 10 (composición): el armado rompe la estructura del resto.** No tiene título, la etiqueta de sección y la imagen quedan casi pegadas al borde (0,2") y la lectura va centrada. Alinearla con las demás: etiqueta, título ("Composición de las exportaciones, 2005 y 2024"), gráfico y tarjetas, y la lectura alineada a la izquierda.
11. **Diap. 11, cierre:** "mejorar la presentación de resultados con herramientas inferenciales" no es lo que hacen esas herramientas. → "La próxima etapa deberá deflactar los valores y contrastar las diferencias entre países con herramientas inferenciales".
12. **Consistencia:**
    - "OECD-OMC" en la portada debería ser "OCDE-OMC";
    - "BaTIS" y "BaTiS" conviven: elegir una;
    - "2005 - 2024" en la portada debería ser "2005–2024";
    - en la diap. 2, "13 categorías" es "12 categorías más el total".
13. **Numerar las diapositivas.** La original tenía número en el pie, y ayuda a ubicarse en el oral.

## Qué conviene recuperar de la PPT original
- **Portada:** el rótulo de la entrega ("Primera entrega: análisis exploratorio de datos").
- **Tabla de variables con la columna "Descripción"** (diap. 3 de la original): resuelve la corrección obligatoria 3.
- **Nota de la diap. 3 original:** "El total S no se suma a las categorías SA–SL: se usa como denominador de las participaciones". Explica el cálculo y muestra que no hay doble conteo.
- **Tarjetas de crecimiento con inicio y fin** (diap. 6 de la original), en millones de USD con el valor final: Uruguay 1.311 → 6.948; Brasil 14.763 → 48.477; Argentina 6.458 → 17.122; Chile 6.658 → 11.744 [03_crecimiento]. Y "Brasil: el mayor aumento absoluto (+33.714 M)", que se cumple con las dos medidas (QA-003).
- **Número de diapositiva en el pie.**
- **No recuperar** las cifras ni las afirmaciones de la original. Son del balanceado, y varias son falsas con el valor final: "Uruguay +281%", "Chile, la mayor caída", "viajes sigue siendo la principal categoría", "casi tres veces más que Argentina o Chile".

## Diapositiva nueva: robustez de la medida
- **Archivo:** `Presentation entrega 1 - con robustez.pptx`. Es la versión de las 21:13 con dos cambios:
  - una diapositiva nueva, la 11, entre composición y hallazgos;
  - la de hallazgos, que pasa a ser la 12 y queda rotulada "11 · HALLAZGOS Y PREGUNTAS".
  - El archivo del grupo no se tocó.
- **Si el grupo sigue editando su archivo:** copiar la diapositiva 11 de esta copia y pegarla en el propio. Usan el mismo tema, así que conserva el formato.
- **Contenido:**
  - 9 de las 20 afirmaciones del guion se mantienen con el balanceado: la dirección del cambio en la composición, la diversificación y la menor recuperación de Argentina;
  - 11 cambian: el nivel y el perfil de Argentina;
  - gráfico `04_g3`: peso del conocimiento en 2005 y 2024 con las dos medidas;
  - lectura.
- **Estilo:** la estructura de la diap. 9 del grupo con la franja de lectura de la 8. Misma tipografía (Aptos), mismos colores y mismos tamaños.
- **Por qué una sola:**
  - `04_g1` repite lo que ya muestra la brecha de la diap. 5;
  - `04_g2`, a ese tamaño, queda ilegible y solo muestra 2024;
  - `04_g3` muestra en un solo gráfico lo que se mantiene (la dirección) y lo que cambia (el nivel).
- **Para el oral:** el gráfico sale de `script/04_comparacion_medidas.R`, sección 9.3. Las cifras, de `04_resumen_hallazgos` y `04_conocimiento`, y la interpretación, de `comparacion_medidas.md`.
- **Consigna:** pide "limitar [el uso de la IA] en el armado de la PPT" (D-007). Esta diapositiva la armó Claude a pedido de Timothy (D-020). El grupo decide si la incluye y tiene que poder explicarla.
