# Handover · 2026-10-29 · Paso 3.7 · Armado del PDF de la Instancia 2
Archivo: `gestion/handovers/2026-10-29-armado-pdf-instancia2.md`

Motivo: cierre de paso. Arranca una sesión nueva sin contexto previo; este archivo alcanza para trabajar.

## Objetivo
Llegar al PDF de la Instancia 2 (10 a 15 diapositivas sin contar carátula y cierre, sin código), armado sobre el guion validado. **Vence hoy, jueves 29/10, a las 23:59.** Lo envía un integrante a nsidicaro.fce@gmail.com, con asunto `curso_2c_2026_grupo_XX_instancia_2` y los demás en copia. El envío lo hace el grupo, no Claude.

## Estado del repo
- Local igual a `origin/main` (`9ad295a`) al 29/10. No hay commits de los compañeros ni cambios sin commitear. Antes de tocar nada, confirmarlo de nuevo con `git fetch` y `git status -sb`.
- Material ya validado por Timothy y por los compañeros:
  - guion: `gestion/insumos/guion_pdf_instancia2.md` (14 diapositivas + carátula + anexo; cada cifra con su tabla de `output/tablas/`);
  - gráficos en `output/graficos/` (05 a 08);
  - tablas en `output/tablas/` (se leen con `readr::read_csv2()`).
- Detalle del paso anterior: `gestion/handovers/HO-005.md`, `gestion/qa/QA-005.md` y `QA-005b.md`.

## Primer punto de control con Timothy: ¿quién arma las diapositivas?
La consigna del TP dice: "El uso de herramientas de IA está permitido […] Limitar su uso en el armado de la PPT". D-007 lo tradujo así: el grupo arma la presentación y Claude entrega material y guion. Timothy pidió esta sesión "para el armado del PDF". **Antes de producir diapositivas, hacele una sola pregunta para elegir entre:**
- **(a) Recomendada:** el grupo arma las diapositivas. Claude deja el texto final de cada diapositiva listo para copiar, con las correcciones de abajo, y después revisa el PDF armado contra el guion (cifras, títulos, salvedades).
- **(b)** Claude arma el .pptx y lo exporta a PDF (skill `pptx`). En ese caso queda registrado como decisión nueva (D-033), porque cambia D-007 y va contra la recomendación de la cátedra.

## Correcciones de redacción que piden los compañeros
Diego revisó los scripts 05 a 09: reproducen los resultados y no hay que rehacer el análisis. Sus observaciones son de redacción y quedan aceptadas. Aplicalas en el guion antes de armar:
1. **Ceros y `socios_con_ventas`.** `06_diagnostico_resumen` dice que los ceros "sí cuentan en la columna socios_con_ventas", pero `script/07_concentracion_socios.R:134` calcula `sum(valor > 0)`: los ceros **no** cuentan. El error está en el texto de `script/06_faltantes_atipicos.R:424`. Corregí ese texto por "En el HHI pesan cero y no cambian ningún índice; tampoco cuentan como socios con ventas", corré el 06 y verificá que solo cambie esa celda de `output/tablas/06_diagnostico_resumen.csv`. No cambia ninguna cifra.
2. **"El ANOVA de un factor es conservador"** (guion, diap. 13, y D-028). No es una regla general. Reemplazar por: "El ANOVA simple no modela la dependencia entre las observaciones de un mismo país. Como control, agregamos el país como bloque y el test de Friedman; en estos datos, la F sube de 38,9 a 154,3 al descontar el país". Anotarlo en D-028 como corrección.
3. **Muestra del ANOVA:** decir siempre "las 2.082 combinaciones país-sector con exportaciones positivas (de 2.400; 318 en cero)", nunca "compara los 200 países". El guion ya lo dice; mantenerlo en la diapositiva.
4. **Socios equivalentes:** escribir "socios equivalentes asociados al HHI promedio 2015-2024 (10.000 / HHI promedio)", no "1 / HHI" a secas.
5. **RCA:** titularlo "Diversidad sectorial (sectores con RCA > 1)", nunca "diversidad" a secas, y aclarar que no mide diversidad de socios.
6. **Modelo con bloque:** no llamarlo "medidas repetidas". Para el oral: "No exactamente: usamos un ANOVA con el país como bloque y el test de Friedman como control dentro de cada país."
7. **Conclusión:** "apoyo parcial" sirve de etiqueta para la primera parte, pero el veredicto completo sigue siendo el de D-029: frente a Brasil se cumple con las dos medidas y los dos índices; frente a Chile y Uruguay depende de la medida y del índice.

Diego también propuso una estructura de 15 diapositivas (archivo `C:\Users\timob\Downloads\devolución.txt`, sección 20). Coincide en lo esencial con el guion. Lo que suma: una diapositiva "Dos bases para dos preguntas" (base, unidad, filas, uso, y qué medida va con cada una) y el ANOVA repartido en pregunta y muestra / resultado / supuestos y robustez / Games-Howell. Usala si mejora el hilo, sin pasar de 15 diapositivas de contenido.

**Diego sobre el ANOVA de medidas repetidas:** no se agrega. Con lo que ya está alcanza, y agregarlo obligaría a reinterpretar todo.

## Propuesta de Brenda: qué socios explican la concentración
Se puede responder sin análisis nuevo, con tablas que ya existen. Va en la diapositiva 9 o en el anexo, como Timothy prefiera:
- `output/tablas/07_principales_socios.csv` (balanceado, 2015-2024 acumulado):
  - Argentina: EE.UU. 25,51%, Brasil 6,80%, Chile 5,31%, Uruguay 4,22%, España 3,73%.
  - Lectura: la concentración de Argentina viene de un solo comprador. Tiene el CR1 más alto de los cuatro (25,7%), pero su CR4 (42,3%) es más bajo que el de Chile y Uruguay.
  - Ojo: el CR1 de 25,7% es el promedio de los porcentajes anuales; el 25,51% es la participación en el acumulado del período. Son medidas distintas y hay que aclararlo si van juntas.
- `output/tablas/07_concentracion_anual.csv` (ítem S, balanceado): evolución del HHI de Argentina en 2015-2024, con máximo de 1.006 en 2020 y 814 en 2024.
  - No usar 2005-2014 para Argentina: es una retroproyección (código E8.2) de la estructura que declara desde 2015, sin información propia de esos años (D-027).
- Cualquier número que se agregue se coteja contra la tabla antes de ponerlo.

## Pregunta de Diego: ¿el PDF es la presentación del oral?
No. La Instancia 2 se entrega "exclusivamente en formato PDF" y se evalúa solo la presentación, sin código (`CURSO/trabajo_practico/consignas_instancia_2.md`, sección 6). El oral es de la **entrega final**: una PPT en .pptx o PDF de 15 a 20 diapositivas más anexo, con el repo, presentada en forma virtual y sincrónica entre el 24/11 y el 01/12, con todos los integrantes (`consignas_trabajo_final.md`, líneas 30, 101 y 130-149). El PDF de hoy es un insumo de la final, no la presentación del oral.

## Pendiente que sigue abierto
- Diapositiva 2 del guion: cotejar con el **texto de la devolución del docente**. El archivo `devolución.txt` es el digest de Diego, no la devolución del docente. Si nadie tiene el texto, la diapositiva queda como está (las tres sugerencias registradas en D-023 están incorporadas).

## Cierre del paso
- Guion corregido con los puntos 1 a 7 (y lo de Brenda, si se incorpora), con cada cifra nueva cotejada contra su tabla.
- Si se tocó el script 06: corrida limpia y solo la celda esperada cambiada en `06_diagnostico_resumen.csv`.
- QA con `qa-auditor` sobre un `HO-006.md`, solo si hubo cambios en código o cifras nuevas. Los cambios de redacción no necesitan QA.
- Validación de Timothy, y después commit y push con `git -c credential.helper= -c "credential.helper=!gh auth git-credential" push`.
- Si se arma el PDF (opción b), revisarlo página por página contra el guion antes de dárselo a Timothy.

## Trampas
- Las tablas redondean a 2 decimales. Ejemplo: Chile figura con 11,15 socios equivalentes en la tabla, pero el exacto es 11,146, que se informa 11,1.
- `08_tests` no guarda el conteo de Tukey (42 pares); sale de la consola del script 08.
- `Rscript` no está en el PATH: usar `"C:/Program Files/R/R-4.6.1/bin/Rscript.exe" script/NN.R` desde la raíz.
- `pdftotext` está en `/mingw64/bin` y sale en latin1 (pasarlo por `iconv -f latin1 -t utf-8`). `pdftoppm` no está instalado.

## Archivos a leer primero
- `gestion/estadodelproyecto.md`
- `gestion/insumos/guion_pdf_instancia2.md`
- `gestion/decisiones.md`: D-007, D-024 y D-026 a D-029.
- `C:\Users\timob\Downloads\devolución.txt`: digest de Diego, fuera del repo.
