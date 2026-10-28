# TP Ciencia de Datos FCE-UBA 2C2026 · Exportaciones de servicios (BaTIS)

@gestion/estadodelproyecto.md

## Proyecto
- TP grupal de "Ciencia de Datos para Economía y Negocios" (FCE-UBA, docente Nicolás Sidicaro). Herramienta de la cátedra: R + RStudio.
- Tema: "Evolución y composición de las exportaciones de servicios: Argentina en comparación con Brasil, Chile y Uruguay · 2005–2024".
- Base: OECD-WTO Balanced Trade in Services (BaTIS), BPM6, versión publicada el 08/12/2025 (2005–2024). Descarga oficial reproducible: `script/00_descarga_datos.R`.
- Entregas: Instancia 1 (EDA; solo .pptx de 8–12 diapositivas) · Instancia 2, 27/10 (métodos) · Instancia 3, 13/11 (visualizaciones) · Final, 24/11 (PPT de 15–20 diapositivas + repo GitHub) · Orales, 24/11–01/12.
- Repo remoto: https://github.com/timobrandel/tp_cdd_2c2026 (público desde el 28/10, D-030).

## Al iniciar cada sesión
1. La tarjeta de estado ya está cargada arriba (import). Trabajá sobre el "próximo paso aprobado"; no abras otro tema sin cerrar el actual.
2. De `gestion/hojaderuta.md`, leé solo la fase en curso y sus criterios de cierre.
3. Ante un "¿por qué se hizo así?", buscá primero en `gestion/decisiones.md`. Lo registrado no se re-discute sin un motivo nuevo.

## Al cerrar un bloque o la sesión
- Reescribí `gestion/estadodelproyecto.md` (tarjeta corta, no bitácora).
- Toda decisión nueva va a `gestion/decisiones.md` (D-NNN: contexto, decisión, alternativas, por qué).
- Commit solo al cerrar un hito que Timothy validó (D-002). Mensaje en castellano.
- Push con las credenciales de `gh` (D-018): `git -c credential.helper= -c "credential.helper=!gh auth git-credential" push`. `git push` a secas puede abrir la ventana de login de Git Credential Manager y trabar el comando.

## Estructura (la exige la consigna final; no inventar carpetas)
| Carpeta | Contenido |
|---|---|
| `raw/` | Datos originales tal como se descargaron. Los pesados quedan fuera de git (D-010) |
| `auxiliar/` | Diccionarios y archivos de apoyo. `BATIS_original_companero.R` = script original del grupo (referencia; no se corre) |
| `input/` | Datos procesados, listos para analizar |
| `output/tablas/`, `output/graficos/` | Resultados generados por los scripts |
| `script/` | Scripts numerados `NN_nombre.R`, un objetivo cada uno (en singular, D-008) |
| `utils/` | Funciones propias, una por archivo |
| `gestion/` | Espacio de trabajo con Claude: estado, hoja de ruta, decisiones, `handovers/`, `qa/`, `insumos/` (fuera de git) |

## Reglas de código R
- Ejecutar siempre desde la raíz del TP con `"C:/Program Files/R/R-4.6.1/bin/Rscript.exe" script/NN_nombre.R` (Rscript no está en el PATH). Es el test de reproducibilidad de la cátedra: sesión limpia, sin depender del Environment.
- Rutas relativas a la raíz (`raw/...`, `input/...`). Nunca `setwd()` ni rutas absolutas dentro de los scripts.
- Encabezado obligatorio: Script / Objetivo / Entrada / Salida (formato de `organizacion_proyectos_cdd.md`).
- `library()` explícitos al principio, lógica no obvia comentada, código autocontenido: Timothy copia y ejecuta, no escribe código.
- tidyverse para manipular; DuckDB solo para filtrar el CSV grande (D-011). Gráficos con ggplot2 y `ggsave()` a `output/graficos/`.
- Toda tabla o gráfico va con una frase que lo interprete; los NA y outliers se explican, no se borran en silencio (advertencias del docente, clase 08).
- Paquetes instalados: tidyverse, readxl, janitor, skimr, knitr, DBI, duckdb. Instalar otro requiere OK de Timothy.

## Flujo Dev → QA (D-004)
1. El Dev cierra un bloque y escribe `gestion/handovers/HO-NNN.md`: objetivo, archivos tocados, cómo correrlo, cifras clave, supuestos, dudas.
2. El Dev lanza el subagente `qa-auditor` con: "Auditá gestion/handovers/HO-NNN.md".
3. El QA escribe `gestion/qa/QA-NNN.md` con veredicto (APROBADO / APROBADO CON OBSERVACIONES / RECHAZADO) y evidencia.
4. El Dev corrige y relanza el QA: máximo 2 vueltas; si persiste, escala a Timothy.
5. Timothy valida → commit → se actualiza el estado.
El QA corre por bloque cerrado, no por cada cambio chico (costo en tokens).

## Reglas de la cátedra que condicionan el trabajo
- IA permitida para scripts e interpretación; la cátedra pide limitarla en el armado de la PPT. La PPT la arma el grupo; Claude entrega tablas, gráficos, cifras y guion (D-007).
- En el oral preguntan por el código y las decisiones: toda decisión técnica se explica en términos que Timothy pueda defender.
- El TP no es causal: se describen asociaciones.

## Requisitos del TP (consignas; detalle por instancia en `gestion/hojaderuta.md`)
- Todas las entregas son obligatorias y deben aprobarse; se puede recuperar una sola instancia intermedia. Pesos según la consigna del TP: Instancia 1 10%, Instancia 2 20%, Instancia 3 10%, final 60% con el oral incluido (el README del curso dice 10% para cada instancia).
- La hipótesis de trabajo guía todo el TP, y cada método y visualización tiene que apoyarla. Todavía no está formulada (paso 2.5).
- Entrega final: al menos 3 métodos además de los descriptivos. Como mínimo, uno estadístico de la Unidad 2, con sus supuestos verificados (y corregidos si no se cumplen), y una herramienta cuantitativa de la Unidad 3.
- Todo método, tabla y gráfico va interpretado. Los faltantes y los outliers se analizan y se explican.
- Repo final:
  - se usan todas las carpetas: raw → input → output;
  - cada script tiene un objetivo;
  - una función por archivo en `utils/`;
  - el README en Markdown cubre objetivo, justificación de la base, qué se hizo, estructura de carpetas y cómo reproducir.
- Oral virtual: participan todos los integrantes, y el foco está en entender el código y las decisiones.

## Hechos de la base que condicionan cualquier análisis
- **Medida del valor exportado.** D-015 usa `Final_value`, la balanza de pagos que informa cada país. El compañero que armó la PPT defiende `Balanced_value` y el grupo todavía decide: ver la tarjeta de estado.
  - La metodología (secciones 5.1 y 6) respalda el balanceado para flujos bilaterales, no para el total de cada país.
  - Además, el balanceado se aparta del valor informado de forma cambiante: Argentina queda entre −2,8% y −18,5%, y Chile llega a +57%.
- **Chile.** Sus 13 ítems de 2023–2024 son estimaciones de OCDE-OMC. Además, nunca informa cuatro categorías chicas (SA, SB, SE, SL), que se completan con ceros. Toda comparación a 2024 que incluya a Chile lleva esa salvedad.
- **Unidades.** Millones de USD corrientes, sin deflactar: el crecimiento incluye la inflación de EE.UU.
- **Documentación.**
  - Metodología oficial: `raw/OECD-WTO_Batis_methodology_BPM6.pdf`.
  - Diccionario: `raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx`.
  - Los códigos R_OECD, E2, E3 y E5 no están en el Excel; están en el Anexo H del PDF.

## Particularidades del entorno (Windows)
- `Rscript -e` con código de varias líneas se cuelga (segfault). Usar archivos `.R`. Los archivos temporales van en la carpeta temporal del sistema, nunca dentro del proyecto.
- Python imprime en cp1252: si la salida tiene caracteres especiales, usar `PYTHONIOENCODING=utf-8`.
- Las tablas de `output/tablas/` están en formato Excel argentino (D-016): se leen con `readr::read_csv2()`.
- `01_filtrado_batis.R` lee 2,98 GB y tarda unos 25 segundos.
- Namibia tiene código ISO "NA": las bases de `input/` del 05 en adelante se leen con `read_csv(..., na = "")` (D-026). Sin eso, R la toma como faltante.

## Repo del curso (solo lectura, cero commits)
Ruta: `C:/Users/timob/Documents/Codex/2026-08-28/es/curso_cdd_fce_uba_2c2026` (abajo, `CURSO/`). Se actualiza con `git pull` solo cuando Timothy lo pida.
| Qué | Dónde |
|---|---|
| Consigna vigente de la Instancia 1 | `CURSO/trabajo_practico/consignas_instancia_1.md` |
| Consigna del TP completo (fechas viejas) | `CURSO/trabajo_practico/consignas_trabajo_final.md` |
| Guía de README del TP | `CURSO/trabajo_practico/guia_readme.md` |
| Organización de proyectos, rutas, reproducibilidad | `CURSO/materiales_utiles/organizacion_proyectos_cdd.md` |
| Instalación de R/RStudio y proyectos .Rproj | `CURSO/materiales_utiles/GUIA_INSTALACION_R.md` |
| Git y GitHub | `CURSO/materiales_utiles/GUIA_GIT_GITHUB.md` |
| Regresión en R (opcional) | `CURSO/materiales_utiles/guia_regresion_en_R.html` |
| Clase 02: intro a R | `CURSO/clases/clase02/` |
| Clase 03: tidyverse, joins (PDF) | `CURSO/clases/clase03/` |
| Clase 04: tidyverse, lectura y verbos | `CURSO/clases/clase04/` |
| Clase 05: ponderación, agregación, distribuciones (PDF) | `CURSO/clases/clase05/` |
| Clase 06: estadística descriptiva con EPH | `CURSO/clases/clase06/` |
| Clase 07: inferencia por remuestreo (bootstrap, permutaciones) | `CURSO/clases/clase07/` |
| Clase 08: EDA completo, modelo de la Instancia 1 (checklist del docente en la sección 9) | `CURSO/clases/clase08/practica-1-eda-completo-wdi.R` |
| Clases 09–10: t-test, Mann-Whitney, ANOVA, Tukey, chi² | `CURSO/clases/clase09/`, `CURSO/clases/clase10/` |
| Clase 11: índices económicos (PDF) | `CURSO/clases/clase11/` |
| Clase 12: concentración y comercio internacional (BACI), Gini/Theil (EPH) | `CURSO/clases/clase12/` |
| Funciones descriptivas ponderadas | `CURSO/utils/estadisticas_descriptivas_ponderadas.R` |
| Material interactivo | `CURSO/interactivo/` |
Clases grabadas: carpeta de Google Drive linkeada en `CURSO/README.md` (transcripciones pendientes, ver hoja de ruta).
