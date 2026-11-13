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
- 3.7 ✅ (29/10, QA-006b aprobado con observaciones, commit `8d798d2`; borrador armado por Claude, D-033) Armado del PDF sobre el guion validado, con las correcciones de redacción de Diego (ceros y `socios_con_ventas`, "conservador", muestra del ANOVA, socios equivalentes, RCA como diversidad sectorial, bloque ≠ medidas repetidas) y, opcional, los socios que explican la concentración (Brenda). **Cierre:** PDF revisado contra el guion y validado por Timothy. Handover: `gestion/handovers/2026-10-29-armado-pdf-instancia2.md`.

**Diferido a después del 29/10:** 2.3 (prueba del MCP de R), 2.4 (colaboradores y README) y 2.7 (consolidación del 03 y el 04).

**Resultado:** nota 10/10 (devolución del 11/11). Sugerencia del docente para la final: un cluster para ver a qué países se parece Argentina por tipo de servicio o por continente de destino, con un promedio de los últimos años.

## Fase 4 · Instancia 3: visualizaciones (vence jueves 12/11, 23:59)
Consigna: `CURSO/trabajo_practico/consignas_instancia_3.md` (publicada el 06/11; reemplaza los requisitos viejos de esta fase). Apoyo: clases 22 y 24 (`CURSO/clases/clase24/clase24_graficos_owid.R` y `clase24_latam_small_multiples.R`) y `gestion/insumos/graficos_catedra.md` (D-032).

**Qué se entrega:**
- Dos JPG hechos en R y exportados con `ggsave()`, a 300 dpi como mínimo y de 20 a 25 cm de ancho: `grupo_26_exploratorio.jpg` y `grupo_26_comunicativo.jpg`.
- Sin código, sin PPT y sin texto que los acompañe: cada gráfico se sostiene solo.
- Por mail a nsidicaro.fce@gmail.com, asunto `curso_2c_2026_grupo_26_instancia_3`. Envía un integrante, con el resto en copia.
- Pesa 10%. Los gráficos no son definitivos: con la devolución, se mejoran para la entrega final.

**Exploratorio** (para el equipo y el docente):
- Complejidad técnica real, con muchas dimensiones a la vez.
- Prueba: si lleva a una conclusión obvia, no es exploratorio. No alcanzan las barras ordenadas, una sola serie de tiempo ni un gráfico lindo que no se use.
- Sirven: boxplots o violines por grupo, dispersión con cuadrantes y color y tamaño por variable, small multiples, mapa de calor, ECDF superpuestas o resultados de métodos de la Instancia 2.
- Título y rótulos que digan qué variables se miran y sobre qué universo.

**Comunicativo** (para alguien que no leyó el TP):
- Un solo mensaje, entendible en menos de 10 segundos. Tiene complejidad, pero el diseño la reduce.
- Título que afirma el hallazgo; subtítulo con unidad, universo y período.
- Color como jerarquía: una o dos series destacadas y el resto en gris.
- Anotaciones dentro del gráfico, líneas de referencia, etiquetas directas en vez de leyenda y fuente al pie.
- Modelo: Our World in Data, Data Insights (clase 24).

**Prolijidad en los dos:**
- Ejes en castellano y con unidad.
- Números con formato argentino.
- Fuente en el `caption`.
- Escalas honestas: si se corta el eje o se usa log, se aclara.
- Paleta que se distinga en escala de grises, sin depender de rojo contra verde. Nada de tortas.

**Pasos:**
- 4.1 ✅ Mensaje y tipos aprobados por Timothy (D-034, D-037). Paquetes autorizados en D-035.
- 4.2 ✅ Tema reutilizable en `utils/tema_tp.R`, con números argentinos y una función por archivo. Colores por destino o servicio (D-036).
- 4.3 ✅ `script/10_destinos_sectores.R` genera los dos JPG desde la raíz. Rscript termina con salida 0.
- 4.4 ✅ QA-008, QA-008b y QA-008c aprobados. Timothy validó ambas imágenes y autorizó commit y push el 13/11.
- 4.5 **Pendiente:** el grupo envía los dos JPG. **Cierre:** confirmar el envío y su fecha.
  - La consigna escrita indica 12/11, 23:59. Timothy indicó el 13/11 a medianoche argentina como plazo operativo.
  - No verificamos una modificación oficial del plazo ni el envío.

**Pendientes anotados (sesión SES-001, 21/09):** van a la entrega final como gráficos de informe.
- **Tasas anuales en líneas, junto al boxplot de la diap. 9.**
  - Gráfico: variación interanual por año, los 4 países, Argentina resaltada y 2020 y 2022 marcados.
  - Por qué: el boxplot no se entiende sin explicación (Timothy no lo leía). Las líneas cuentan la historia y muestran que los cuatro caen y rebotan juntos. El boxplot formaliza los atípicos con la regla de 1,5 RIC que pide la clase 08.
  - Candidato natural para "mostrar el tratamiento de outliers".
- **Letras de los ejes más grandes en el boxplot (`03_g4_boxplot_tasas.png`).** A tamaño de diapositiva se leen chicas.
- **Histograma de tasas de la diap. 8 (`03_g3_histograma_tasas.png`):** con 19 años por país queda ralo. Evaluar si lo reemplaza el gráfico de líneas.

## Fase 5 · Entrega final (martes 24/11, 23:59) y oral (24/11 al 01/12)
Consigna: `CURSO/trabajo_practico/consignas_entrega_final.md` (publicada el 10/11). La fecha del 24/11 la confirmó el docente en la clase 24, así que no se pasa al 30/11.

**Presentación:** PDF o PPTX de 15 a 20 diapositivas, sin contar carátula ni cierre, más un anexo. Recorrido: ¿qué nos preguntamos? → ¿con qué datos? → ¿cómo quedaron después de limpiarlos? → ¿qué métodos y en qué orden? → ¿qué encontramos? → ¿qué concluimos?
1. Hipótesis específica y contrastable. Si cambió desde la Instancia 1, se dice y se explica por qué.
2. La base: quién la produce, periodicidad, unidad de observación, filas y variables con las que se trabaja, período y limitaciones.
3. Tabla de las variables usadas: descripción, tipo, faltantes y cómo se construyeron las variables nuevas.
4. Bases auxiliares, o decir explícitamente que no hay.
5. Descriptivas **antes** de la limpieza: tendencia central, dispersión y distribución, con tablas y gráficos.
6. Faltantes y outliers: cómo se detectaron, qué se hizo, por qué y qué consecuencias tiene.
7. Descriptivas **después** de la limpieza. Si no se limpió, mostrar que no cambian de forma considerable.
8. Al menos 3 métodos: uno de inferencia (Unidad 2), uno cuantitativo (Unidad 3) y un tercero. Quien ya tenía tres los profundiza en vez de sumar uno sin función.
   - Orden: tests → ANOVA → regresión. Los índices van antes si construyen la variable que se analiza después; clustering y PCA, antes de los métodos que los usan.
   - Por cada método: por qué se eligió, decisiones, supuestos (y qué se hizo si no se cumplen), resultados con estadístico, gl, p-valor y tamaño del efecto, interpretación contra la hipótesis y limitaciones.
9. Conclusión sin resultados nuevos.
10. Próximos pasos.

**Visualizaciones:**
- Los dos gráficos de la Instancia 3, corregidos y ubicados en el argumento.
- Además, gráficos de informe en al menos tres momentos: descriptivas, faltantes y outliers, y resultados de los métodos.
- Todos cumplen los criterios de la clase: castellano, unidades, fuente, orden con sentido, sin tortas y legibles en la diapositiva.

**Repo:**
- Todas las carpetas en uso.
- Scripts autónomos que leen lo que guardó el anterior, con prefijo numérico y un nombre que explique qué hacen.
- Una función por archivo en `utils/`.
- Rutas relativas y librerías al principio.
- Sin `setwd()`, `rm(list = ls())` ni `install.packages()`.
- README con: título, integrantes, objetivo e hipótesis, base con link, período y unidad, análisis, estructura, cómo reproducir (paquetes, orden y qué genera cada script) y conclusiones.
- **Prueba obligatoria:** clonar el repo en otra carpeta y correr todo de cero.
- No cuentan los commits posteriores al 24/11, 23:59.
- Ojo con los datos pesados fuera de git (D-010): la consigna admite excepciones "habilitadas expresamente por el docente", así que conviene confirmarlo con él.

**Envío:** asunto `curso_2c_2026_grupo_26_entrega_final`, con el link al repo y los nombres de los integrantes en el cuerpo del mail y la presentación adjunta.

**Oral:**
- 20 minutos: 15 de exposición, con corte estricto, y 5 de preguntas sobre el código y las decisiones, a cualquier integrante. Hablan todos.
- Fecha a elegir en https://forms.gle/oguR4XUZRVLvS2M17
- Repasar `decisiones.md`.

**Devoluciones a incorporar:**
- Instancia 1: bilateral (D-023).
- Instancia 2: el cluster sugerido.
- Instancia 3: la que llegue.

**Evaluación:** pesa 60% con el oral. Llega con una grilla que se comparte en las últimas semanas: usarla como checklist.
