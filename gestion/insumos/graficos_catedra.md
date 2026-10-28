# Gráficos de la cátedra y cómo llevarlos al TP

## De dónde sale
No hizo falta sacar fotogramas de las grabaciones: los gráficos que Sidicaro mostró en clase están en el repo del curso, como PDF y como código R que los genera.

| Fuente | Qué tiene |
|---|---|
| `CURSO/clases/clase21/viz_clase01_introduccion_visualizacion.pdf` (68 diap.) | Teoría de la Unidad 4: elegir el gráfico según la pregunta, comunicar contra explorar, buenas prácticas y taller de crítica |
| `CURSO/clases/clase22/clase22_visualizacion_ggplot2.pdf` (51 diap.) | ggplot2 capa por capa (WDI 2019) |
| `CURSO/clases/clase22/clase22_graficos_varios.R` | Galería "estilo de la casa" con 10 gráficos: líneas base 100, boxplot con violín, barras ordenadas, dispersión, slope chart, dumbbell, ECDF, lollipop, connected scatter |
| `CURSO/clases/clase12/01_concentracion_baci.R` y `02_comercio_baci.R` | Los gráficos de **concentración (HHI) y RCA**: es el mismo método que usamos |
| `CURSO/clases/clase10/clase10_script.R` | Gráficos del **ANOVA**: boxplot con puntos por grupo, en escala log |

Las transcripciones de `gestion/insumos/transcripciones/` cubren las clases 10 a 18. No están las de visualización (21 y 22), pero sus PDF tienen las mismas diapositivas que se proyectaron.

## El estilo de la cátedra (clase 22, "tema de la casa")
```r
theme_minimal(base_size = 12) +
  theme(plot.title       = element_text(face = "bold", size = 13),
        plot.subtitle    = element_text(color = "gray40", size = 10),
        plot.caption     = element_text(color = "gray50", hjust = 0),
        panel.grid.minor = element_blank(),
        legend.position  = "bottom")
```
- Colores: `steelblue` para el dato y `tomato` para el contraste o la referencia (línea en 1 para el RCA, extremos del HHI). En las series, `scale_color_brewer(palette = "Set1")`.
- Principios de la clase 21 que el docente va a buscar:
  - **título informativo** (dice la conclusión, no el tema);
  - **color con función** (diap. 52: resalta lo que importa y atenúa el resto en gris);
  - el **mismo color para el mismo país** en todo el informe;
  - **etiquetas directas** en vez de leyenda;
  - barras desde cero y **ordenadas por valor**;
  - unidades, período, fuente y notas metodológicas siempre visibles;
  - **par exploración → comunicación**: un gráfico denso para explorar y uno limpio que aísla el mensaje.

## Dónde estamos
Ya cumplimos la parte de contenido: títulos que dicen la conclusión, fuente y salvedades en el pie, escala log explicada, sombreado del período del análisis, marca de los datos estimados.

Falta lo visual:
1. **Tema:** `tema_tp` es `theme_minimal()` con el pie a la izquierda. Le faltan el título en negrita, el subtítulo gris y sacar la grilla menor. Además está copiado en 5 scripts (03, 04, 06, 07, 08): va a `utils/tema_tp.R`, una función por archivo, como pide la consigna del repo.
2. **Paleta:** usamos los colores por defecto de ggplot (rojo, verde, celeste, violeta), que no codifican nada. La cátedra usa Set1 o un color con función.
3. **Leyendas:** casi todos los gráficos de países usan leyenda; la clase 21 pide etiqueta directa.

## Propuesta gráfico por gráfico

| Nuestro gráfico | Modelo de la cátedra | Cambio | Para qué sirve |
|---|---|---|---|
| Todos | Tema de la casa (clase 22) | `utils/tema_tp.R` con el tema de arriba y una paleta fija por país: Argentina `tomato` y los vecinos en grises o en azules de Set1, igual en todos los gráficos | Coherencia visual con la cátedra; resuelve la duplicación |
| `07_g1_hhi_total` (líneas en dos paneles) | Clase 21, diap. 34: "atenúa a los demás en gris, marca a la Argentina" | Argentina en color y los otros tres en gris, con etiqueta directa al final de cada línea | Comunicación: la línea argentina contra las de los vecinos |
| **Nuevo:** HHI por país con las dos medidas | Clase 12, `01_concentracion_baci.R`, gráfico "La concentración depende de cómo se agrupen los productos" (barras agrupadas, paleta Blues) | Barras horizontales del HHI 2015-2024 de los 4 países, una por medida, ordenadas | Es el mismo mensaje que el del docente ("el resultado depende de la medida"), aplicado a la medida en lugar de la agregación. Va en la diap. 10 (veredicto) |
| **Alternativa:** dumbbell balanceado → final | Clase 22, gráfico 6 (dumbbell) | Un segmento por país, del HHI balanceado (`steelblue`) al final (`tomato`) | Muestra en una sola figura cuánto mueve la medida a cada país; Argentina es la que más se mueve |
| `07_g2_socios_equivalentes_sectores` (mapa de calor) | Clase 21, diap. 25 (mapa de calor) y 35 (small multiples) | Se queda como está | Rol de **exploración**: muchos sectores y países, sin elegir un ganador |
| **Nuevo:** sectores de Argentina | Clase 22, gráfico 9 (lollipop), o clase 21, diap. 58, caso 2 (barras ordenadas con etiqueta) | Socios equivalentes de Argentina por sector, ordenados, con etiqueta directa y los sectores estimados en gris | **Comunicación** del hallazgo "de 2,0 a 18,9"; es el par del mapa de calor |
| `07_g3_rca_sectores` | Clase 12, `02_comercio_baci.R` (barras `steelblue` con `geom_hline(yintercept = 1)` en `tomato` punteado) | Línea en RCA = 1 roja y punteada, barras ordenadas | Casi una copia del gráfico del docente |
| `08_g1_medias_sectores` (medias con IC) | Clase 21, diap. 49 (medias con IC) y clase 10 (boxplot con puntos) | Se queda; ya sigue la diapositiva de incertidumbre. Opcional: boxplot con puntos como en la clase 10 | Resultado del ANOVA |
| `06_g2_boxplot_sectores` | Clase 10, `reorder(..., FUN = median)` y escala log | Ordenar los sectores por mediana, como el docente | Tratamiento de atípicos |
| `03_g2_evolucion_indice` | Clase 22, gráfico 1 (base 100 con `geom_hline(100)` punteada) | Agregar la referencia en 100 | Pendiente de la Instancia 1 |
| Tasas anuales en líneas (pendiente SES-001) | Clase 21, diap. 18 (marcar los puntos si hay pocos períodos) y diap. 9-10 | Líneas con puntos, Argentina resaltada, 2020 y 2022 anotados | Ya estaba en la hoja de ruta de la Fase 4 |

## Cuándo hacerlo
- **Instancia 2 (vence mañana):** no tocaría los gráficos. El guion está validado y el grupo está armando el PDF; cambiar las figuras obliga a regenerar, a pasar otra vez por el QA y a que el grupo reemplace imágenes con el reloj encima.
- **Instancia 3 (13/11, visualizaciones):** es el lugar natural. La consigna pide al menos dos visualizaciones con storytelling, una para comunicar y otra para explorar, cada una con su rol. Los pares de la tabla (mapa de calor → lollipop; líneas o barras de las dos medidas) cubren eso con los modelos del docente.

## Sobre "que no parezca hecho con IA"
Alinear los gráficos con los de la clase es lo correcto en cualquier caso: es lo que el docente enseñó y lo que va a evaluar. Pero no reemplaza lo que cuenta en el oral, que es poder explicar cada decisión: por qué barras y no torta, por qué escala log, por qué el gris. Por eso cada cambio de la tabla tiene su diapositiva de referencia: si preguntan, se responde "como en la clase 21, diapositiva tal".
