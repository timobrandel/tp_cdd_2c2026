# ¿A quién le vende servicios Argentina?

**Grupo 26 · Ciencia de Datos para Economía y Negocios · FCE-UBA · 2.º cuatrimestre de 2026**

**Integrantes:** Timothy Brandel, Diego Sebastián Díez de los Ríos y Brenda Firmano.

**Docente:** Nicolás Sidicaro.

## Pregunta e hipótesis

Comparamos la evolución, la composición y los destinos de las exportaciones de servicios de Argentina, Brasil, Chile y Uruguay.

La hipótesis propone que, entre 2015 y 2024, Argentina concentra sus exportaciones en menos socios que sus tres vecinos. También propone que la concentración por destino y el valor exportado difieren entre sectores. La especialización relativa complementa la hipótesis y describe qué exporta cada país.

## Datos y decisiones

Usamos la edición de diciembre de 2025 de [OECD–WTO Balanced Trade in Services (BaTIS)](https://www.wto.org/english/res_e/statis_e/daily_update_e/), con clasificación BPM6 y EBOPS 2010. La base cubre 2005–2024, con valores anuales en millones de USD corrientes.

| Base procesada | Unidad de observación | Filas × variables | Uso |
| --- | --- | ---: | --- |
| `batis_filtrada.csv` | Exportador × ítem × año, destino mundo | 1.040 × 12 | Evolución y composición de los cuatro países |
| `batis_bilateral.csv` | Exportador × socio × ítem × año | 207.480 × 11 | Concentración por socio y gráficos de destinos |
| `batis_mundo_sectores.csv` | Exportador × ítem × año, destino mundo | 51.870 × 10 | Especialización y comparación entre sectores |

La cobertura de las bases es 2005–2024. Usamos 2015–2024 para los métodos principales porque Argentina empieza a declarar destinos en 2015. Conservamos 2005–2024 como contexto de evolución y composición. El ANOVA usa una celda por economía y sector, con el promedio anual del decenio.

- **Valor final:** dato informado, derivado o completado por OCDE–OMC. Lo usamos para totales al mundo, RCA y ANOVA.
- **Valor balanceado:** estimación que concilia las dos direcciones de reporte de un mismo flujo bilateral. Lo usamos para concentración y destinos. El valor final bilateral sirve como sensibilidad.
- **Cobertura:** los totales bilaterales de Chile y Uruguay carecen de distribución por socio declarada por el exportador. La calidad de la información también cambia entre sectores.
- **Faltantes y atípicos:** conservamos las cifras completadas por OCDE–OMC y los atípicos detectados. El ANOVA sobre logaritmos toma celdas positivas. La sensibilidad muestra el efecto de conservar ceros o retirar atípicos.
- **Archivos auxiliares:** no cruzamos bases externas. El diccionario de BaTIS aporta etiquetas de economías. Una transcripción del Anexo H completa cuatro códigos metodológicos.

Consultá el [diccionario de variables](output/tablas/09_tabla_variables.csv), el [diagnóstico de cobertura](output/tablas/06_diagnostico_resumen.csv) y las [descriptivas de sensibilidad](output/tablas/06_descriptivas_sensibilidad.csv).

## Métodos y resultados

| Método | Pregunta | Resultado |
| --- | --- | --- |
| Concentración con HHI, CR1 y CR4 | ¿Cuánto pesan los socios principales? | Argentina supera a Brasil en HHI y CR4 con ambas medidas. Frente a Chile y Uruguay, la lectura depende del indicador y la medida. |
| Ventaja comparativa revelada (RCA) | ¿Qué sectores tienen más peso en la canasta argentina que en la mundial? | Argentina tiene RCA mayor que uno en 5 de los 12 sectores. |
| ANOVA sobre el logaritmo del valor exportado y pruebas complementarias | ¿Difiere el valor exportado típico entre sectores? | El ANOVA simple de referencia da F(11, 2070) = 38,87, p < 0,001 y η² = 0,17. Welch y Friedman también encuentran diferencias sectoriales. |

Levene detecta varianzas desiguales. Usamos Welch como contraste principal de medias, aunque comparte el supuesto de independencia entre observaciones. Friedman compara rangos dentro de cada país e incluye las 318 celdas con promedio cero. Los tres resultados corresponden a la muestra mundial, con 200 economías y 12 sectores antes del filtro de positivos.

Argentina registra de 2,0 socios equivalentes en servicios personales, culturales y recreativos a 18,9 en transporte. Estados Unidos explica el 25,5 % del valor bilateral identificado que Argentina acumuló en 2015–2024. La orientación geográfica cambia según el servicio. Los resultados describen asociaciones.

Visualizaciones de la tercera instancia: [exploratoria](output/graficos/grupo_26_exploratorio.jpg) y [comunicativa](output/graficos/grupo_26_comunicativo.jpg).

El [script 10](script/10_destinos_sectores.R) cruza la base bilateral con la cobertura sectorial que guarda el script 07. Acumula los flujos de 2015–2024, excluye los socios sin identificar (`ROW`) y calcula las participaciones de Sudamérica y Estados Unidos. El denominador reúne **todos** los socios identificados de cada exportador y rubro. Antes de guardar los JPG, el script verifica que el orden entre los dos destinos se mantenga en los seis rubros argentinos del gráfico comunicativo. Usa tanto el valor final como el balanceado.

## Arquitectura del repositorio

| Ruta | Contenido |
| --- | --- |
| [`raw/`](raw/) | Originales de BaTIS. El script 00 descarga y extrae el archivo pesado desde la OMC. |
| [`auxiliar/`](auxiliar/) | Códigos del Anexo H que lee el script 02 y antecedente de código del grupo. |
| [`input/`](input/) | Bases filtradas que leen los scripts de análisis. |
| [`script/`](script/) | Scripts numerados, con entradas y salidas en el encabezado. |
| [`utils/`](utils/) | Funciones que los scripts cargan con `source()`. |
| [`output/tablas/`](output/tablas/) | Tablas en CSV con coma decimal y separador de punto y coma. En R, usar `readr::read_csv2()`. |
| [`output/graficos/`](output/graficos/) | Figuras en PNG y JPG exportadas en R con `ggsave()`. |
| [`gestion/`](gestion/) | Decisiones, revisiones y antecedentes del grupo. |

El [registro de decisiones](gestion/decisiones.md) documenta las elecciones metodológicas. El grupo usó asistentes de IA como apoyo para los scripts, la interpretación, las verificaciones y el material de presentación. Los integrantes definieron las decisiones metodológicas y prepararon la presentación final.

## Reproducción desde un clon

1. Cloná el repositorio y trabajá desde la raíz. En RStudio, abrí `tp_cdd_2c2026.Rproj`.
2. Instalá los paquetes una sola vez desde la consola de R. Usamos R 4.6.1 para la comprobación local.

   ```r
   install.packages(c("tidyverse", "scales", "readxl", "DBI", "duckdb", "ggtext", "ggrepel"))
   ```

3. Corré cada script en una sesión limpia. Reservá al menos 4 GB para la descarga y la extracción de los datos originales.

   ```powershell
   $rscript = "Rscript"
   foreach ($archivo in (Get-ChildItem script/*.R | Sort-Object Name)) {
     & $rscript --vanilla $archivo.FullName
     if ($LASTEXITCODE -ne 0) { throw "Falló $($archivo.Name)" }
   }
   ```

   Si Windows no encuentra `Rscript`, asigná a `$rscript` la ruta de tu instalación de R.
   Usá PowerShell normal si el lanzador omite `PROCESSOR_ARCHITECTURE`.
   Si el lanzador heredó el locale Unix `C.UTF-8`, ajustá `LANG`, `LC_ALL` y `LC_CTYPE` a `.UTF-8` para ese proceso.

   En macOS o Linux, usá lo siguiente desde la raíz.

   ```sh
   for archivo in script/*.R; do
     Rscript --vanilla "$archivo" || exit 1
   done
   ```

### Paquetes y funciones

| Etapa | Paquetes | Qué hacen |
| --- | --- | --- |
| Filtrado del crudo (01 y 05) | `DBI`, `duckdb` | `DBI` conecta R con DuckDB, que filtra el CSV antes de cargar el subconjunto en R. |
| Lectura y transformación | `readxl`, `readr`, `dplyr`, `tidyr` | `readxl` lee el diccionario. `readr`, `dplyr` y `tidyr` integran `tidyverse` y leen, agrupan o reordenan las tablas. |
| Gráficos (03, 04, 06, 07, 08 y 10) | `ggplot2`, `scales` | `ggplot2` integra `tidyverse`. Dibuja las capas y exporta con `ggsave()`. `scales` formatea ejes y porcentajes. |
| Gráficos de destinos (10) | `ggtext`, `ggrepel` | `ggtext` aplica color al texto del título. `ggrepel` acomoda las etiquetas del exploratorio para reducir solapamientos. |
| Inferencia (08) | `stats` y funciones de `utils/` | `stats` viene con R. El repositorio implementa Levene y Games–Howell en funciones propias. |

Para **regenerar solo los dos JPG** desde las salidas versionadas, verificá que estén `input/batis_bilateral.csv` y `output/tablas/07_concentracion_sectores.csv`. Con los paquetes instalados y desde la raíz, corré `Rscript --vanilla script/10_destinos_sectores.R`. El script actualiza la tabla de destinos y los dos JPG de 300 dpi. Para reconstruir las bases desde la fuente, corré la secuencia completa.

### Orden de los scripts

| Orden | Entrada principal | Qué genera |
| --- | --- | --- |
| [00 Descarga](script/00_descarga_datos.R) | Sitio de la OMC | ZIP, CSV original, diccionario y metodología en `raw/`. |
| [01 Filtrado inicial](script/01_filtrado_batis.R) | CSV de BaTIS | `input/batis_filtrada.csv`, dimensiones y nulos de la base completa. |
| [02 Estructura](script/02_estructura_variables.R) | Base filtrada, tabla 01, diccionario y Anexo H | Diccionario analítico, unidad de observación y origen de datos. |
| [03 Exploración](script/03_exploracion.R) | Base filtrada | Descriptivas, evolución, composición y gráficos de contexto. |
| [04 Comparación de medidas](script/04_comparacion_medidas.R) | Base filtrada | Tablas y gráficos con valor final y balanceado. |
| [05 Filtrado bilateral](script/05_filtrado_bilateral.R) | CSV original y diccionario | Dos bases procesadas, controles de cobertura y diagnóstico bilateral. |
| [06 Calidad y sensibilidad](script/06_faltantes_atipicos.R) | Bases del script 05 | Faltantes, ceros, atípicos, descriptivas comparables y gráficos de diagnóstico. |
| [07 Concentración y RCA](script/07_concentracion_socios.R) | Bases del script 05 | Índices, principales socios, RCA y gráficos de resultados. |
| [08 Inferencia](script/08_anova_sectores.R) | Base mundial del script 05 | Descriptivas sectoriales, pruebas, comparaciones por pares y figuras. |
| [09 Diccionario](script/09_tabla_variables_bilateral.R) | Bases del script 05 | Variables y unidades de observación de las dos bases. |
| [10 Destinos](script/10_destinos_sectores.R) | Base bilateral y tabla de concentración del 07 | Tabla de destinos y dos JPG del grupo 26. |

En las bases bilaterales, `na = ""` preserva `NA`, el código ISO de Namibia. Los datos crudos pesados superan el límite de GitHub. El script 00 los recupera desde su fuente y el repositorio incluye las bases procesadas.
