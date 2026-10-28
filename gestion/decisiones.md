# Decisiones del proyecto

Registro de decisiones técnicas y de proyecto. Formato: contexto, decisión, alternativas descartadas, por qué. Una decisión vigente no se re-discute sin un motivo nuevo; si cambia, se agrega una nueva que la reemplace y se marca la anterior como reemplazada.

---

## D-001 · 21/09/2026 · El TP vive en su propia carpeta, fuera del repo del curso
- **Decisión:** carpeta `tp_cdd_2c2026`, hermana del repo del curso, con la estructura exacta de la consigna final. El repo del curso queda como biblioteca de solo lectura.
- **Alternativa descartada:** trabajar dentro del repo del curso (con exclusiones locales de git).
- **Por qué:** la entrega final exige un repo de GitHub propio con estructura fija; el repo del curso ya tiene `datos/`, `output/` y `utils/` (mezclar genera confusión); y si el docente sube un archivo con el mismo nombre que uno nuestro, `git pull` se frena.

## D-002 · 21/09/2026 · Git local en el TP; commit solo al cerrar hitos validados
> **Reemplazada en parte por D-031 (28/10):** `gestion/` se publica, filtrada. Sigue vigente el commit solo con hitos validados.
- **Decisión:** repositorio git en la carpeta del TP. Commit solo cuando Timothy valida un hito; los comandos git los corre Claude. Fuera de git: `CLAUDE.md`, `.claude/`, `gestion/`. En el repo del curso, cero commits.
- **Por qué:** cada hito validado queda como punto de restauración; el QA audita exactamente lo que cambió desde el último hito; al final se sube a GitHub (obligatorio). Los archivos de trabajo con Claude no son parte de la entrega.

## D-003 · 21/09/2026 · Memoria persistente con los mecanismos nativos de Claude Code
- **Decisión:** `~/.claude/CLAUDE.md` global (perfil y reglas de Timothy) + `CLAUDE.md` del TP (instrucciones y mapas) + `gestion/*.md` + memoria automática de Claude Code.
- **Alternativa descartada:** skill `productivity:memory-management`.
- **Por qué:** Claude Code ya carga solo los `CLAUDE.md` y el índice de su memoria automática al abrir cada sesión. El skill está pensado para decodificar jerga y personas de un laburo y crea su propio `CLAUDE.md` + `memory/`: duplica lo nativo y se superpone con los archivos de gestión. `estadodelproyecto.md` se importa desde `CLAUDE.md` (se carga siempre); hoja de ruta y decisiones se leen a demanda porque crecen.

## D-004 · 21/09/2026 · QA como subagente que la sesión Dev lanza al cerrar cada bloque
- **Decisión:** subagente `qa-auditor` (`.claude/agents/qa-auditor.md`), con handover escrito (`gestion/handovers/`) e informe (`gestion/qa/`). Máximo 2 vueltas de corrección; después escala a Timothy.
- **Alternativa descartada:** dos sesiones fijas (Dev y QA) conectadas por mensajes.
- **Por qué:** la app no permite que una sesión cree otra sola. El subagente nace de cero en cada auditoría (sin los sesgos del Dev), tiene herramientas limitadas por configuración y corre en paralelo. La sesión QA fija acumularía contexto entre auditorías y necesita el mismo modo de permisos que la Dev.

## D-005 · 21/09/2026 · R se ejecuta con Rscript en sesión limpia; MCP de R después de la entrega
- **Decisión:** Dev y QA corren cada script con `Rscript` desde la raíz del TP; Timothy corre los mismos scripts en RStudio abriendo `tp_cdd_2c2026.Rproj`, configurado para no guardar ni restaurar el Environment (`.RData`). No se usa el paquete `here`. El MCP `mcptools` (Posit) se evalúa en la Fase 2.
- **Por qué:** `Rscript` arranca un R nuevo cada vez, que es el test de reproducibilidad de la cátedra. El `.Rproj` fija la carpeta de trabajo en la raíz del proyecto, así las rutas relativas funcionan en cualquier compu. `here` es opcional para la cátedra y con `.Rproj` alcanza. El MCP no hace falta para producir la entrega y su instalación es un paso aparte con su propia verificación.

## D-006 · 21/09/2026 · Consigna vigente de la Instancia 1: `consignas_instancia_1.md`
- **Decisión:** nos basamos solo en `consignas_instancia_1.md`. La sección "Instancia 1" de `consignas_trabajo_final.md` queda como referencia no vinculante. Todas las columnas de la base con valores se describen en la tabla de variables (tipo y nulos), marcando cuáles se usan.
- **Por qué:** `consignas_instancia_1.md` se subió el 08/09, después de `consignas_trabajo_final.md` (23/08), y es la que linkea el README para la primera entrega; la otra quedó desactualizada (todavía dice 18/09). Según recuerda Timothy, el docente dijo en una clase virtual que se usen todas las variables que tengan valores, y eso es compatible con el punto 2 de la consigna porque BaTIS tiene pocas columnas.

## D-007 · 21/09/2026 · La PPT la arma el grupo
- **Decisión:** Claude produce scripts, tablas, gráficos y un guion por diapositiva con cifras e interpretación; el grupo arma la PPT.
- **Por qué:** la cátedra permite IA en scripts e interpretación pero pide limitarla en el armado de la PPT, y en el oral pregunta por el código y las decisiones.

## D-008 · 21/09/2026 · Convenciones de código
- **Decisión:** carpeta `script/` en singular (como exige la consigna, aunque la guía de organización dice `scripts/`); scripts numerados `NN_nombre.R` con encabezado Script / Objetivo / Entrada / Salida; una función por archivo en `utils/`.
- **Por qué:** la consigna final es el documento vinculante para la estructura del repo.

## D-009 · 21/09/2026 · Transcripciones de las clases después de la entrega
- **Decisión:** Fase 2. Primero revisar en la carpeta de Drive de las grabaciones si Meet generó transcripciones de texto; si solo hay videos, evaluar transcripción local.
- **Por qué:** para la Instancia 1 alcanza el material escrito del repo (clase 05, clase 08 con el checklist del docente). Transcribir videos requiere instalar herramientas y horas de proceso.

## D-010 · 21/09/2026 · Datos crudos pesados fuera de git
- **Decisión:** el zip de datos (509 MB) y el CSV descomprimido (~2,8 GB) quedan en `raw/` pero fuera de git; se regeneran con `script/00_descarga_datos.R`. La base filtrada de `input/` sí se versiona.
- **Por qué:** GitHub rechaza archivos de más de 100 MB. La descarga por script garantiza que cualquier integrante (y el docente) reproduzca exactamente los mismos datos.

## D-011 · 21/09/2026 · Descarga oficial de la OMC y filtrado con DuckDB
- **Decisión:** los datos se bajan de wto.org (no del Drive del compañero) y el CSV se filtra con DuckDB antes de pasarlo a R; después del filtro, todo es tidyverse.
- **Alternativas descartadas:** bajar el CSV del Drive (2,8 GB contra 509 MB del zip oficial, sin descarga reproducible); cargar el CSV completo en R con `readr` (varios GB de memoria, RStudio se cuelga).
- **Por qué:** es la misma versión que usó el compañero (08/12/2025), así que las cifras coinciden. DuckDB consulta el archivo en disco y le pasa a R solo las filas filtradas (1.040 de millones).

## D-012 · 21/09/2026 · Scripts adaptados de BATIS.R, con los mismos filtros
- **Decisión:** los scripts 01–03 conservan la lógica y los filtros de `auxiliar/BATIS_original_companero.R` (reporters AR, BR, CL, UY; socio WL = mundo; flujo X = exportaciones; 2005–2024; ítems S y SA–SL) y agregan lo que pide la consigna: dimensión y nulos de la base completa, tabla de variables, dispersión, histograma, índice 2005 = 100 y composición que suma 100%.
- **Por qué:** mantener las cifras de la PPT del grupo y completar lo que falta sin reescribir desde cero.
- **Estado:** reemplazada en parte por D-015. Los filtros se mantienen, pero las cifras cambian porque la variable principal pasa a ser `Final_value`.

## D-013 · 21/09/2026 · Alcance: 4 países y 2005–2024, sin recortes
- **Decisión:** no se saca ningún país ni se acortan años.
- **Por qué:** la base de trabajo tiene 1.040 filas; recortar no ahorra trabajo (el código es el mismo) y quita comparación. 2005–2024 cubre varios regímenes macroeconómicos argentinos, y el tema calza con métodos de la Unidad 3 (ventajas comparativas reveladas, concentración de la canasta) para la entrega final. Riesgos a explicitar: escalas distintas entre países (normalizar con índices y participaciones), USD corrientes y valores balanceados que pueden diferir de la balanza de pagos oficial.

## D-015 · 21/09/2026 · Variable principal: `Final_value` (valor informado por cada país)
- **Decisión:** el análisis y la PPT usan `Final_value`. `Balanced_value` se presenta como hallazgo de calidad del dato: la brecha entre lo que informa cada país y lo que declaran sus socios, año por año (gráfico `03_g7`). La medida se elige con el parámetro `variable_principal` de `script/03_exploracion.R`. Aprobada por Timothy.
- **Alternativa descartada:** `Balanced_value`, la que usaba el script original del grupo.
- **Por qué:**
  1. `Final_value` es la serie de balanza de pagos que informa cada país, según el código de metodología: FMI (R_IMF) para Argentina y Uruguay, fuente nacional (R_NAT) para Brasil, OCDE (R_OECD) para Chile. Donde falta el dato, está completada con estimaciones de OCDE-OMC. Con el balanceado, Argentina queda entre 2,8% y 18,5% por debajo de lo que informa (11,7% en promedio).
  2. El balanceo está pensado para la consistencia bilateral (lo que A exporta a B es igual a lo que B importa de A), no para medir el total de un país. Además, sus ajustes cambian mucho en el tiempo: en Chile van de −5,7% (2005) a +57,3% (2021); en Uruguay, de +44,4% (2006) a valores negativos desde 2012.
  3. La elección cambia lo que se cuenta. Con el final, Argentina supera a Chile todos los años desde 2006 (hasta +74,9% en 2019 y +45,8% en 2024); con el balanceado parecen del mismo tamaño. La participación de conocimiento de Argentina en 2024 es 51,0% con el final y 36,5% con el balanceado.
- **Qué no cambia:**
  - En 2005–2022 (los años que Chile informó), el ranking de crecimiento es el mismo con las dos medidas: UY > BR > AR > CL. La inversión entre Argentina y Chile en 2005–2024 aparece solo al sumar 2023–2024 de Chile, que son estimaciones.
  - En las categorías grandes (transporte, viajes, otros servicios empresariales, telecomunicaciones e informática), la dirección del cambio 2005–2024 es la misma con ambas medidas en los 4 países. Difiere en 12 de 48 pares país-categoría, todos con cambios menores a 1 punto porcentual salvo propiedad intelectual de Uruguay (`03_robustez_direccion`).
- **Salvedad:** en Chile, los 13 ítems de 2023–2024 son estimaciones de OCDE-OMC (9 con E2 y 4 con E5), con cualquiera de las dos medidas.

## D-016 · 21/09/2026 · Tablas de resultados en formato Excel argentino
- **Decisión:** las tablas de `output/tablas/` se guardan con `utils/guardar_tabla.R`: separador ";", coma decimal, UTF-8 con BOM, redondeo a 2 decimales. La base de trabajo (`input/batis_filtrada.csv`) sigue en CSV estándar y con todos sus decimales, porque la leen los scripts.
- **Por qué:** el grupo abre las tablas con doble clic en un Excel con configuración argentina para copiar cifras a la PPT. En CSV estándar, los acentos y los decimales se leen mal (QA-001, m5). Para leerlas desde R se usa `read_csv2()`.

## D-017 · 21/09/2026 · La correlación entre países no se presenta como hallazgo
- **Decisión:** la correlación de las tasas de variación entre países queda como tabla de respaldo (`03_correlaciones_tasas`), no como hallazgo de la PPT.
- **Por qué:** con `Final_value` y sin 2020–2022 (n = 16), las correlaciones van de 0,43 a 0,84. Para el mínimo, el intervalo de confianza al 95% va de −0,08 a 0,76. Además son tasas de valores en USD corrientes: parte de la asociación puede venir de shocks comunes (crisis de 2009, dólar fuerte de 2015, pandemia) y de la valuación en dólares, no de una integración entre los países (QA-001, M2).

## D-014 · 21/09/2026 · Histograma de tasas de variación anual, no de niveles
- **Decisión:** el histograma principal muestra las tasas de variación interanual de las exportaciones totales de servicios por país.
- **Por qué:** en niveles, Brasil exporta varias veces lo que Uruguay y el histograma queda aplastado. La tasa no depende del tamaño del país y muestra la volatilidad, que es comparable entre países.

## D-018 · 21/09/2026 · Repo en GitHub: `timobrandel/tp_cdd_2c2026`, privado hasta la entrega final
> **Reemplazada en parte por D-030 (28/10):** el repo es público. Siguen vigentes la rama `main` y el push con `gh`.
- **Contexto:** el repo remoto estaba previsto para el paso 2.4, después de la entrega. Timothy lo adelantó al 21/09.
- **Decisión:** repo privado en la cuenta de Timothy, con `main` como rama por defecto. Se sube lo que versiona git según D-002 y D-010 (quedan fuera `CLAUDE.md`, `.claude/`, `gestion/` y los datos crudos pesados). El push se hace con las credenciales de `gh`, solo para ese comando: `git -c credential.helper= -c "credential.helper=!gh auth git-credential" push`.
- **Alternativas descartadas:** repo público desde ahora; `git push` a secas; `gh auth setup-git`.
- **Por qué:**
  - De privado a público se pasa con un comando. Al revés no sirve: lo que ya se vio o se clonó no se borra. El docente necesita acceso recién en la entrega final (24/11): ahí el repo se hace público o se lo suma como colaborador.
  - Los commits llevan el mail del campus de Timothy, que en un repo público queda a la vista de cualquiera.
  - Git usa Git Credential Manager, que puede abrir una ventana de login y trabar el comando. `gh` ya tiene la sesión iniciada con la cuenta `timobrandel`. `gh auth setup-git` resolvería lo mismo, pero cambia la configuración global de git de Timothy.
- **Estado:** la visibilidad privada la eligió Claude como opción conservadora; Timothy puede cambiarla.
- **Pendiente (paso 2.4):** sumar a los integrantes como colaboradores (hacen falta sus usuarios de GitHub) y escribir el README según `guia_readme.md`.

## D-019 · 21/09/2026 · La comparación de medidas va en un script propio, no en una copia de los scripts
- **Contexto:** el grupo discute qué medida usar (D-015). Timothy propuso copiar los scripts con el valor balanceado en una rama nueva para comparar.
- **Decisión:** script `04_comparacion_medidas.R`, trabajado en la rama `comparacion-medidas`, aprobado por Timothy.
  - Pasa la base a formato largo (una columna `medida`) y calcula las métricas del 03 con las dos medidas a la vez.
  - Chequea con cada medida las 20 afirmaciones del guion de la PPT (`04_resumen_hallazgos`).
  - El 03 no se toca y sigue con el valor final.
- **Alternativa descartada:** copiar los scripts con el balanceado en una rama.
- **Por qué:**
  - Solo el 03 depende de la medida, y ya la tiene como parámetro (`variable_principal`). El 00 y el 01 no dependen de ella, y el 02 solo en una etiqueta. Una copia deja dos versiones que hay que mantener iguales a mano.
  - Una rama muestra una versión por vez y los archivos se llaman igual en las dos: la tabla lado a lado no existiría en ningún lado.
  - La rama sí sirve para trabajar sin tocar `main` hasta que pasen el QA y la validación de Timothy.
- **Criterios de "se cumple":** están escritos en la columna `criterio` de `04_resumen_hallazgos`. Tres implican una convención:
  - la asimetría se da por cumplida si la media supera el doble de la mediana;
  - "más años de caída" exige que Argentina supere a cada uno de los otros; el empate no alcanza;
  - el orden 2005–2022 se compara con el de 2005–2024 de la misma medida.
- **Pendiente (paso 2.7):** la sección 7 bis del 03 (robustez) se superpone con el 04. Se pasa al 04 en la Fase 2, porque hoy los insumos y la PPT citan las tablas `03_robustez_*`.

## D-020 · 21/09/2026 · Claude arma una diapositiva de robustez en una copia de la PPT
- **Contexto:** Timothy pidió validar la PPT del grupo contra las cifras auditadas y, si valía la pena, agregar las diapositivas de la comparación de medidas con la estética del grupo. D-007 dice que la PPT la arma el grupo, porque la consigna pide limitar la IA en el armado.
- **Decisión:**
  - Una sola diapositiva ("10 · Robustez de la medida"), en una copia: `Presentation entrega 1 - con robustez.pptx`. El archivo del grupo no se toca.
  - Las correcciones de `revision_ppt_entrega1.md` las aplica el grupo.
  - El gráfico es uno nuevo, `04_g3` (script 04, sección 9.3), pensado para el tamaño de la diapositiva. Grafica datos ya auditados (`04_conocimiento`), y las 13 salidas previas del 04 quedaron idénticas byte a byte.
- **Alternativas descartadas:**
  - Dos diapositivas con `04_g1` y `04_g2`: `04_g1` repite la brecha de la diap. 5, y `04_g2`, a ese tamaño, queda ilegible y solo muestra 2024.
  - Aplicar todas las correcciones en la PPT: sería más IA en el armado, contra D-007.
- **Por qué:** la elección de la medida cambia 11 de las 20 afirmaciones del guion. Mostrar qué se sostiene con las dos medidas fortalece la interpretación y anticipa la pregunta del oral "¿por qué no el balanceado?". Una diapositiva es un uso acotado, y el grupo decide si la incluye.
- **Vigencia:** D-007 sigue valiendo para todo lo demás.
- **Estado:** reemplazada por D-021. La diapositiva ya está en el archivo del grupo.

## D-021 · 21/09/2026 · Claude aplica las correcciones en la PPT del grupo
- **Contexto:** con la revisión (`revision_ppt_entrega1.md`) y la diapositiva de robustez listas, Timothy decidió que Claude aplicara todo en el archivo del grupo, que el grupo dejó de editar. Su criterio: la PPT la armó el grupo y la IA se usa para mejorarla, que es lo que pide la consigna ("limitar su uso en el armado de la PPT").
- **Decisión:** en `gestion/insumos/TP CIENCIA DE DATOS BaTiS - 1ª entrega - FIrmano, Brandel, Díez de Los Ríos.pptx` (el archivo de trabajo se llamaba `Presentation entrega 1.pptx`) se aplicaron:
  - las 6 correcciones obligatorias y las 7 recomendadas;
  - lo recuperado de la PPT original;
  - la diapositiva de robustez (queda en 12 diapositivas);
  - además, se rehízo la diapositiva de composición, cuyo gráfico estaba estirado un 60% en horizontal. Ahora tiene el esquema de las demás y el gráfico en su proporción real.
- **Resguardo:** la versión del grupo quedó en `Presentation entrega 1 - respaldo del grupo 21.13.pptx`.
- **Control:** las 12 diapositivas se revisaron renderizadas con PowerPoint, y el archivo pasa la validación de formato.
- **Por qué:** Timothy tiene la última palabra sobre cuánto usar la IA dentro de lo que permite la consigna. El contenido y la estructura son los del grupo. Los cambios corrigen errores, completan criterios de evaluación y siguen su estética.
- **Vigencia:** reemplaza a D-007 para esta entrega. Para las próximas, se decide en cada instancia.

## D-022 · 21/09/2026 · Hallazgos de la diap. 12 reescritos con criterio de robustez
- **Contexto:** SES-001. Los 5 hallazgos repetían cifras de las diap. 8–10 y dos de ellos (media/mediana y "mayor caída en 2020") no se sostienen con el balanceado (`04_resumen_hallazgos`). "Brasil domina" miraba a Brasil y no a Argentina.
- **Decisión (validada por Timothy):**
  - cinco hallazgos ordenados por los ejes de la diap. 3: nivel, crecimiento, volatilidad y pandemia (fusionados), composición, y dato y medida;
  - solo afirmaciones que se sostienen con las dos medidas;
  - el cierre incluye la salvedad de Chile 2023–2024;
  - la lectura de la diap. 11 se reemplazó, porque justificaba el valor final con un argumento distinto de D-015.
- **Alternativas descartadas:** dejar "La media engaña", que es impreciso (la brecha entre media y mediana de Uruguay es mayor); sacar el eje nivel, que dejaba sin cubrir la pregunta guía.
- **Resguardo:** `Presentation entrega 1 - respaldo antes de hallazgos 22.10.pptx`. Script: `gestion/herramientas_ppt/aplicar_hallazgos.py`.
- **Ampliación (pies de diapositiva, validada por Timothy):**
  - se reescribieron los pies de las diap. 3 y 5 a 10 para que interpreten en vez de repetir el panel;
  - se corrigieron dos afirmaciones: el CV de niveles de la diap. 6 mide crecimiento, no volatilidad, y la correlación 0,67 de Chile en la diap. 5 estaba sobredimensionada;
  - formato parejo: 14 pt y filete verde 2F7D7A en los pies de lectura (5 a 11); el cierre de la 12 queda en terracota;
  - **sin rótulos** ("Lectura:", "Cierre:"): Timothy prefiere frases sueltas, tipo insight, y no una estructura repetida.
  - Resguardo: `Presentation entrega 1 - respaldo antes de pies 22.30.pptx`. Script: `gestion/herramientas_ppt/aplicar_pies.py`.
- **Ampliación (hallazgo 5 y preguntas, validada por Timothy):**
  - el hallazgo 5 pasa a ser "Canastas más diversificadas": en Argentina, top-3 de 87,2% a 79,9%, −7,3 pp con las dos medidas (`04_concentracion`);
  - se mantienen las dos preguntas, centradas en Argentina: ventaja comparativa revelada (Unidad 3, Balassa) y crecimiento significativamente menor (Unidad 2, test pareado);
  - se descartan las preguntas de la PPT original: "qué factores explican" es causal, y deflactar o relativizar al PBI es un chequeo de robustez, que ya figura en "Siguiente etapa".
  - Resguardo: `... respaldo antes de preguntas 22.55.pptx`. Script: `gestion/herramientas_ppt/aplicar_preguntas.py`.

## D-023 · 27/10/2026 · Balanced_value para el análisis bilateral
- **Contexto:** la devolución de la Instancia 1 (7/10) pide aprovechar lo propio de BaTIS, el comercio bilateral. D-015 había elegido `Final_value` para los totales de cada país.
- **Decisión (Timothy):** todo lo bilateral (país × socio) usa `Balanced_value`. D-015 sigue para los totales al mundo de la Instancia 1.
- **Por qué:** la metodología (secciones 5.1 y 6) recomienda el balanceado justamente para los flujos entre pares: concilia lo que declaran exportador e importador y completa los pares que nadie informa. Además, la suma de socios reproduce exacto el total al mundo balanceado (`05_control_suma_socios`, diferencia máxima 0).
- **Consecuencia:** el balanceado no tiene faltantes, pero buena parte de la distribución por socio es estimada (ver D-025).

## D-024 · 27/10/2026 · Hipótesis de trabajo
- **Decisión (Timothy, 27/10):** "Entre 2015 y 2024, las exportaciones de servicios de Argentina se concentran en menos socios que las de Brasil, Chile y Uruguay, y tanto esa concentración como el valor exportado difieren según el sector."
- **Cómo se responde cada parte** (las tres herramientas de la devolución, sin adaptarlas):
  - "se concentran en menos socios": HHI, CR1 y CR4 por país (3.3, cuantitativo). La diversidad que pidió el docente se mide como en la clase 12, con la cantidad de **sectores** con RCA > 1 (D-026): describe la canasta de servicios y no responde esta parte, que es sobre socios (corregido por QA-004, m7);
  - "esa concentración difiere según el sector": las mismas medidas abiertas por sector (3.3);
  - "el valor exportado difiere según el sector": ANOVA del log del valor entre los 12 sectores, con todos los países (3.4, inferencia).
- **Cambios respecto del borrador:**
  - 2015–2024 es el período con dato oficial por socio de Argentina (D-025);
  - "se concentran" en vez de "dependen", porque es lo que mide el HHI y el TP no es causal;
  - se agrega "el valor exportado" para que el ANOVA que pidió el profesor responda una parte de la hipótesis.
- **Alternativa descartada:** hacer el ANOVA sobre el HHI de cada país y sector. Encajaba mejor con el borrador, pero se apartaba de la sugerencia del profesor.
- **Salvedad:** la distribución por socio de Chile y Uruguay es estimada por OCDE-OMC, y la de Brasil lo es en parte (D-025). Va en la sección de faltantes, no en la hipótesis.

## D-025 · 27/10/2026 · Bases bilaterales del script 05 y hallazgos de cobertura
- **Decisión (Claude, autónoma, dentro de la hoja de ruta aprobada):** `script/05_filtrado_bilateral.R` extrae en una lectura del CSV:
  - `input/batis_bilateral.csv`: AR, BR, CL y UY × 202 socios individuales × S y SA–SL × 2005–2024 (207.480 filas). Se excluye WL para no contar dos veces.
  - `input/batis_mundo_sectores.csv`: los 202 países informantes al mundo, mismos ítems y años (51.870 filas), para el ANOVA.
- **Hallazgos que condicionan el análisis:**
  - **Faltantes:** ninguno en el balanceado. Las combinaciones "ausentes" son cambios territoriales (Yugoslavia, Serbia, Montenegro, Antillas Neerlandesas, Curazao, Sint Maarten, Kosovo): la grilla esperada se arma con las economías que existían cada año.
  - **Origen del dato bilateral** (`05_origen_bilateral`): la distribución por socio es 100% estimada por OCDE-OMC en Chile y Uruguay todos los años, en Argentina hasta 2014 y en Brasil hasta 2009. Argentina tiene dato oficial por socio desde 2015 (~164 socios); Brasil desde 2010, con 37 socios que cubren ~65% del valor.
  - **ROW** (resto del mundo) figura como economía, pesa menos de 0,7% del total: se conserva en la base y se decide en 3.3 si entra como socio.
  - **Ceros:** 19.869 filas en cero (sin exportación o estimadas despreciables, E0). En el HHI pesan cero.
  - **Qué mide `origen`:** el código de `Final_value_methodology`, es decir, si el exportador declaró su venta a cada socio. El balanceado nunca es "dato informado" a secas: combina esa declaración con la del importador (metodología, sección 5.1). Lo de "dato oficial" se refiere a la parte del exportador (corregido por QA-004, C1).
  - **Argentina 2005-2014:** el 99,8% del valor tiene código E8.2, una retroproyección de la estructura que Argentina declara desde 2015. Esos años no tienen información propia sobre sus socios. Chile y Uruguay: modelo de gravedad (M1.x).
- **Por qué importa:** en el valor final, comparar la concentración de Argentina con Chile y Uruguay es comparar datos declarados con un modelo de gravedad. Por eso la medida principal es el balanceado, que incluye lo que declaran los compradores de los cuatro (D-029). Va como limitación central en la sección de faltantes de la Instancia 2.

## D-026 · 27/10/2026 · Criterios de faltantes, atípicos y concentración (scripts 06 y 07)
- **Decisión (Claude, autónoma, dentro de la hoja de ruta aprobada):**
  - **ROW se excluye** de la concentración: es un residuo de socios no identificados y contarlo inventaría un comprador. Pesa como máximo 0,7%.
  - **Ceros bilaterales se conservan:** en el HHI pesan cero y no cambian ningún índice. De los 7.978 de 2015-2024, solo 144 los declaró el país; 1.043 son E0 y el resto, ceros del modelo de OCDE-OMC. Son ventas no registradas ni estimadas, no un "no exportó" declarado (corregido por QA-004b, m3).
  - **Base del ANOVA y del RCA:** valor final (D-015), una observación por país y sector con el promedio anual 2015-2024 (200 economías presentes los diez años). Así cada país aparece una vez por sector y no diez. No se usa el balanceado porque en los totales de economías chicas se aparta mucho del valor final (Gabón 2024: 38 millones de valor final, que estima OCDE-OMC porque Gabón no informa, contra 2.497 balanceados).
  - **Faltantes del valor final** (`06_faltantes_valor_final`, agregado por QA-004, M2): no hay nulos, pero 9.263 de 47.880 filas país-sector-año (2005-2024) no tienen valor informado; OCDE-OMC las completa. En la base del ANOVA, el 17,8% de los años.
  - **Ceros al mundo:** 318 de 2.400 celdas país-sector tienen promedio cero (39% en manufactura sobre insumos). Por origen: 73 informadas los diez años, 101 mixtas, 17 nunca informadas y estimadas despreciables (E0), y 127 nunca informadas y completadas con cero. Solo las primeras son un "no exportó" declarado; las nunca informadas son faltantes completados con cero: Chile en SA, SB y SE (completadas) y en SL (E0). Todas quedan fuera del ANOVA sobre log(valor), porque log(0) no existe. Entran en el Kruskal-Wallis con ceros, en el Friedman, en el RCA y en los percentiles, con la salvedad: en esas celdas, el RCA y el percentil no se interpretan (`08_posicion_paises`, columna `interpretable`).
  - **Atípicos (1,5 RIC sobre el log, por sector):** 16 bajos y 1 alto (EE.UU. en gobierno) en la base al mundo; 9 socios atípicos altos en 7 de 48 combinaciones país-sector en lo bilateral. Se conservan todos. Los bajos son, sobre todo, series intermitentes con varios años en cero dentro del promedio, no economías chicas (`06_atipicos_mundo_detalle`, columna `anios_en_cero`). En lo bilateral son justamente la concentración.
  - **Índices:** se calculan año por año y se promedian en el período. Los socios equivalentes son 1 / (HHI promedio), no el promedio de los 1 / HHI anuales, para que la tabla cumpla siempre la relación (corregido por QA-004, M3). En las tablas, el HHI va en escala 0-10.000 y los CR en %, porque `guardar_tabla` redondea a 2 decimales.
  - **Diversidad:** como en la clase 12, la cantidad de sectores con RCA de Balassa > 1, contra 199 economías (Corea del Norte informa cero en todo). Es diversidad de sectores, no de socios. El "percentil" es la parte de las economías con estrictamente menos sectores con ventaja.
  - **Trampa de datos:** Namibia tiene código ISO "NA". El 05 guarda los faltantes como celda vacía y los scripts leen con `na = ""`. Antes se perdían 1.040 filas en la base bilateral (como socio) y 260 en la base al mundo (como informante).
  - **Funciones:** toda función auxiliar vive en `utils/`, una por archivo (D-008).
- **Por qué:** cada criterio sale de la consigna (faltantes y atípicos con justificación) y de la clase 12. Nada se borra en silencio: todo queda en `06_diagnostico_resumen`.

## D-027 · 27/10/2026 · Resultados de 3.3 que condicionan la hipótesis
- **Hallazgo nuevo de origen** (`06_origen_por_sector`): Brasil informa por socio el total de servicios, pero ninguna apertura por sector (100% estimada). Chile no informa el total por socio, pero sí transporte (15% estimado), viajes (48%) y otros empresariales (64%). En Argentina 2015-2024 tienen más de 50% estimado manufactura, construcción, gobierno y mantenimiento.
- **Total de servicios 2015-2024, con las dos medidas y los dos índices** (`07_comparacion_medidas` y `07_contraste_hipotesis`; versión corregida después de QA-004, C1 y M1):

  | Medida | Índice | AR | BR | CL | UY |
  |---|---|---|---|---|---|
  | Balanceado (principal) | HHI | 878 | 649 | 897 | 674 |
  | Balanceado (principal) | CR4 | 42,3% | 35,6% | 50,1% | 47,0% |
  | Final (sensibilidad) | HHI | 1.196 | 787 | 913 | 676 |
  | Final (sensibilidad) | CR4 | 51,9% | 35,7% | 45,4% | 42,3% |

  - Con el balanceado, Argentina vende como si tuviera 11,4 socios iguales, contra 15,4 de Brasil, 14,8 de Uruguay y 11,1 de Chile. Su CR1 (EE.UU.) es el más alto: 25,7%.
  - Años 2015-2024 en que Argentina supera al vecino en HHI con el balanceado: Brasil 10, Uruguay 10, Chile 5. Con el final: 10 de 10 frente a los tres.
- **Lectura** (D-029): frente a Brasil, la hipótesis se cumple con las dos medidas y los dos índices. Frente a Uruguay, se cumple con el HHI y no con el CR4 del balanceado: Uruguay reparte casi la mitad entre sus cuatro primeros socios, con tamaños parecidos, y el resto muy disperso. Frente a Chile, con la medida principal Argentina no está más concentrada con ningún índice: con el HHI, empatan en años (Argentina arriba en 5 de 10; Chile arriba en 2019 y 2021-2024, con 2021 casi igual, 965 contra 951, y 2023-2024 estimados) y Chile queda algo arriba en promedio (897 contra 878); con el CR4, Chile está más concentrado los 10 años (50,1% contra 42,3%). Con el final, Argentina está más concentrada que Chile con los dos índices, pero el final de Chile es un modelo de gravedad (corregido por QA-004b, M1).
- **Sensibilidad al período:** para Argentina no sirve. En 2005-2014 su distribución por socio es una retroproyección de la que declara desde 2015 (E8.2): con el final, el HHI queda casi fijo (1.128 → 1.196); el salto del balanceado (692 → 878) viene de lo que declaran sus socios, no de Argentina (corregido por QA-004, M4). Sirve para Brasil, comparando 2010-2014 (ya declara por socio) con 2015-2024: 781 → 649 con el balanceado y 882 → 787 con el final. Sus años 2005-2009 también son retroproyección y quedan fuera de la comparación (corregido por QA-004b, m4).
- **Por sector** (balanceado): la concentración de Argentina es la que más varía entre sectores (coeficiente de variación del HHI de 0,84, contra 0,71 de Brasil). Va de 2,0 socios equivalentes en personales, culturales y recreativos (EE.UU. 67%) a 18,9 en transporte, empatado con mantenimiento (corregido por QA-004, M3). Con el final, Argentina varía menos que Brasil (0,55 contra 0,59): "la concentración difiere según el sector" se cumple con las dos medidas, pero "Argentina es la que más varía" solo con el balanceado.
- **Diversidad:** Argentina tiene ventaja en 5 de 12 sectores; el 82,8% de las economías tiene menos. Brasil tiene 4, y Chile y Uruguay 3. Argentina es la canasta de servicios más diversa de los cuatro, aunque esté entre los más concentrados en socios. Las 4 ventajas en cero de Chile son faltantes completados (D-026).
- **Decisión (Timothy, 27/10):** la redacción de D-024 no se toca. Se reporta el contraste tal como sale, sin ajustar la hipótesis al resultado: la consigna premia contrastarla, no confirmarla. El 28/10, con los resultados de QA-004, Timothy fijó cómo se formula el veredicto (D-029).

## D-028 · 27/10/2026 · ANOVA del valor exportado entre sectores (script 08)
- **Decisión (Claude, autónoma, dentro de la hoja de ruta aprobada):**
  - **Base:** la de D-026, 200 economías × 12 sectores, promedio 2015-2024 del valor final. El ANOVA usa las 2.082 celdas positivas sobre log(valor); los 318 ceros entran solo en el Kruskal-Wallis. En logaritmos se comparan medias geométricas, el valor de un "país típico".
  - **Criterio fijado antes de ver los tests de medias (clase 10):** si el cociente de desvíos supera 2 o Levene rechaza, el test principal es Welch y los pares se comparan con Games-Howell. Levene rechazó (F = 13,9; cociente 1,90), así que se usa Games-Howell.
  - **Sin paquetes nuevos:** `rstatix` y `car` no están instalados. Games-Howell (`utils/games_howell.R`) y Levene centrado en la mediana (`utils/test_levene.R`) se escribieron en R base con las fórmulas de esos paquetes. Se validaron con datos simulados: con varianzas iguales, Games-Howell reproduce las diferencias y los p-valores de Tukey.
  - **Control de independencia:** el mismo país aparece en hasta 12 sectores. Se agregó un ANOVA con el país como segundo factor (bloque) para ver si la diferencia entre sectores sobrevive al tamaño de cada país. Como sus residuos cumplen peor los supuestos, se agregó también el test de Friedman, su versión por rangos (R base, con los ceros), que compara los sectores dentro de cada país (agregado después de QA-004).
- **Resultados** (`08_tests`, `08_descriptivos_sectores`, `08_comparaciones_pares`):
  - ANOVA: F(11; 2.070) = 38,9, p < 0,001, eta² = 0,17. Welch, Kruskal-Wallis (con y sin ceros, epsilon² 0,21 y 0,17) y el ANOVA con bloque dan la misma conclusión.
  - Supuestos: los residuos son casi normales en el centro (W = 0,993, asimetría −0,31), con colas que se apartan. Shapiro rechaza por el tamaño de la muestra. Las varianzas difieren (Levene p < 0,001), aunque el cociente de desvíos queda debajo de la regla de 2.
  - Con el país como bloque: F = 154,3; el país explica el 57% de la variabilidad, y el sector, el 20,3% de la SC total. Es el número comparable con el 0,17 del ANOVA simple (el eta² parcial, 0,48, saca al país del denominador y no se compara; corregido por QA-004, M5). El modelo es aditivo: con una observación por país y sector, la interacción no se puede estimar. Sus residuos son menos normales (W = 0,957, asimetría −0,84) y con varianzas más distintas (cociente 3,0) que los del ANOVA simple.
  - Friedman: chi² = 1.220,8 con 11 gl, p < 0,001, W de Kendall = 0,55. Los países ordenan sus sectores de forma parecida: la diferencia no viene del tamaño del país.
  - Ranking de medias geométricas (millones de USD por año): viajes 920, transporte 451, otros empresariales 319 y telecom. 184 forman el grupo alto; propiedad intelectual (9,8) y mantenimiento (11,9) son los más bajos. Viajes supera 94 veces a propiedad intelectual en un país típico.
  - Games-Howell: 41 de 66 pares difieren (Tukey daría 42). Se forman tres bloques: los cuatro sectores grandes (entre ellos no difieren, salvo viajes contra otros empresariales y telecom.), un bloque medio de gobierno, financieros, construcción, manufactura y seguros (sin diferencias entre ellos), y uno bajo de personales, mantenimiento y propiedad intelectual. Los dos últimos se solapan: solo gobierno, financieros y construcción superan a parte del bloque bajo.
  - Posición de los cuatro países (`08_posicion_paises`): Brasil queda entre el percentil 56 y el 91 en todos los sectores (corregido por QA-005, C1: el máximo es 91,46). Argentina va del 39 (construcción) al 84 (personales y culturales). Chile figura en el percentil 0 en manufactura, mantenimiento, construcción y gobierno porque nunca informa esos sectores y OCDE-OMC los completa con cero: no son interpretables (columna `interpretable`).
- **Lectura contra la hipótesis:** la tercera parte ("el valor exportado difiere según el sector") se cumple con todos los métodos. Es una asociación descriptiva entre sector y valor, no una causa.
- **Limitación que va al PDF (reescrita por QA-004, M5):** las celdas de un mismo país no son independientes. Como el país está cruzado con el sector, ignorarlo infla el error: el ANOVA de un factor es conservador, no optimista (la F sube de 38,9 a 154,3 al descontar el país). El modelo con bloque y el Friedman muestran que la conclusión no depende del tamaño de los países.
- **Pares:** la clase 10 usa la regla del cociente (1,90 < 2, que daría Tukey); se agregó Levene, que con n = 2.082 rechaza casi siempre. Como la conclusión no cambia (41 pares contra 42), en el PDF van los dos números.

## D-029 · 28/10/2026 · Medida de la concentración por socio después de QA-004
- **Contexto:** QA-004 (C1, M1) mostró que el HHI de 878 no es "dato informado": se calcula con el balanceado, que combina lo que declara el exportador con lo que declara el importador. Con el valor final (lo que declara cada país, o lo que estima OCDE-OMC), Argentina es la más concentrada de los cuatro: HHI 1.196, contra CL 913, BR 787 y UY 676. Con el balanceado empata con Chile en HHI y, en CR4, queda debajo de Chile y Uruguay.
- **Decisión (Timothy, 28/10):** el balanceado sigue como medida principal (D-023), y el valor final se reporta al lado como sensibilidad. El veredicto se formula así: frente a Brasil, la hipótesis se cumple con las dos medidas y los dos índices; frente a Chile y Uruguay, depende de la medida y del índice.
- **Por qué no el valor final como principal:** el final por socio es dato propio en Argentina, 56% propio en Brasil y 100% estimado por OCDE-OMC en Chile y Uruguay. Comparar el dato de Argentina con un modelo para Chile y Uruguay puede fabricar la diferencia. El balanceado mide a los cuatro de la misma manera: incluye lo que declaran sus compradores. Además, cambiar a la medida que confirma la hipótesis no se puede defender en el oral.
- **Alternativa descartada:** el valor final como medida principal (Timothy lo planteó; se descartó por la falta de comparabilidad).

## D-030 · 28/10/2026 · El repo del TP pasa a ser público (reemplaza D-018 en la visibilidad)
- **Contexto:** el 28/10 el repo figuraba como público en GitHub, aunque D-018 lo fijaba privado hasta la entrega final. Lo detectamos porque Diego (`DS-memek`) veía los cambios sin haber aceptado la invitación de colaborador.
- **Decisión (Timothy, 28/10):** dejarlo público. Diego queda invitado con permiso de escritura, para poder subir cambios.
- **Qué implica:**
  - otros grupos pueden ver el código y los resultados antes de la entrega final;
  - los mails de los commits (el del campus de Timothy, motivo de D-018) quedan a la vista;
  - lo que suba de `gestion/` después del 3.6 (acordado el 28/10, filtrado sin `insumos/`, `herramientas_ppt/` ni las presentaciones) también será público.
- **Sigue vigente de D-018:** la rama `main` y el push con las credenciales de `gh`.

## D-031 · 28/10/2026 · `gestion/` se publica en el repo (reemplaza D-002 en ese punto)
- **Contexto:** D-002 dejaba `gestion/` fuera de git. Timothy propuso publicarla para que el grupo tenga el registro completo y porque muestra un uso ordenado de la IA. La consigna permite la IA en los scripts y la interpretación, y pide limitarla en el armado de la presentación. Para Timothy, apoyar la presentación en textos y gráficos trabajados con IA no es un problema; lo sería que la IA hiciera la presentación entera, y en la Instancia 1 el grupo terminó editando casi todo.
- **Decisión (Timothy, 28/10, con el OK de Diego Díez de los Ríos y Brenda Firmano):**
  - se publica todo `gestion/` (decisiones, hoja de ruta, estado, `qa/`, `handovers/`, `insumos/` y `herramientas_ppt/`), más `CLAUDE.md` y `.claude/agents/`;
  - criterio: toda referencia de un documento publicado tiene que llevar a un archivo del repo; no quedan links que no conduzcan a nada.
- **Cómo se cumplió el criterio:**
  - los scripts y resultados de verificación del QA y del Dev, que vivían en carpetas temporales, se copiaron a `gestion/verificacion/` y las rutas se reescribieron;
  - los de QA-003 y el cruce del HO-003 ya no existían: el texto lo dice;
  - la presentación final de la Instancia 1 se cita con su nombre definitivo.
- **Excepción:** `gestion/insumos/transcripciones/` no se publica, porque son notas de las clases (material de la cátedra). La hoja de ruta lo aclara donde las menciona. También quedan fuera `.claude/settings*.json` (configuración local) y `__pycache__/`.
- **Alternativa descartada:** publicar sin los archivos de la presentación (SES-001, HO-005, QA-005 y QA-005b). Dejaba referencias rotas.
- **Sigue vigente de D-002:** el commit solo después de que Timothy valide el hito.

## D-032 · 28/10/2026 · Los gráficos se alinean con los de la cátedra en la Instancia 3
- **Contexto:** `gestion/insumos/graficos_catedra.md` compara los gráficos del TP con los de las clases 10, 12, 21 y 22. Propone el tema de la casa en `utils/tema_tp.R`, una paleta fija por país, etiquetas directas y pares exploración → comunicación.
- **Decisión (Timothy):** se aplica en la Fase 4 (Instancia 3, 13/11). Los gráficos del PDF de la Instancia 2 quedan como se validaron.
- **Por qué:** el guion de la Instancia 2 ya estaba validado y la entrega vencía al día siguiente. Cambiar las figuras obligaba a otra vuelta de QA y a reemplazar imágenes a último momento. La Instancia 3 es justamente la de visualizaciones.
- **Alternativa descartada:** aplicar ahora solo el tema y la paleta.
