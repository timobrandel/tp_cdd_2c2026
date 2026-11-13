# Estado del proyecto
Última actualización: 13/11/2026. Timothy validó los gráficos y autorizó commit y push.

## Fase actual y último hito validado
Fase 4: Instancia 3, grupo 26. Pasos 4.1–4.4 cerrados.
- Timothy aprobó ambas imágenes después de recuperar los textos completos y ampliar el espaciado.
- QA-008, QA-008b y QA-008c: **APROBADO**, sin hallazgos pendientes.
- Comunicativo: puntos unidos horizontales, con Argentina y dos destinos por fila.
- Exploratorio: dispersión de burbujas en cuatro paneles, con diagonal de igualdad y porcentajes en cada panel.
- Ambos JPG tienen 300 dpi y 24 cm de ancho.
- Altura: exploratorio 29,5 cm; comunicativo 19,5 cm.
- El recálculo confirmó 99 filas y cinco columnas numéricas sin cambios.
- Rscript terminó con salida 0. QA también ejecutó el paquete editable descomprimido.
- Script: `script/10_destinos_sectores.R`.
- Entregables: `output/graficos/grupo_26_exploratorio.jpg` y `output/graficos/grupo_26_comunicativo.jpg`.
- Paquete para Diego: `output/grupo_26_graficos_editables.zip`, con proyecto de RStudio, script, funciones e insumos.
- Continuidad: `gestion/handovers/HO-008.md`. Decisión: D-037. Última revisión: `gestion/qa/QA-008c.md`.

## Próximo paso
**4.5: el grupo envía los dos JPG. El envío todavía no está verificado.**
- Destinatario: nsidicaro.fce@gmail.com. Asunto: `curso_2c_2026_grupo_26_instancia_3`.
- Envía un integrante, con los demás en copia. Adjunta solamente los dos JPG, sin código ni PPT.
- Timothy indicó el 13/11 a medianoche argentina como plazo operativo.
- La consigna escrita indica 12/11, 23:59. No verificamos una modificación oficial del plazo.
- La entrega pesa 10%. Consigna: `CURSO/trabajo_practico/consignas_instancia_3.md`.
- La Fase 5 todavía requiere definir y aprobar el próximo bloque.

## Antecedentes y pendientes del grupo
- Instancia 1: 7/10. La devolución pidió aprovechar el comercio bilateral.
- Instancia 2: 10/10. El docente destacó métodos, interpretación y gráficos.
- Argentina está más concentrada por socio que Brasil con ambas medidas.
- Frente a Chile y Uruguay, el resultado depende de la medida y del índice.
- El grupo debe decidir sobre el cluster sugerido por el docente.
- Entrega final: 24/11, 23:59; presentación de 15–20 diapositivas, anexo y enlace al repositorio.
- Falta verificar la reproducción completa desde un clon nuevo para la entrega final.
- Oral: 24/11–01/12; participan todos. Falta elegir fecha: https://forms.gle/oguR4XUZRVLvS2M17
- Diferidos: prueba del MCP de R, usuario de Brenda para invitarla y consolidación de scripts 03/04.
- La última información disponible indicaba que Diego todavía no había aceptado la invitación al repositorio.

## Limitaciones verificadas
- Persisten avisos iniciales de locale y paquetes compilados con R 4.6.2; no impidieron la ejecución.
- Falta probar el entorno concreto de Diego.
- No realizamos impresión física ni prueba ciega con lectores externos.
- Chile y la cobertura estimada están explicados en el exploratorio. Las comparaciones describen asociaciones, sin causalidad.
