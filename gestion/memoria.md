# Memoria técnica del proyecto

## R y gráficos · 13/11/2026

- Algunos lanzadores omiten `PROCESSOR_ARCHITECTURE` en Windows.
- En este entorno, `library(cli)` provocaba `0xC0000005` al cerrar R cuando faltaba esa variable.
- Restituirla antes de cargar paquetes resolvió el caso mínimo y el script 10.
- La solución local vive en `utils/preparar_entorno_graficos.R`.
- No ocultar el error con una salida forzada ni atribuirlo a los datos.
- Windows no reconoce el locale Unix `C.UTF-8`; R moderno acepta `.UTF-8`.
- El locale C provocaba errores de acentos y una etiqueta espuria `<bf>` en gridtext.
- La prueba `gestion/verificacion/verificar_entorno_graficos.R` reproduce ambas condiciones.
- El dispositivo JPEG predeterminado generaba píxeles suficientes, pero omitía metadatos de DPI.
- `ggsave(..., device=grDevices::jpeg, type="cairo", dpi=300)` los conserva en este entorno.
- `facet_wrap(axes="all", axis.labels="all")` permite repetir números sin cambiar las escalas.
- La posición de etiquetas puede ajustarse sin mover las coordenadas de los datos.
- Timothy pidió márgenes generosos entre nombres de ejes, porcentajes, paneles y leyendas; evitar elementos demasiado cercanos.
- Prefiere títulos y ejes completos, con subtítulos desglosados; ganar espacio no justifica quitar explicaciones útiles.
- La cobertura estimada del script 07 es un promedio anual; las participaciones del script 10 usan valores acumulados.
- No confundir esas ponderaciones ni describir el umbral 50% como ausencia completa de datos.
- D-037 registra las decisiones. HO-008 documenta reproducción, respaldo y paquete editable para Diego.
