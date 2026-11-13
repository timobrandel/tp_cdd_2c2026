# QA-007 · Anexo visual y económico

Fecha: 13/11/2026. Auditor: Codex. Base: `54972d4`, con cambios anteriores sin commit.

## Alcance y evidencia

- Revisé ambos JPG originales, el script 10, sus funciones y la consigna vigente.
- Contrasté el diseño con la galería de la clase 22 y el script OWID de la clase 24.
- Leí la última sesión de Claude del proyecto: `e09df8a2-b5c7-4842-a621-9d631c028e46`.
- Timothy aprobó el hallazgo y la generación; todavía no validó los JPG finales.
- Inspeccioné imágenes completas y vistas de 907 píxeles de ancho, equivalentes a 24 cm bajo una referencia de 96 ppp.
- Revisé también copias diagnósticas en escala de grises, guardadas fuera del proyecto.
- Esa simulación no certifica el tamaño físico de cada pantalla ni reemplaza una impresión.
- La reproducción y el recálculo independiente corresponden a `QA-007.md`.

**Dictamen visual: requiere correcciones antes de aprobar la entrega.** Los tipos elegidos sirven; existen problemas verificables de accesibilidad y rotulación.

## Tipos exactos

| Archivo | Tipo | Qué representa |
|---|---|---|
| Comunicativo | Gráfico horizontal de puntos unidos, de brechas, o *dumbbell* | Dos participaciones por fila: Estados Unidos y Sudamérica. El segmento muestra su diferencia. |
| Exploratorio | Dispersión de burbujas facetada en cuatro paneles, con cuadrantes y diagonal de igualdad | Cada círculo representa un sector. Cada panel representa un país. |

El comunicativo contiene siete filas: el total y seis sectores. No representa cambios temporales ni intervalos de confianza.

El exploratorio contiene 48 sectores-país. Tamaño, color y relleno agregan dimensiones a las dos coordenadas.

La galería de la clase 22 incluye el *dumbbell* en su sección 6.
La consigna admite dispersión, cuadrantes y paneles comparables como recursos exploratorios.

## Cómo leer las líneas

- Eje horizontal: porcentaje de las exportaciones del sector comprado por Estados Unidos.
- Eje vertical: porcentaje comprado por los otros países de América del Sur.
- Línea vertical cortada: participación estadounidense en el total de servicios del país.
- Línea horizontal cortada: participación sudamericana en ese total.
- Un punto a la derecha supera la referencia estadounidense nacional.
- Un punto arriba supera la referencia sudamericana nacional.
- Diagonal continua: ambos destinos compran el mismo porcentaje del sector.
- Encima de la diagonal pesa más Sudamérica; debajo pesa más Estados Unidos.
- Los pequeños segmentos junto a las etiquetas solamente conectan nombres con círculos.

Las líneas cortadas no representan tendencias, promedios simples entre sectores ni significación estadística.
La referencia del total pondera los sectores por su valor exportado.

Ejemplo argentino: ambas referencias rondan el 25,5%.
Viajes queda en 13,2% estadounidense y 42,5% sudamericano.
Por eso aparece arriba y a la izquierda del cruce.
Económicamente, los compradores sudamericanos pesan más en viajes que en la canasta total argentina.

## Hallazgos y correcciones propuestas

### V1 · Mayor: los colores del exploratorio pierden su función en gris

El verde `#1B7F79` y el violeta `#7B3F9D` se convierten en grises casi iguales.
La conversión diagnóstica devuelve intensidades 96 y 92, respectivamente, sobre una escala de 0 a 255.
La inspección visual confirma que cuesta distinguir ambos grupos.
La consigna exige distinguirlos también en grises.

**Corrección:** elegir colores con distinta luminosidad y comprobar nuevamente la imagen completa en gris.
No alcanza con evitar el par rojo-verde.

### V2 · Mayor: la leyenda del relleno exagera lo que mide

El script dibuja círculos vacíos cuando `pct_estimado > 50`.
La leyenda afirma que el país no declara sus socios, como si la ausencia fuera completa.
También presenta los círculos llenos como datos declarados sin aclarar que pueden contener estimaciones.

**Corrección:** nombrar el umbral y el indicador realmente calculado.
El QA numérico documenta además la diferencia entre promedio anual y participación acumulada.
Cambiar la ponderación requiere resolver esa decisión; corregir la explicación no exige recalcular posiciones.

### V3 · Media: el lector debe buscar ejes demasiado lejos

Los paneles superiores carecen de números horizontales propios.
Los paneles derechos carecen de números verticales propios.
Los ejes comparten escalas correctamente, pero obligan a trasladar visualmente cada punto entre paneles.
El título vertical es demasiado largo.

**Corrección:** repetir números en cada panel y acortar los títulos a «Compra EE.UU. (%)» y «Compra Sudamérica (%)».
El subtítulo debe aclarar que el denominador corresponde a las exportaciones de cada sector.
Mantener escalas comunes permite comparar países honestamente.

### V4 · Media: tres referencias compiten por atención

El exploratorio combina grilla, dos líneas cortadas y diagonal, además de conectores de etiquetas.
El subtítulo explica sus funciones, pero exige leer un párrafo antes de explorar.
Los paneles rectangulares tampoco muestran la igualdad con una inclinación de 45 grados.
Esto no invalida la ecuación; dificulta su lectura intuitiva.

**Propuesta preferida:** conservar los cuatro paneles y la diagonal; retirar las referencias nacionales del diseño final.
La figura conserva complejidad mediante posición, tamaño, color, relleno y comparación entre países.
La consigna ofrece cuadrantes como ejemplo; no los exige.
Si el grupo conserva cuadrantes, debe rotular directamente sus referencias y reducir otras guías.
Conviene usar igual longitud física por punto porcentual en ambos ejes.

### V5 · Media: las notas ocupan espacio necesario para los datos

El exploratorio suma un título extenso, cuatro líneas de subtítulo, tres leyendas y un pie largo.
El pie utiliza aproximadamente 7,5 puntos; el comunicativo utiliza aproximadamente 8,2 puntos.
La lectura diagnóstica a 907 píxeles confirma que las aclaraciones quedan demasiado pequeñas.
No observé recortes generales de títulos ni desalineaciones graves entre paneles.
Sí observé etiquetas atravesadas por referencias y agrupaciones apretadas en Brasil y Uruguay.

**Corrección:** reducir texto repetido, compactar leyendas y dedicar más superficie a los paneles.
Mantener fuente, período, medida, exclusión de ROW y advertencias necesarias.
Mover la lista completa de países sudamericanos al respaldo metodológico; el JPG puede indicar «otros once países sudamericanos».
No eliminar aclaraciones necesarias solamente para ganar espacio.

### V6 · Media: el comunicativo necesita precisar el alcance económico

El título resume bien la dirección comparada, pero puede sugerir destinos exclusivos o mayorías en todos los sectores.
En informática, Estados Unidos compra aproximadamente 30%, Sudamérica 22% y los demás destinos 48%.
Superar a Sudamérica no equivale a comprar la mayoría mundial.
Las participaciones tampoco demuestran cómo se distribuyen las ventas dentro de Sudamérica.
Estos gráficos muestran orientación de destinos; no calculan por sí mismos concentración HHI ni balanzas comerciales.

**Título propuesto:** «Argentina: Sudamérica pesa más en viajes; Estados Unidos, en los servicios del conocimiento».
**Bajada propuesta:** «Comparación entre ambos destinos. Participación en las exportaciones de cada sector, acumuladas entre 2015 y 2024».
**Anotación propuesta:** «El total casi empata; los sectores muestran destinos diferentes».

Conviene reducir el protagonismo de la anotación cultural: compite con el mensaje general aprobado.
La cifra del 71% puede quedar como etiqueta, acompañada por su sensibilidad metodológica cuando corresponda.
El 26% del total expresa redondeo: «casi empatan» resulta más preciso que «empatan».

### V7 · Menor: los nombres cortos pueden inducir interpretaciones incorrectas

«Manufactura» representa servicios sobre insumos de terceros, no exportaciones de bienes manufacturados.
«Viajes» incluye fines personales y de negocios; «turismo» puede sugerir solamente vacaciones.
El rubro SI también incluye servicios de información.
Conviene utilizar nombres breves que mantengan esas diferencias.

## Definiciones verificadas

La agrupación SH + SI + SJ + SK tiene respaldo oficial como aproximación agregada de servicios del conocimiento.
El CEI utiliza esos cuatro rubros y distingue una definición más precisa, que exige mayor desagregación.
Por eso no corresponde rechazar la agrupación ni cambiarla por intuición.
Corresponde documentar el alcance agregado y evitar equipararla con prestación exclusivamente por internet.
Fuente: [CEI, comercio de servicios 2025, página 5](https://cancilleria.gob.ar/userfiles/ut/2026-06_analisis_del_comercio_de_servicios_de_la_argentina_2026.pdf).

La referencia a audiovisuales dentro de servicios personales, culturales y recreativos es correcta.
Ese rubro también incluye otros servicios; el gráfico no identifica cuánto corresponde exclusivamente a audiovisuales.
Fuente: [FMI, BPM6, párrafos 10.162–10.172](https://data.imf.org/-/media/iData/External-Storage/Documents/73FBCD5B6CDE4D289C60B9B0CAA40622/en/2-bpm6.pdf).

## Criterios para una segunda revisión

1. El lector identifica ambos destinos y el denominador sin leer una explicación externa.
2. Cada panel permite leer porcentajes sin buscar números en otro panel.
3. Los grupos se distinguen en color y en gris.
4. La leyenda describe exactamente el indicador de estimaciones y su umbral.
5. Las notas esenciales se leen en una vista completa del JPG.
6. El título expresa comparación, sin atribuir causalidad ni mayorías inexistentes.
7. La reproducción termina correctamente y preserva las cifras auditadas.

No modifiqué scripts, tablas ni JPG. Las propuestas todavía no representan una versión corregida.
No realicé una prueba ciega con lectores externos ni una impresión física.
