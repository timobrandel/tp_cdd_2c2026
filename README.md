# Exportaciones de servicios: Argentina en comparación con Brasil, Chile y Uruguay (2005–2024)

Trabajo práctico de **Ciencia de Datos para Economía y Negocios** (FCE-UBA, segundo cuatrimestre de 2026, docente Nicolás Sidicaro).

**Integrantes:** Timothy Brandel, Diego Sebastián Díez de los Ríos y Brenda Firmano.

## Objetivo

Describir la evolución y la composición de las exportaciones de servicios de Argentina y compararlas con las de Brasil, Chile y Uruguay entre 2005 y 2024.

La hipótesis que guía el análisis es:

> Entre 2015 y 2024, las exportaciones de servicios de Argentina se concentran en menos socios que las de Brasil, Chile y Uruguay, y tanto esa concentración como el valor exportado difieren según el sector.

El trabajo describe asociaciones; no busca relaciones causales.

## Base de datos

[OECD-WTO Balanced Trade in Services (BaTIS)](https://www.wto.org/english/res_e/statis_e/daily_update_e/), clasificación BPM6, versión publicada el 08/12/2025. Cubre 2005–2024, en millones de USD corrientes.

**Por qué esta base:** es la única fuente que da el comercio de servicios de cada país con cada socio y por sector, con la misma metodología para todos los países. Eso permite comparar los cuatro países y medir la concentración por socio. Trae dos medidas del valor exportado:

- **Valor final:** lo que informa cada país o, si no lo informa, lo que estima OCDE-OMC. Se usa para los totales de cada país y para la comparación entre sectores.
- **Valor balanceado:** concilia lo que declara el exportador con lo que declara el importador. Se usa para la concentración por socio, porque mide a los cuatro países de la misma manera.

Documentación oficial: `raw/OECD-WTO_Batis_methodology_BPM6.pdf` (metodología) y `raw/OECD-WTO_BATIS_BPM6_December2025_codes.xlsx` (códigos).

## Qué se hizo

1. **Descarga y filtrado** (scripts 00 y 01): descarga reproducible desde la OMC y extracción de las exportaciones de servicios de los cuatro países.
2. **Estructura y exploración** (02 a 04): variables, unidad de observación, origen del dato (informado o estimado), evolución, composición, atípicos y comparación de las dos medidas del valor.
3. **Comercio bilateral** (05): bases de los cuatro países con sus 202 socios y de todos los países por sector.
4. **Faltantes y atípicos** (06): datos estimados por OCDE-OMC, ceros según su origen y atípicos con el criterio de 1,5 veces el rango intercuartílico.
5. **Concentración y diversidad** (07): CR1, CR4, índice de Herfindahl-Hirschman (HHI) y socios equivalentes por país y sector; ventaja comparativa revelada de Balassa y cantidad de sectores con ventaja.
6. **Inferencia** (08): ANOVA del logaritmo del valor exportado entre los 12 sectores, con todos los países. Incluye la verificación de supuestos y sus alternativas: Welch, Kruskal-Wallis, ANOVA con el país como bloque, Friedman y comparaciones de Games-Howell.
7. **Diccionario de las bases bilaterales** (09).

## Conclusiones principales (Instancia 2)

- **Frente a Brasil,** Argentina está más concentrada en pocos socios con las dos medidas y con los dos índices (HHI y CR4).
- **Frente a Uruguay,** el resultado depende del índice: Argentina está más concentrada según el HHI, pero no según el CR4 del valor balanceado.
- **Frente a Chile,** con la medida principal, Argentina no está más concentrada: en HHI empatan en años y en CR4 Chile está más concentrado. Con el valor final Argentina queda por encima, pero ahí los socios de Chile salen de un modelo de OCDE-OMC.
- **Por sector,** la concentración de Argentina varía mucho: de 2,0 socios equivalentes en servicios personales, culturales y recreativos a 18,9 en transporte.
- **Diversidad:** Argentina tiene ventaja comparativa en 5 de 12 sectores, más que sus vecinos.
- **Valor exportado:** difiere entre sectores con todos los métodos (ANOVA: F = 38,9, p < 0,001).

## Estructura del repositorio

```
tp_cdd_2c2026/
├── raw/        # Datos originales de la OMC. Los archivos pesados no se suben: los descarga el script 00
├── auxiliar/   # Script original del grupo (referencia; no se corre)
├── input/      # Bases procesadas que usan los scripts de análisis
├── output/
│   ├── tablas/    # Resultados en CSV con formato argentino (se leen con readr::read_csv2)
│   └── graficos/  # Gráficos en PNG
├── script/     # Scripts numerados NN_nombre.R, uno por objetivo
├── utils/      # Funciones propias, una por archivo
├── gestion/    # Registro del trabajo (ver "Proceso de trabajo")
├── CLAUDE.md   # Reglas del proyecto para el asistente de IA
└── .claude/agents/  # Definición de los agentes auditores
```

Los números de las tablas y gráficos de `output/` coinciden con el del script que los genera.

## Cómo reproducir

1. Abrir `tp_cdd_2c2026.Rproj` en RStudio, o trabajar desde la raíz del proyecto. Los scripts usan rutas relativas y no llevan `setwd()`.
2. Instalar los paquetes: `tidyverse`, `scales`, `readxl`, `DBI` y `duckdb`.
3. Correr los scripts en orden, del 00 al 09, cada uno en una sesión limpia:

   ```bash
   Rscript script/00_descarga_datos.R
   ```

   - El 00 baja unos 500 MB de la OMC una sola vez; si los archivos ya están en `raw/`, no los vuelve a bajar.
   - El 01 y el 05 leen el CSV completo de BaTIS (casi 3 GB) con DuckDB; tardan unos segundos.
   - Del 06 en adelante solo se usan las bases de `input/`.

Las bases de `input/` se leen con `read_csv(..., na = "")`: el código ISO de Namibia es "NA" y, sin esa opción, R lo toma como dato faltante.

## Proceso de trabajo

El trabajo se organizó con un registro escrito, que está en `gestion/`:

- `hojaderuta.md`: los pasos de cada instancia, con su criterio de cierre.
- `decisiones.md`: cada decisión técnica (D-001 a D-031), con su contexto, las alternativas descartadas y quién la tomó.
- `estadodelproyecto.md`: en qué punto está el trabajo.
- `qa/` y `handovers/`: cada bloque se auditó con un revisor independiente, que vuelve a correr los scripts desde cero, recalcula las cifras y las contrasta con la consigna. Los handovers explican qué se entregó a cada auditoría.
- `verificacion/`: los scripts con los que se recalcularon las cifras en cada auditoría, y sus resultados.
- `insumos/`: el material de apoyo de las presentaciones (cifras, revisiones y guion) y las versiones de la presentación de la Instancia 1.
- `herramientas_ppt/`: scripts que aplicaron correcciones de texto a la presentación de la Instancia 1.

**Uso de IA.** Como permite la consigna, el código, la interpretación y el material de apoyo de las presentaciones se trabajaron con un asistente de IA (Claude Code), y las auditorías las hizo otro agente de IA independiente. Las decisiones que condicionan los resultados, como la hipótesis o la medida del valor exportado, las tomaron los integrantes, y el registro indica en cada caso quién decidió. Las presentaciones las armó el grupo, sobre ese material.

Las transcripciones de las clases que se usaron como referencia no se publican, porque son material de la cátedra.
