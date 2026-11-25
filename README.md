# Exportaciones de servicios: Argentina en comparación con Brasil, Chile y Uruguay (2005–2024)

Trabajo práctico del **Grupo 26** de Ciencia de Datos para Economía y Negocios (FCE-UBA, segundo cuatrimestre de 2026, docente Nicolás Sidicaro).

**Integrantes:** Timothy Brandel, Diego Sebastián Díez de los Ríos y Brenda Firmano.

## Objetivo

Describir la evolución, la composición y los destinos de las exportaciones de servicios de Argentina. Comparamos los resultados con Brasil, Chile y Uruguay entre 2005 y 2024.

La hipótesis que guía el análisis es:

> Entre 2015 y 2024, las exportaciones de servicios de Argentina se concentran en menos socios que las de Brasil, Chile y Uruguay, y tanto esa concentración como el valor exportado difieren según el sector.

El trabajo describe asociaciones. El análisis bilateral principal empieza en 2015, cuando Argentina empieza a declarar destinos de forma comparable.

## Base de datos

[OECD-WTO Balanced Trade in Services (BaTIS)](https://www.wto.org/english/res_e/statis_e/daily_update_e/), clasificación BPM6 / EBOPS 2010, edición de diciembre de 2025. Cubre 2005–2024, con observaciones anuales en millones de USD corrientes.

**Por qué esta base:** BaTIS reúne datos de comercio de servicios por país, socio y sector con una metodología común. Eso permite comparar los cuatro países y medir la concentración por socio. Para el análisis usamos dos medidas del valor exportado:

- **Valor final:** parte de lo que informa cada país. OCDE–OMC deriva o estima valores donde falta información. Usamos esta medida para los totales al mundo, el RCA y el ANOVA.
- **Valor balanceado:** concilia lo que declara el exportador con lo que declara el importador. Lo usamos para concentración y destinos. Repetimos esos cálculos con el valor final para ver cuánto cambia el resultado.

Documentación oficial: [metodología BaTIS](raw/OECD-WTO_Batis_methodology_BPM6.pdf) y [diccionario de códigos](raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx).

| Base procesada | Unidad de observación | Filas × variables |
| --- | --- | ---: |
| `batis_filtrada.csv` | Exportador × ítem × año, destino mundo | 1.040 × 12 |
| `batis_bilateral.csv` | Exportador × socio × ítem × año | 207.480 × 11 |
| `batis_mundo_sectores.csv` | Exportador × ítem × año, destino mundo | 51.870 × 10 |

Chile y Uruguay no declaran la distribución por socio del total de servicios. Chile sí aporta información parcial para algunos sectores. El diccionario y el Anexo H de BaTIS permiten interpretar los códigos. El trabajo usa BaTIS como única base de datos.

## Qué se hizo

1. **Descarga y filtrado inicial** ([00](script/00_descarga_datos.R) y [01](script/01_filtrado_batis.R)). El 00 descarga los originales desde la OMC. El 01 guarda `input/batis_filtrada.csv` y controla el tamaño y los nulos de la fuente.
2. **Estructura y exploración** ([02](script/02_estructura_variables.R) a [04](script/04_comparacion_medidas.R)). El 02 registra variables, unidades y origen con el diccionario y el Anexo H. El [03](script/03_exploracion.R) guarda las descriptivas y los gráficos de evolución y composición. El 04 compara las dos medidas del valor exportado.
3. **Comercio bilateral** ([05](script/05_filtrado_bilateral.R)). A partir del CSV original y el diccionario, guarda la base bilateral de cuatro exportadores y la base de exportaciones al mundo por sector.
4. **Faltantes y atípicos** ([06](script/06_faltantes_atipicos.R)). Lee las dos bases del 05 y describe los faltantes, el origen de los ceros y los valores extremos. Identifica atípicos con la regla de 1,5 rangos intercuartílicos. La [tabla de sensibilidad](output/tablas/06_descriptivas_sensibilidad.csv) compara las 2.400 celdas, las 2.082 positivas y las 2.065 positivas sin atípicos.
5. **Concentración y diversidad** ([07](script/07_concentracion_socios.R)). Lee las bases del 05. Guarda CR1, CR4, el índice de Herfindahl–Hirschman (HHI), socios equivalentes, los principales destinos y el RCA de Balassa.
6. **Inferencia** ([08](script/08_anova_sectores.R)). Lee la base mundial del 05 y guarda descriptivas sectoriales, diagnósticos, contrastes y gráficos. Incluye Welch, Kruskal–Wallis, ANOVA con bloque país, Friedman y comparaciones de Games–Howell.
7. **Diccionario** ([09](script/09_tabla_variables_bilateral.R)). Lee las bases del 05 y guarda el [diccionario de variables](output/tablas/09_tabla_variables.csv), con tipos, unidades y faltantes.
8. **Destinos por servicio** ([10](script/10_destinos_sectores.R)). Lee la base bilateral del 05 y la cobertura sectorial que guarda el 07. Calcula qué porcentaje compra cada destino sobre todos los socios identificados. Verifica el patrón con ambas medidas y guarda la tabla de destinos y los JPG [exploratorio](output/graficos/grupo_26_exploratorio.jpg) y [comunicativo](output/graficos/grupo_26_comunicativo.jpg).

## Conclusiones principales

- **Frente a Brasil,** Argentina está más concentrada en pocos socios con las dos medidas y con los dos índices (HHI y CR4).
- **Frente a Uruguay,** el resultado depende del índice: Argentina está más concentrada según el HHI, pero no según el CR4 del valor balanceado.
- **Frente a Chile,** con la medida principal, Argentina no está más concentrada: en HHI empatan en años y en CR4 Chile está más concentrado. Con el valor final Argentina queda por encima, pero ahí los socios de Chile salen de un modelo de OCDE-OMC.
- **Por sector,** la concentración de Argentina varía mucho: de 2,0 socios equivalentes en servicios personales, culturales y recreativos a 18,9 en transporte.
- **Diversidad:** Argentina tiene ventaja comparativa en 5 de 12 sectores, más que sus vecinos.
- **Valor exportado:** en la muestra mundial, el ANOVA simple da F(11, 2070) = 38,87, p < 0,001 y η² = 0,17. Usa las 2.082 celdas positivas y conserva los 17 atípicos. Welch compara medias con varianzas desiguales. Friedman compara rangos dentro de cada país e incluye los ceros.
- **Destinos:** EE. UU. explica el 25,5 % del acumulado argentino a socios identificados. En viajes, Sudamérica representa 42,5 % y EE. UU. 13,2 %. En servicios personales, culturales y recreativos, representan 8,6 % y 70,8 %, respectivamente.

## Estructura del repositorio

```
tp_cdd_2c2026/
├── raw/        # Datos originales de la OMC. Los archivos pesados no se suben: los descarga el script 00
├── auxiliar/   # Códigos del Anexo H y script original del grupo como referencia
├── input/      # Bases procesadas que usan los scripts de análisis
├── output/
│   ├── tablas/    # Resultados en CSV con formato argentino (se leen con readr::read_csv2)
│   └── graficos/  # Gráficos en PNG y JPG
├── script/     # Scripts numerados NN_nombre.R, uno por objetivo
├── utils/      # Funciones propias, una por archivo
├── gestion/    # Registro del trabajo (ver "Proceso de trabajo")
├── CLAUDE.md   # Reglas del proyecto para el asistente de IA
└── .claude/agents/  # Definición de los agentes auditores
```

Los números de las tablas y gráficos de `output/` coinciden con el del script que los genera.

## Cómo reproducir

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

El 00 descarga unos 500 MB la primera vez. Reutiliza los archivos presentes en `raw/`. El 01 y el 05 consultan con DuckDB el CSV de casi 3 GB. A partir del 06, los scripts trabajan con archivos procesados.

Las bases procesadas se leen con `read_csv(..., na = "")` donde corresponde. Así R conserva `NA`, el código ISO de Namibia. Las tablas de resultados se leen con `readr::read_csv2()`.

## Proceso de trabajo

El trabajo se organizó con un registro escrito, que está en `gestion/`:

- `hojaderuta.md`: los pasos de cada instancia, con su criterio de cierre.
- [`decisiones.md`](gestion/decisiones.md): cada decisión técnica, con su contexto, las alternativas descartadas y quién la tomó.
- `estadodelproyecto.md`: en qué punto está el trabajo.
- `qa/` y `handovers/`: cada bloque se auditó con un revisor independiente, que vuelve a correr los scripts desde cero, recalcula las cifras y las contrasta con la consigna. Los handovers explican qué se entregó a cada auditoría.
- `verificacion/`: los scripts con los que se recalcularon las cifras en cada auditoría, y sus resultados.
- `insumos/`: el material de apoyo de las presentaciones (cifras, revisiones y guion) y las versiones de la presentación de la Instancia 1.
- `herramientas_ppt/`: scripts que aplicaron correcciones de texto a la presentación de la Instancia 1.

**Uso de IA.** El grupo usó asistentes de IA para apoyar el código, la interpretación y el material de las presentaciones. Otro asistente realizó verificaciones independientes. Los integrantes tomaron las decisiones metodológicas, como la hipótesis y la medida del valor exportado, y armaron la presentación final.
