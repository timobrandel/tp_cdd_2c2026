# Hoja de ruta

Regla: un paso por vez. Un paso se cierra cuando cumple su criterio de cierre, pasó el QA (si produce código o cifras) y Timothy lo validó.

## Fase 0 · Setup (21/09) · HECHA (falta verificar 0.2 con una sesión nueva)
- 0.1 Carpeta del TP con la estructura de la cátedra, `.Rproj`, `.gitignore` y git. **Cierre:** carpeta creada y primer commit.
- 0.2 `CLAUDE.md`, archivos de gestión, subagente QA, `CLAUDE.md` global y puntero en la memoria del repo del curso. **Cierre:** una sesión nueva abierta en la carpeta del TP responde el estado del proyecto sin contexto previo.

## Fase 1 · Instancia 1: EDA (entrega 21/09, 23:59 hora argentina)
**Cierre de la fase:** la PPT del grupo cubre las 5 secciones de `consignas_instancia_1.md` y el checklist del docente (clase 08, sección 9): dimensiones, unidad de observación, descripción y tipo de cada variable, faltantes, descriptivas, distribución de categóricas, forma de las distribuciones, dispersión y atípicos, posición, relación entre variables y periodicidad de la fuente.

**Formato:** solo .pptx, de 8 a 12 diapositivas. Recorrido: ¿qué datos tenemos? → ¿cómo están estructurados? → ¿qué encontramos al explorarlos? → ¿qué preguntas surgen?

**Criterios de evaluación:**
- Comprensión de la base: unidad de observación y características principales.
- Descripción de las variables: descripción, tipo y nulos.
- Análisis exploratorio: uso correcto de estadísticas, tablas y gráficos.
- Interpretación: de 3 a 5 hallazgos explicados.
- Presentación: claridad, orden y legibilidad.
- Coherencia: un hilo conductor entre las diapositivas.

No se esperan conclusiones definitivas ni análisis causales, y los gráficos no necesitan un diseño elaborado. Pesa 10%.
- ✅ 1.1 Datos oficiales en `raw/` con `00_descarga_datos.R`. **Cierre:** zip, CSV y diccionario presentes; el tamaño del zip coincide con el publicado por la OMC (508.787.368 bytes).
- ✅ 1.2 `01_filtrado_batis.R`: raw → input, más la dimensión de la base completa y los nulos por variable. **Cierre:** `input/batis_filtrada.csv` con las 1.040 filas esperadas, o las faltantes identificadas y explicadas.
- ✅ 1.3 `02_estructura_variables.R`: tabla de variables (descripción, tipo, nulos, categorías principales) y unidad de observación verificada, sin duplicados. **Cierre:** tablas en `output/tablas/`.
- ✅ 1.4 `03_exploracion.R`: tendencia central y dispersión, frecuencias, histograma de tasas, boxplot y atípicos, evolución (niveles e índice 2005 = 100), composición que suma 100%, pandemia. **Cierre:** tablas y gráficos en `output/`.
- ✅ 1.5 QA de 1.2–1.4. **Cierre:** veredicto APROBADO, o APROBADO CON OBSERVACIONES con las observaciones resueltas.
- ✅ 1.6 Insumos para la PPT: 3 a 5 hallazgos con razonamiento económico, 1 o 2 preguntas y chequeo de la PPT del grupo contra la consigna. **Cierre:** `gestion/insumos/insumos_ppt_instancia1.md` (auditado en QA-002) y `gestion/insumos/revision_ppt_grupo.md`.
- ✅ 1.7 (entregada el 21/09) El grupo ajusta y entrega la PPT (`gestion/insumos/Trabajo_Practico_BaTiS_EDA.pptx` es la versión revisada). **Cierre:** entregada antes de las 23:59.
  - a. El grupo decide la medida: `Final_value` (D-015) o `Balanced_value`. Si elige el balanceado, se cambia `variable_principal` en `03`, se regenera todo, se rehacen las cifras de los insumos y se registra una decisión que reemplace a D-015.
  - b. Aplicar las 8 correcciones obligatorias de `revision_ppt_grupo.md`, que valen con cualquier medida. Las principales:
    - tabla con las 12 variables y sus nulos;
    - dimensión de la base completa y periodicidad;
    - medidas de dispersión;
    - salvedad de Chile 2023–2024;
    - histograma;
    - una frase de interpretación en cada gráfico;
    - integrantes en la portada;
    - pregunta 1 sin formulación causal.
  - c. Actualizar las cifras según la medida elegida. Con `Final_value`, cambian los hallazgos 3 y 5 de la PPT.
  - d. (21/09, 21:15) La PPT nueva del grupo (`gestion/insumos/TP CIENCIA DE DATOS BaTiS - 1ª entrega - FIrmano, Brandel, Díez de Los Ríos.pptx`, con el valor final) se revisó contra las cifras auditadas en `gestion/insumos/revision_ppt_entrega1.md`.
  - e. (21/09, 21:30) Por decisión de Timothy (D-021), Claude aplicó todas las correcciones y la diapositiva de robustez en el archivo del grupo. La PPT final tiene 12 diapositivas y está lista para entregar. Respaldo de la versión del grupo: `Presentation entrega 1 - respaldo del grupo 21.13.pptx`.
- ✅ 1.8 (commit `9613cfa` en `main`, QA-003, D-019) Comparación de las dos medidas: `04_comparacion_medidas.R` chequea las afirmaciones del guion con el valor final y con el balanceado. No bloquea 1.7: le da evidencia a la decisión 1.7a. Interpretación en `gestion/insumos/comparacion_medidas.md`. **Cierre:** QA aprobado, Timothy valida, merge a `main` y push.

## Fase 2 · Consolidación post-entrega (antes del 27/10)
- 2.1 ✅ (27/10) Devolución docente de la Instancia 1 (7/10): falta aprovechar el comercio bilateral; propone concentración de socios por país y sector, índice de diversidad y ANOVA entre sectores con todos los países. Registrada en D-023 a D-025.
- 2.2 ✅ (27/10) Transcripciones: las "Notas de Gemini" de Drive traen la transcripción completa. Se bajaron las de las clases 10, 12 y 14–18 a una carpeta local; no se publican porque son material de la cátedra (D-031).
- 2.3 MCP de R (`mcptools`, Posit): verificar que siga vigente, instalar, configurar y probar con RStudio.
- 2.4 (adelantado: repo `timobrandel/tp_cdd_2c2026` creado y `main` subido el 21/09, D-018; faltan colaboradores y README) Repo de GitHub del grupo: colaboradores y README según `guia_readme.md`. **Cierre:** los integrantes tienen acceso y el README cubre las secciones de la guía.
- 2.5 Hipótesis de trabajo formal (la exige el TP completo).
- 2.6 Opcional: Ralph loop + QA para tareas largas y bien definidas.
- 2.7 Consolidar la comparación de medidas (D-019, QA-003):
  - pasar la sección 7 bis de `03_exploracion.R` (robustez) al 04 y actualizar las referencias a `03_robustez_*` en decisiones e insumos;
  - sumar al resumen del 04 las dos afirmaciones de la PPT del grupo (M3): Brasil "casi tres veces" y la recuperación más fuerte;
  - agregar el coeficiente de asimetría g1 de la clase 06 a las tablas de distribución del 03 y del 04 (m1);
  - comentar en el 03 y el 04 que la tasa de 2005 es NA porque no hay año anterior (m8);
  - unificar `misma_direccion`: TRUE/FALSE en el 03 y Sí/No en el 04.
  **Cierre:** el 03 queda sin la 7 bis, el 04 reproduce esas cifras y pasa el QA.

## Fase 3 · Instancia 2: métodos (vence 29/10, 23:59; PDF de 10–15 diapositivas)
Consigna: `CURSO/trabajo_practico/consignas_instancia_2.md`. Hoja de ruta aprobada por Timothy el 27/10.

**Requisitos:**
- síntesis de la Instancia 1 y cambios por la devolución;
- faltantes y outliers, con criterio y justificación;
- un método de inferencia: hipótesis, supuestos, estadístico, p-valor, tamaño del efecto y limitaciones;
- un método cuantitativo: justificación, decisiones, resultados y limitaciones;
- una síntesis final.

Solo se entrega el PDF.

**Pasos:**
- 3.0 ✅ (27/10) Registrar la devolución, la hipótesis borrador y la medida bilateral (D-023, D-024, D-025).
- 3.1 ✅ (27/10) `script/05_filtrado_bilateral.R`: base bilateral de los 4 países y base al mundo de todos los países, por sector. **Cierre:** grilla completa sin faltantes ni filas de más, y la suma de socios igual al total al mundo. Cumplido (`05_cobertura_bases`, `05_control_suma_socios`).
- 3.2 ✅ (28/10, QA-004b aprobado con observaciones) Faltantes y outliers del bilateral: origen del dato por país y año (estimado o informado), ceros, cambios territoriales y ROW; outliers con 1,5 RIC sobre el log del valor por sector. **Cierre:** tabla de diagnóstico y una decisión justificada para cada caso. Hecho en `script/06_faltantes_atipicos.R` y `06_diagnostico_resumen` (D-026).
- 3.3 ✅ (28/10, QA-004b aprobado con observaciones) Método cuantitativo: participación por socio, CR1, CR4 y HHI por país, sector y año, más la diversidad (sectores con RCA > 1, como en la clase 12). Las funciones de la clase 12 se adaptan en `utils/`. Sensibilidad por medida: balanceado (principal) contra valor final (D-029). La sensibilidad por período solo vale para Brasil, 2010–2014 contra 2015–2024; para Argentina, 2005–2014 es retroproyección (QA-004, M4). **Cierre:** tablas y gráficos interpretados. Hecho en `script/07_concentracion_socios.R` (D-026, D-027).
- 3.4 ✅ (28/10, QA-004b aprobado con observaciones; hecho en `script/08_anova_sectores.R`, D-028) Método de inferencia: ANOVA del log del valor exportado entre los 12 sectores, con todos los países.
  - Supuestos: normalidad de los residuos y homogeneidad de varianzas (Levene o Fligner).
  - Si fallan: Welch o Kruskal-Wallis, con comparaciones de a pares y eta².
  - Limitación: un mismo país aparece en varios sectores.

  **Cierre:** el resultado, interpretado contra la hipótesis.
- 3.5 ✅ (28/10) QA del bloque 3.1–3.4 (HO-004, `qa-auditor`): QA-004 rechazó, QA-004b aprobó con observaciones, todas corregidas.
- 3.6 ✅ (28/10, QA-005b aprobado con observaciones, commit `a774e55`) Tablas, gráficos, cifras y guion de 10 a 15 diapositivas para el PDF del grupo. Guion en `gestion/insumos/guion_pdf_instancia2.md`; tabla de variables en `script/09_tabla_variables_bilateral.R`.

**Diferido a después del 29/10:** 2.3 (prueba del MCP de R), 2.4 (colaboradores y README) y 2.7 (consolidación del 03 y el 04).

**A confirmar:** la clase 18 menciona que la entrega final pasa al 30/11, con una clase de consultas el 27/11.

## Fase 4 · Instancia 3: visualizaciones (13/11)
**Insumo (28/10):** `gestion/insumos/graficos_catedra.md` mapea cada gráfico del TP con su modelo de la cátedra (clases 10, 12, 21 y 22): tema de la casa en `utils/tema_tp.R`, paleta fija por país, pares exploración → comunicación. Falta que Timothy decida si se aplica ahora o en esta fase (recomendación: en esta fase).
**Requisitos (consigna del TP):**
- Al menos dos visualizaciones con los elementos de storytelling de la Unidad 4.
- Para cada una:
  - qué rol cumple: describir una relación, presentar el resultado de un método, apoyar las conclusiones o mostrar el tratamiento de nulos y outliers;
  - en qué parte de la presentación final va y cómo ayuda al argumento.
- Tienen que ser funcionales al análisis, no decorativas. En la entrega final, una va orientada a la comunicación y otra al análisis exploratorio.
- Pesa 10%.

**Pendientes anotados (sesión SES-001, 21/09):**
- **Tasas anuales en líneas, junto al boxplot de la diap. 9.**
  - Gráfico: variación interanual por año, los 4 países, Argentina resaltada y 2020 y 2022 marcados.
  - Por qué: el boxplot no se entiende sin explicación (Timothy no lo leía). Las líneas cuentan la historia y muestran que los cuatro caen y rebotan juntos, lo que prepara el test pareado. El boxplot formaliza los atípicos con la regla de 1,5 RIC que pide la clase 08.
  - Se hace en el script 03, en el formato de la diapositiva, y pasa por QA.
  - Candidato natural para "mostrar el tratamiento de outliers".
- **Letras de los ejes más grandes en el boxplot (`03_g4_boxplot_tasas.png`).** A tamaño de diapositiva se leen chicas.
- **Histograma de tasas de la diap. 8 (`03_g3_histograma_tasas.png`):** con 19 años por país queda ralo. Evaluar si lo reemplaza el gráfico de líneas.

## Fase 5 · Entrega final (24/11) y oral (24/11 al 01/12)
**Contenido mínimo (consigna del TP):**
- Hipótesis de trabajo, apoyada por todo lo que se haga.
- Presentación de la base: variables (qué significan, qué valores toman, de qué tipo son), dimensiones y periodicidad de publicación.
- Estadísticas descriptivas con tablas y visualizaciones.
- Análisis de las distribuciones, los faltantes y los outliers.
- Al menos 3 métodos además de los descriptivos:
  - al menos uno estadístico, con sus supuestos verificados y corregidos;
  - al menos una herramienta de análisis económico o cuantitativo.
- Las visualizaciones de la Instancia 3, con las buenas prácticas de la Unidad 4.
- Conclusiones y próximos pasos.
- Todo método y visualización, interpretado. No causal.

**PPT:** .pptx o PDF de 15 a 20 diapositivas, sin contar carátula ni cierre, más un anexo con tablas y gráficos de respaldo.

**Repo de GitHub:**
- Estructura raw / auxiliar / input / output (tablas, graficos) / script / utils / README, usando todas las carpetas.
- Datos cargados, scripts, outputs y README en Markdown: objetivo, justificación de la base, qué se hizo, estructura de carpetas y cómo reproducir.
- Hoy es privado (D-018): al entregar, se hace público o se suma al docente como colaborador.

**Oral:** virtual y sincrónico; participan todos los integrantes. El foco está en entender el código y las decisiones: repasar `decisiones.md`.

**Evaluación:** pesa 60%, con el oral incluido. La devolución llega con una grilla de evaluación que se comparte en las últimas semanas: usarla como checklist.
