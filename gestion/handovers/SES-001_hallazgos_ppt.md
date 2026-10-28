# SES-001 · Handover de sesión: revisar los 5 hallazgos de la PPT final
21/09/2026, 21:45 hora argentina. **La entrega es hoy a las 23:59, hora argentina.**

## Objetivo
Decidir si los 5 hallazgos de la diapositiva 12 de la PPT final son los mejores posibles y detectar los conceptos que se repiten a lo largo de la PPT. Hay que compararlos con los 5 hallazgos de la PPT original del grupo.
- **Criterios de la consigna:** "Interpretación: de 3 a 5 hallazgos explicados" y "Coherencia: un hilo conductor".
- **Entregable:** un diagnóstico y una propuesta concreta, con texto de reemplazo, cifra y tabla de origen para cada cambio.
- **Aplicar solo con el OK de Timothy.**

## Estado de partida
- **PPT final:** `gestion/insumos/TP CIENCIA DE DATOS BaTiS - 1ª entrega - FIrmano, Brandel, Díez de Los Ríos.pptx` (el archivo de trabajo se llamaba `Presentation entrega 1.pptx`), 12 diapositivas.
  - Tiene todas las correcciones de `revision_ppt_entrega1.md` y la diapositiva 11 de robustez (D-021).
  - Respaldo de la versión anterior del grupo: `Presentation entrega 1 - respaldo del grupo 21.13.pptx`.
- **PPT original del grupo:** `gestion/insumos/Trabajo_Practico_BaTiS_EDA.pptx`. Está hecha con el valor balanceado y sus hallazgos están en la diapositiva 10.
- **Repo:** commit `9613cfa` en `main` (incluye el script 04), subido a GitHub. El bloque 1.8 está cerrado.

## Hallazgos actuales (diapositiva 12 de la PPT final)
1. **Argentina y Uruguay lideran el giro hacia conocimiento:** Argentina pasa de 31% a 51% y Uruguay, de 12% a 47%.
2. **Argentina creció menos que Uruguay y Brasil:** +165% (5,3% anual), contra +430% de Uruguay y +228% de Brasil; Chile, +76%.
3. **La media engaña:** Argentina tiene la mediana más baja (1,6%) y 8 años de caída.
4. **Pandemia, caída mayor y recuperación menor:** −35,9% en 2020 y +15,7% en 2024 respecto de 2019.
5. **Brasil domina en escala:** su mediana es USD 33.156 M, más del doble que Argentina y casi cuatro veces Chile.

## Hallazgos de la PPT original (diapositiva 10)
Están hechos con el balanceado, y varias cifras son falsas con el valor final.
1. **Brasil domina en escala:** "casi tres veces más que Argentina o Chile". Con el final es 2,6 y 3,6 veces.
2. **Uruguay crece más rápido:** +281% contra +161% de Argentina. Con el final, +430% contra +165%.
3. **La pandemia golpeó de forma despareja:** "Chile, la mayor caída y la recuperación más fuerte". Estaba medida contra 2020; contra 2019 y con el final, la mayor caída es la de Argentina y la mayor recuperación, la de Brasil.
4. **Argentina se diversificó hacia servicios modernos:** de ~24% a ~37%. Con el final, conocimiento pasa de 31% a 51%.
5. **Viajes perdió peso en Argentina:** de 42,8% a 33,6%, "pese a seguir siendo la principal categoría". Con el final, pasa de 42,3% a 29,0% y ya no es la principal: la supera otros servicios empresariales (34,6%).

## Hipótesis de la sesión anterior (a validar, no son conclusiones)
- **H1 · "Brasil domina en escala" es el hallazgo más débil.**
  - Es un dato de tamaño que no responde la pregunta guía, que es sobre Argentina, y ya aparece en la lectura de la diapositiva 6.
  - Candidatos para su lugar:
    - **Robustez:** con las dos medidas se mantiene la dirección del cambio en la composición; el nivel y el perfil de Argentina, no (diap. 11 y `comparacion_medidas.md`).
    - **Calidad del dato** (hallazgo 5 del guion): el 96,5% de las filas de la base completa no tiene valor informado, pero nuestros cuatro países informan casi todo; la excepción es Chile, con 62,3% (diap. 5).
- **H2 · Los hallazgos 3 y 4 son dos caras de la volatilidad argentina.** Fusionarlos liberaría un lugar.
- **H3 · Fragilidad** (`comparacion_medidas.md` y QA-003, m4):
  - Con el valor final, estas afirmaciones se cumplen por poco y no se sostienen con el balanceado:
    - el hallazgo 3: 8 caídas contra 7 de Chile;
    - la caída de 2020 del hallazgo 4: −35,9% contra −34,4% de Chile.
  - Además, "conocimiento 51%" supera el 50% por 0,97 pp.
  - Robustos: la dirección de la composición, la diversificación y la menor recuperación de Argentina.
  - A evaluar: ¿priorizar lo robusto o explicitar la fragilidad?
- **H4 · Repeticiones a revisar:**
  - conocimiento 31% → 51% (diap. 10, 11 y 12);
  - media, mediana y 8 caídas (diap. 8 y 12);
  - −35,9% (diap. 9 y 12);
  - "Argentina supera a Chile desde 2006" (diap. 6);
  - "Chile 2023–2024 estimado": es necesaria, pero aparece en muchos lugares.
  - La diapositiva de hallazgos resume, pero debería sintetizar, no repetir cifras textuales.
- **H5 · Cobertura de la pregunta guía.** Los hallazgos deberían cubrir los 4 ejes de la diap. 3 (nivel, crecimiento, volatilidad y composición) sin redundancia.

## Reglas
- **Cifras:** solo de outputs auditados (`output/tablas/03_*` y `04_*`; se leen con `readr::read_csv2()`). El contenido del guion y sus fuentes está en `gestion/insumos/insumos_ppt_instancia1.md`.
- **Redacción:** nada causal. Salvedades: USD corrientes y Chile 2023–2024 estimados.
- **Alcance de los cambios:** solo la diapositiva 12, salvo que Timothy apruebe otra cosa. Mantener el estilo del grupo:
  - tipografía Aptos;
  - títulos en 24313D y bajadas en 667580;
  - filete terracota C86F52.
- **Antes de editar:** respaldo del archivo y verificar que no esté abierto (que no exista `~$...` en la carpeta).
- **Operativa en Windows:**
  - python-pptx no está instalado: se lee y se edita el XML con `zipfile` + `lxml`. Los scripts de la sesión anterior están en `gestion/herramientas_ppt/`:
    - `volcar_pptx.py`: texto por diapositiva;
    - `detalle_pptx.py`: posiciones y fuentes;
    - `aplicar_correcciones.py`: modelo de edición.
  - Los scripts de la guía pptx (`add_slide.py`, `validate.py`) hay que copiarlos a una carpeta local, porque Python no ve la ruta de la guía en AppData.
  - **Render:** PowerPoint por COM (`Presentations.Open(ruta, -1, 0, 0)` y después `Slides.Item(i).Export(png, "PNG", 1600, 900)`). No cerrar PowerPoint si ya estaba abierto.
- **Flujo:** propuesta → OK de Timothy → aplicar → render → verificar. Registrar la decisión en `decisiones.md` y actualizar `estadodelproyecto.md`.
