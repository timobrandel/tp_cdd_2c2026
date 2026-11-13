# QA de gráficos de la Instancia 3 · 13/11/2026

## Objetivo

Timothy pidió auditar los gráficos de FABLE 5.2 antes de la entrega.
Priorizó legibilidad, coherencia económica, estética y explicación de las líneas del exploratorio.
También pidió leer la última sesión del proyecto.

## Trabajo realizado

- Codex leyó la sesión Claude `e09df8a2-b5c7-4842-a621-9d631c028e46` y el handover `HO-007.md`.
- Codex inspeccionó los JPG originales, vistas reducidas y versiones diagnósticas en gris.
- El subagente `qa-auditor` recalculó cifras independientemente y reprodujo el script en una copia temporal.
- Informes: `gestion/qa/QA-007.md` y `gestion/qa/QA-007-visual.md`.
- Codex actualizó la tarjeta de estado sin modificar los gráficos ni sus datos.

## Resultado

Los valores publicados coinciden con el recálculo independiente, considerando el redondeo del CSV.
La reproducción produce los archivos, pero R presenta errores de entorno y falla al cerrar.
La leyenda de estimaciones no describe correctamente el umbral aplicado.
El exploratorio pierde distinción entre grupos cuando se convierte a gris.
Sus ejes compartidos, referencias y textos dificultan una lectura autónoma.

Los tipos son adecuados: puntos unidos para comunicar; dispersión de burbujas con cuatro paneles para explorar.
La aproximación agregada de servicios del conocimiento tiene respaldo oficial del CEI.
El anexo documenta fuentes, límites interpretativos y propuestas de diseño.

## Qué sigue

1. Aplicar correcciones sin alterar las cifras verificadas.
2. Repetir QA sobre las nuevas imágenes y comprobar que R termine correctamente.
3. Timothy valida los JPG; después corresponden commit y push.
4. El grupo envía los dos archivos. Codex no envió mensajes ni adjuntos a terceros.

No se realizó impresión física ni prueba ciega de comprensión con lectores externos.
El plazo operativo indicado por Timothy es el 13/11 a medianoche argentina.
La consigna escrita dice 12/11, 23:59; la extensión oficial no quedó verificada.

## Integridad de los originales

SHA256 de `grupo_26_exploratorio.jpg`:
`69AFD4F8ABD8B35A4DE89F39416C40124FC9DB3F65175A13D62ED1F8FFCD42F2`

SHA256 de `grupo_26_comunicativo.jpg`:
`B50641BB8C7AE8B185E3F47A5ACB6B5B016BC4FB31F93675BE509DA9B197B264`

No se hizo commit ni push: D-002 exige validación de Timothy para cerrar el hito.
