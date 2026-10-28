# Insumos para la PPT · Instancia 1 (EDA)

- **Consigna vigente:** `consignas_instancia_1.md` (D-006).
- **Variable principal:** el valor final que informa cada país (`Final_value`, D-015).
- **Unidades:** millones de USD corrientes. Todo son exportaciones de servicios al mundo, 2005–2024.
- **Origen de las cifras:** cada una sale de un archivo de `output/`, que se indica entre corchetes. Las tablas se abren con doble clic en Excel (D-016) y los gráficos están en `output/graficos/`.

La cátedra pide limitar la IA en el armado de la PPT. Esto es contenido e interpretación para que el grupo lo redacte con sus palabras. En el oral preguntan por el código y las decisiones: el porqué de cada una está en `gestion/decisiones.md`.

---

## Guion sugerido: 11 diapositivas (la consigna pide 8 a 12)
Recorrido de la consigna: ¿qué datos tenemos? → ¿cómo están estructurados? → ¿qué encontramos? → ¿qué preguntas surgen?

**1. Portada.** Título del TP, integrantes, materia y fecha.

**2. La base de datos** [01_dimension_base_completa, 02_unidad_observacion]
- **Qué es:** OECD-WTO Balanced Trade in Services (BaTIS), BPM6, de la OCDE y la OMC. Datos anuales. La versión que usamos se publicó en diciembre de 2025; la metodología oficial es de enero de 2025 y describe la versión 2005–2023.
- **Fenómeno:** comercio internacional de servicios entre países, en una matriz completa y consistente.
- **Base completa:** 49.604.340 filas × 12 variables.
  - 204 economías informantes (202 países y 2 agregados), 206 socios, 31 códigos de servicio (el total, 26 categorías estándar y 4 agregados derivados), 2005–2024.
  - Unidad de observación: país informante × socio × flujo × categoría × año. Verificado: 49.604.340 combinaciones distintas, cero duplicados.
- **Base de trabajo:** 1.040 filas × 12 variables = 4 países × 20 años × 13 categorías (total + 12).
  - Unidad de observación: **país × año × categoría de servicio**, exportaciones al mundo. Verificado: sin duplicados y sin combinaciones faltantes.
- **Por qué se filtra:** el tema es la evolución y la composición de lo que exporta cada país, no a quién le exporta. Por eso socio = mundo y flujo = exportaciones.

**3. Tema y pregunta guía.** Título del TP. Pregunta: ¿cómo evolucionaron el nivel y la composición de las exportaciones de servicios de Argentina entre 2005 y 2024, comparadas con Brasil, Chile y Uruguay?

**4. Variables** [02_tabla_variables]
Tabla con las 12 variables: descripción, tipo, nulos y valores principales (columna "valores": las categorías, o el mínimo y el máximo).
- **Tipos:** numéricas `Reported_value`, `Final_value` y `Balanced_value`; temporal `Year`; el resto, categóricas.
- **Nulos:** solo `Reported_value`: 103 de 1.040 filas en la base de trabajo y 96,5% en la base completa. Está vacía cuando el valor no fue informado sino estimado.
- **Uso de cada una:**
  - `Final_value` es la variable principal.
  - `Reporter`, `Item_code` y `Year` agrupan.
  - `Partner` y `Flow` son filtros.
  - `Balanced_value`, `Reported_value` y `Final_value_methodology` se usan para la calidad del dato.
  - `type_*` son constantes en la base de trabajo.

**5. ¿De dónde salen los datos? Calidad del dato** [02_origen_datos_por_pais, 02_estimados_detalle, 03_brecha_resumen, gráfico 03_g7]
- **Base completa:** el 96,5% de las filas no tiene valor informado por el país (`Reported_value` vacío). Esos valores los completa OCDE-OMC con estimaciones (modelos de gravedad, interpolaciones), ceros derivados o sumas de grupos de países.
- **Nuestros cuatro países:** casi todo está informado. Argentina 99,6% (FMI), Brasil 100% (fuente nacional), Uruguay 98,5% (FMI). La excepción es **Chile, con 62,3% informado**. Sus 98 filas sin informar son de dos tipos:
  - 72 corresponden a cuatro categorías chicas que Chile nunca informa (manufactura sobre insumos de terceros, mantenimiento, construcción y gobierno) y que OCDE-OMC completa con ceros;
  - 26 son los 13 ítems de **2023 y 2024, que son estimaciones** (códigos E2 y E5).
- **Valor balanceado:** corrige lo que informa cada país con lo que declaran sus socios, y la diferencia no es pareja en el tiempo (gráfico 03_g7):
  - Argentina queda siempre por debajo de su cifra: entre −2,8% y −18,5%.
  - Chile pasa de −5,7% (2005) a +57,3% (2021).
  - Uruguay pasa de +44,4% (2006) a valores negativos desde 2012.
- **Relación entre las dos variables** (ítem del checklist del docente): a lo largo de los 20 años, el valor final y el balanceado se mueven casi igual en Argentina, Brasil y Uruguay (correlación de 0,98 a 0,99), aunque en niveles distintos. En Chile, la correlación es de solo 0,67 [03_brecha_resumen].
- **Por eso usamos el valor que informa cada país.**

**6. Tamaño y evolución** [03_descriptivos_nivel, 03_argentina_vs_chile, gráfico 03_g1]
Razonamiento: la media de 20 años describe el tamaño típico del período. Como la serie tiene tendencia, se acompaña con la mediana y con el coeficiente de variación (desvío / media), que permite comparar la dispersión de países de tamaños muy distintos.

| País | Media | Mediana | Desvío | Coef. de variación | Mínimo (año) | Máximo (año) |
|---|---|---|---|---|---|---|
| Argentina | 12.702 | 13.411 | 2.870 | 0,23 | 6.458 (2005) | 17.122 (2024) |
| Brasil | 32.476 | 33.156 | 8.467 | 0,26 | 14.763 (2005) | 48.477 (2024) |
| Chile | 9.051 | 8.897 | 1.801 | 0,20 | 5.554 (2020) | 11.980 (2011) |
| Uruguay | 4.264 | 4.933 | 1.763 | 0,41 | 1.311 (2005) | 6.948 (2024) |

- Desde 2006, Argentina exporta más servicios que Chile todos los años: 45,8% más en 2024 y hasta 74,9% más en 2019.
- El coeficiente de variación del nivel refleja sobre todo el crecimiento del período, porque la serie tiene tendencia. La volatilidad se mide con las tasas (diapositiva 8).
- Chile 2024 es un año estimado; el máximo que informó es el de 2011.

**7. Crecimiento 2005–2024** [03_crecimiento, gráfico 03_g2]
Razonamiento: la tasa anual compuesta traduce el crecimiento acumulado a un ritmo anual equivalente, comparable entre países. El índice 2005 = 100 pone a todos en el mismo punto de partida.

| País | Crecimiento acumulado 2005–2024 | Tasa anual compuesta 2005–2024 | Tasa anual compuesta 2005–2022 |
|---|---|---|---|
| Uruguay | +430% | 9,2% | 9,3% |
| Brasil | +228% | 6,5% | 6,1% |
| Argentina | +165% | 5,3% | 4,8% |
| Chile | +76% | 3,0% | 1,5% |

- **Chile:** 2005–2022 es el período que informó; 2023 y 2024 son estimados. Con cualquiera de los dos períodos, el orden es el mismo. Chile tocó su máximo en 2011 y no lo volvió a superar.
- **Salvedad:** son dólares corrientes. Parte del crecimiento es inflación de EE.UU.; se deflacta en la Instancia 2.

**8. Volatilidad: histograma de las tasas de variación anual** [03_descriptivos_tasas, gráfico 03_g3]
Razonamiento: la tasa interanual no depende del tamaño del país, así que permite comparar. Cuando unos pocos años extremos tiran de la media, la mediana describe mejor el "año típico".

| País | Media | Mediana | Desvío (puntos porcentuales) | Años con caída |
|---|---|---|---|---|
| Argentina | 6,7% | **1,6%** | 17,6 | **8 de 19** |
| Brasil | 7,3% | 5,0% | 13,8 | 6 de 19 |
| Chile | 4,6% | 6,9% | 18,0 | 7 de 19 |
| Uruguay | 10,7% | 4,6% | 19,0 | 5 de 19 |

- La media de Argentina se parece a la de sus vecinos, pero su mediana es la más baja y es el país con más años de caída. El promedio lo inflan los rebotes, como el +50% de 2022.
- Su desvío no es el más alto (Uruguay y Chile oscilan más): lo que la distingue es la frecuencia de las caídas.

**9. Atípicos y pandemia** [03_atipicos_tasas, 03_pandemia, gráfico 03_g4]
- **Atípicos:** según la regla del boxplot (1,5 rangos intercuartiles), los únicos años atípicos son de Argentina: 2020 (−35,9%) y 2022 (+50,3%).
- **Caída de 2020 contra 2019:** Argentina −35,9% (la mayor), Chile −34,4%, Uruguay −29,1%, Brasil −16,7%.
- **Recuperación, 2024 contra 2019** (se mide contra el nivel previo al shock): Brasil +46,8%, Chile +38,8% (2024 estimado), Uruguay +25,8%, **Argentina +15,7% (la menor)**.
- Los atípicos se explican, no se borran: coinciden con el shock de la pandemia y su rebote.

**10. Composición 2005 vs. 2024** [03_composicion_2005_2024, 03_concentracion_top3, gráfico 03_g5]
Participación de cada categoría en el total, en %. "Conocimiento" = telecomunicaciones e informática + otros servicios empresariales (esa columna sale de 03_robustez_composicion).

| País | Viajes | Transporte | Otros serv. empresariales | Telecom. e informática | Conocimiento |
|---|---|---|---|---|---|
| Argentina | 42,3 → 29,0 | 20,2 → 12,8 | 24,7 → 34,6 | 6,3 → 16,4 | **31,1 → 51,0** |
| Brasil | 26,2 → 15,1 | 17,7 → 15,6 | 40,4 → 41,0 | 2,2 → 12,7 | 42,6 → 53,8 |
| Chile | 15,6 → 26,4 | 67,2 → 36,1 | 10,1 → 23,7 | 3,6 → 5,9 | 13,7 → 29,6 |
| Uruguay | 45,3 → 31,5 | 35,7 → 11,3 | 3,9 → 27,7 | 7,7 → 19,5 | 11,6 → 47,2 |

- **Transporte pierde peso en los cuatro países; viajes, en Argentina, Brasil y Uruguay.** En Chile, viajes gana peso respecto de 2005: 28,3% en 2019 (informado) y 26,4% en 2024 (estimado), con un pozo en la pandemia (12,5% en 2022) [03_composicion_completa].
- Chile 2024 es estimado: su foto de 2024 se lee con esa salvedad.
- **La canasta se diversificó en los cuatro países.** Las 3 categorías más grandes pesan menos que en 2005: Argentina 87,2% → 79,9%, Brasil 84,3% → 71,7%, Chile 92,9% → 86,2%, Uruguay 88,7% → 78,7%.

**11. Hallazgos y preguntas** (las dos secciones de abajo)

Cómo encaja cada tramo con la consigna:
- Diapositivas 2 a 5: ¿qué datos tenemos y cómo están estructurados?
- Diapositivas 6 a 10: ¿qué encontramos?
- Diapositiva 11: ¿qué preguntas surgen?

El histograma de los valores por categoría (03_g6) puede ir en la 4 como "forma de la distribución de la variable principal". Muestra una distribución muy asimétrica a la derecha: media 1.219, mediana 228, en las 960 filas de categorías. Los 150 valores en cero quedan fuera de la escala logarítmica y se informan en el subtítulo. De dónde vienen [03_ceros_detalle]:
- **80 de Chile:** estimados como cero por OCDE-OMC, en 4 categorías que Chile no informa.
- **Los otros 70:** 65 informados como cero por los países y 5 estimados o derivados, todos en categorías chicas.

---

## Hallazgos (la consigna pide entre 3 y 5; cada uno con su tabla o gráfico)
1. **Giro hacia los servicios de conocimiento.** En los cuatro países ganan peso los servicios empresariales y la informática, y pierde peso el transporte. Viajes también pierde en Argentina, Brasil y Uruguay; en Chile, no. En Argentina, conocimiento pasa del 31% al 51% del total: hoy es más de la mitad de lo que exporta. Uruguay tuvo la transformación más grande, del 12% al 47%. *(diap. 10)*
2. **Argentina creció, pero menos que Uruguay y Brasil.** Creció +165% nominal (5,3% anual): tercera de cuatro, y el orden no cambia si se mira solo 2005–2022. Aun así, desde 2006 exporta más que Chile todos los años. Chile está estancado desde su máximo de 2011. *(diap. 6 y 7)*
3. **La media engaña: Argentina es la que más veces cae.** Tiene la mediana de crecimiento más baja (1,6%), la mayor cantidad de años con caída (8 de 19) y los únicos dos años atípicos (2020 y 2022), aunque su media (6,7%) se parece a la de los vecinos. Su desvío no es el más alto: Uruguay y Chile oscilan más. *(diap. 8 y 9)*
4. **Pandemia: la mayor caída y la menor recuperación.** Argentina cayó 35,9% en 2020 y en 2024 está apenas 15,7% por encima de 2019. Brasil cayó 16,7% y está 46,8% por encima. *(diap. 9)*
5. **La base es mayormente estimada, pero nuestros datos no.** El 96,5% de las filas de la base completa no tiene valor informado por el país. Argentina, Brasil y Uruguay informan casi el 100%; Chile, el 62%: nunca informa cuatro categorías chicas y sus años 2023–2024 son estimados. La versión "balanceada" se aparta de lo que informa cada país de forma cambiante: Argentina queda entre 2,8% y 18,5% por debajo, y Chile llega a quedar 57% por encima. *(diap. 5)*

**No llevar como hallazgo** (D-017): la correlación de las tasas anuales entre países. Sin la pandemia son solo 16 años, y con el valor final va de 0,43 a 0,84. Además, parte de la asociación puede venir de shocks comunes (crisis de 2009, dólar fuerte de 2015, pandemia) y de que los valores están en dólares corrientes. Queda como tabla de respaldo [03_correlaciones_tasas]. La "relación entre variables" del checklist queda cubierta en la diapositiva 5 (valor final contra balanceado).

## Preguntas para las próximas etapas (la consigna pide 1 o 2)
1. ¿La especialización argentina en servicios de conocimiento es una ventaja comparativa revelada frente a la región y al mundo? Se responde con el índice de Balassa (Unidad 3, Instancia 2).
2. ¿Las diferencias de crecimiento entre los cuatro países son estadísticamente significativas? Los cuatro comparten los mismos años, así que las muestras no son independientes. Corresponde un test para muestras relacionadas, por ejemplo el test pareado de la clase 10 entre Argentina y cada vecino (Unidad 2, Instancia 2).

## Salvedades que tienen que aparecer en la PPT
- Millones de USD corrientes, sin deflactar.
- Chile 2023–2024: estimaciones de OCDE-OMC.
- Se usa el valor que informa cada país (`Final_value`), no el balanceado. Explicar por qué en la diapositiva 5.
- El análisis es descriptivo, no causal: las interpretaciones describen asociaciones.
- Los gráficos del compañero usan el valor balanceado. Hay que reemplazarlos por los de `output/graficos/`.

## Advertencias del docente (clase 08, sección 9)
1. Ninguna tabla ni gráfico sin una frase que lo interprete.
2. Los NA y outliers se explican, no se borran en silencio.
3. Correlación no es causalidad.
