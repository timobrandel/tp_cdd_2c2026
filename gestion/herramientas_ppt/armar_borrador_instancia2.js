// Script: armar_borrador_instancia2.js
// Objetivo: armar el borrador del PDF de la Instancia 2 (D-033) sobre el guion validado
//           (gestion/insumos/guion_pdf_instancia2.md), con la estética de la PPT de la Instancia 1.
//           Es un borrador: el grupo edita textos y estética y lo termina.
// Entrada: output/graficos/*.png y las cifras del guion (cotejadas contra output/tablas/).
// Salida: gestion/insumos/Instancia 2 - borrador.pptx
// Requiere pptxgenjs 4.0.1, fuera del repo: `npm install pptxgenjs@4.0.1` en una carpeta temporal.
// Uso (desde la raíz del TP): NODE_PATH=<esa carpeta>/node_modules node gestion/herramientas_ppt/armar_borrador_instancia2.js
// Las referencias "diap. N" usan el número de página del pie (la carátula es la 1).

const pptxgen = require("pptxgenjs");
const fs = require("fs");

// Paleta tomada de la PPT entregada en la Instancia 1
const COL = {
  fondo: "F7F6F2", titulo: "24313D", navy: "28445A", gris: "667580",
  teal: "2F7D7A", tarjeta: "E9EEF0", tarjeta2: "DCE4EA", borde: "D4DBDE",
  terracota: "C86F52", blanco: "FFFFFF", verde: "D8EBDD", rojo: "F3D9D0", ambar: "F6EBCF",
};
const FONT = "Aptos"; // la tipografía de la PPT del grupo
const FUENTE = "Fuente: elaboración propia con datos de OECD-WTO BaTIS (BPM6, versión dic. 2025). Millones de USD corrientes.";

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13,33" × 7,5", igual que la PPT de la Instancia 1
pres.author = "Brenda Firmano, Diego Sebastián Díez de Los Ríos, Timothy Brandel";
pres.title = "Instancia 2: métodos · Exportaciones de servicios BaTIS";
pres.theme = { headFontFace: FONT, bodyFontFace: FONT };

pres.defineSlideMaster({
  title: "CONTENIDO",
  background: { color: COL.fondo },
  slideNumber: { x: 12.45, y: 7.08, w: 0.5, h: 0.25, fontFace: FONT, fontSize: 9, color: COL.gris, align: "right" },
});

// ---------- ayudas ----------
function nueva(kicker, titulo) {
  const s = pres.addSlide({ masterName: "CONTENIDO" });
  s.addText(kicker.toUpperCase(), { x: 0.6, y: 0.3, w: 10, h: 0.3, fontFace: FONT, fontSize: 10, bold: true, color: COL.teal, margin: 0, isTextBox: true });
  s.addText(titulo, { x: 0.6, y: 0.6, w: 12.1, h: 0.75, fontFace: FONT, fontSize: 26, bold: true, color: COL.titulo, margin: 0, valign: "middle", isTextBox: true });
  return s;
}
function fuente(s, texto) {
  s.addText(texto || FUENTE, { x: 0.6, y: 7.05, w: 11.6, h: 0.3, fontFace: FONT, fontSize: 9, color: COL.gris, margin: 0, isTextBox: true });
}
// Banda de conclusión al pie, como en la Instancia 1
function banda(s, texto, y = 6.2, h = 0.75) {
  s.addShape(pres.shapes.RECTANGLE, { x: 0.6, y, w: 12.13, h, fill: { color: COL.tarjeta }, line: { color: COL.borde, width: 0.75 } });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.6, y, w: 0.08, h, fill: { color: COL.teal }, line: { color: COL.teal, width: 0 } });
  s.addText(texto, { x: 0.85, y, w: 11.75, h, fontFace: FONT, fontSize: 14, bold: true, color: COL.titulo, valign: "middle", margin: 0, isTextBox: true });
}
function tarjeta(s, x, y, w, h, fill = COL.tarjeta) {
  s.addShape(pres.shapes.RECTANGLE, { x, y, w, h, fill: { color: fill }, line: { color: COL.borde, width: 0.75 } });
}
// Lista con viñetas: items = string o [{text, options}]
function lista(s, items, x, y, w, h, size = 13) {
  const runs = [];
  items.forEach((it, i) => {
    const last = i === items.length - 1;
    if (typeof it === "string") {
      runs.push({ text: it, options: { bullet: { indent: 14 }, breakLine: !last, paraSpaceAfter: 5 } });
    } else {
      it.forEach((r, j) => runs.push({ text: r.text, options: { ...(r.options || {}), ...(j === 0 ? { bullet: { indent: 14 }, paraSpaceAfter: 5 } : {}), ...(j === it.length - 1 && !last ? { breakLine: true } : {}) } }));
    }
  });
  s.addText(runs, { x, y, w, h, fontFace: FONT, fontSize: size, color: COL.titulo, valign: "top", margin: 0, isTextBox: true });
}
function encab(s, texto, x, y, w, size = 15, color = COL.titulo) {
  s.addText(texto, { x, y, w, h: 0.35, fontFace: FONT, fontSize: size, bold: true, color, margin: 0, valign: "middle", isTextBox: true });
}
// Imagen dentro de una caja blanca, respetando la proporción del PNG
function grafico(s, archivo, x, y, w, h, ratio) {
  s.addShape(pres.shapes.RECTANGLE, { x, y, w, h, fill: { color: COL.blanco }, line: { color: COL.borde, width: 0.75 } });
  const pad = 0.1;
  let iw = w - 2 * pad, ih = iw / ratio;
  if (ih > h - 2 * pad) { ih = h - 2 * pad; iw = ih * ratio; }
  s.addImage({ path: "output/graficos/" + archivo, x: x + (w - iw) / 2, y: y + (h - ih) / 2, w: iw, h: ih });
}
function tabla(s, filas, opts) {
  const head = filas[0].map((t) => ({ text: t, options: { bold: true, color: COL.blanco, fill: { color: COL.navy } } }));
  const cuerpo = filas.slice(1).map((f, i) => f.map((c) => (typeof c === "string" ? { text: c, options: { fill: { color: i % 2 ? COL.tarjeta : COL.blanco } } } : c)));
  s.addTable([head, ...cuerpo], { fontFace: FONT, fontSize: 12, color: COL.titulo, border: { type: "solid", pt: 0.75, color: COL.borde }, valign: "middle", margin: 0.05, ...opts });
}
const celda = (text, fill, extra = {}) => ({ text, options: { fill: { color: fill }, ...extra } });

// =====================================================================
// 0. Carátula (misma composición que la de la Instancia 1)
{
  const s = pres.addSlide({ masterName: "CONTENIDO" });
  s.addShape(pres.shapes.RECTANGLE, { x: 10.63, y: 0, w: 2.7, h: 7.5, fill: { color: COL.navy }, line: { color: COL.navy, width: 0 } });
  s.addText("INSTANCIA 2: MÉTODOS ESTADÍSTICOS Y CUANTITATIVOS", { x: 1.04, y: 1.05, w: 9, h: 0.3, fontFace: FONT, fontSize: 10, bold: true, color: COL.teal, margin: 0, isTextBox: true });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.72, y: 1.5, w: 0.08, h: 1.45, fill: { color: COL.terracota }, line: { color: COL.terracota, width: 0 } });
  s.addText("¿A quién le vende servicios Argentina? Concentración por socio y diferencias entre sectores", { x: 1.04, y: 1.45, w: 9.2, h: 1.55, fontFace: FONT, fontSize: 30, bold: true, color: COL.titulo, margin: 0, valign: "middle", isTextBox: true });
  s.addText("Argentina comparada con Brasil, Chile y Uruguay · 2015–2024", { x: 1.04, y: 3.55, w: 9, h: 0.45, fontFace: FONT, fontSize: 18, color: COL.gris, margin: 0, isTextBox: true });
  s.addText([
    { text: "Brenda Firmano · Diego Sebastián Díez de Los Ríos · Timothy Brandel", options: { breakLine: true } },
    { text: "Ciencia de Datos para Economía y Negocios · FCE-UBA · 29 de octubre de 2026" },
  ], { x: 1.04, y: 5.9, w: 9, h: 0.55, fontFace: FONT, fontSize: 11, color: COL.gris, margin: 0, isTextBox: true });
  s.addText("Fuente: OCDE-OMC, Balanced Trade in Services (BaTIS), edición BPM6, diciembre de 2025", { x: 1.04, y: 6.85, w: 9, h: 0.3, fontFace: FONT, fontSize: 9, color: COL.gris, margin: 0, isTextBox: true });
}

// =====================================================================
// 1. De dónde venimos
{
  const s = nueva("De dónde venimos", "La Instancia 1 describió cuánto y qué exporta cada país al mundo");
  const stats = [
    ["+165%", "Crecimiento nominal de Argentina 2005–2024 (5,3% anual): tercera de cuatro. Uruguay +430%, Brasil +228%. Con el balanceado queda cuarta (+161%)."],
    ["−35,9%", "Caída de Argentina en 2020, la mayor de los cuatro, y la menor recuperación a 2024 contra 2019 (+15,7%; vecinos de +25,8% a +46,8%)."],
    ["31% → 51%", "Peso de los servicios de conocimiento en el total de Argentina entre 2005 y 2024."],
  ];
  stats.forEach(([n, t], i) => {
    const x = 0.6 + i * 4.13;
    tarjeta(s, x, 1.65, 3.87, 2.6, COL.blanco);
    s.addText(n, { x: x + 0.25, y: 1.85, w: 3.4, h: 0.95, fontFace: FONT, fontSize: 40, bold: true, color: COL.terracota, margin: 0, isTextBox: true });
    s.addText(t, { x: x + 0.25, y: 2.85, w: 3.4, h: 1.7, fontFace: FONT, fontSize: 13, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
  });
  s.addText("Pregunta guía: cómo evolucionaron el nivel y la composición de las exportaciones de servicios de Argentina 2005–2024 frente a Brasil, Chile y Uruguay. Unidad: país × año × categoría (1.040 filas = 4 países × 20 años × 13 categorías), exportaciones al mundo, valor final. Chile 2023–2024: estimaciones de OCDE-OMC.", { x: 0.6, y: 4.45, w: 12.1, h: 0.95, fontFace: FONT, fontSize: 12, color: COL.gris, margin: 0, isTextBox: true });
  banda(s, "Le faltaba lo propio de BaTIS: a quién le vende cada país. Eso es lo que agrega esta instancia.");
  fuente(s);
}

// =====================================================================
// 2. Qué cambiamos por la devolución
{
  const s = nueva("Devolución de la Instancia 1", "Qué cambiamos a partir de la devolución (nota 7/10)");
  tabla(s, [
    ["Pidió el docente", "Qué hicimos", "Diap."],
    ["Aprovechar el comercio bilateral", "Nueva base país × socio: 4 países × 202 socios × 13 ítems × 20 años", "5"],
    ["Concentración de socios por país y sector, con cualquier índice", "CR1, CR4 y HHI por país, sector y año", "9 a 12"],
    ["Índice de diversidad", "Diversidad sectorial: sectores con ventaja comparativa revelada (RCA > 1), como en la clase 12. Mide la canasta de sectores, no la de socios", "12"],
    ["ANOVA con todos los países para ver si los sectores difieren en el valor", "ANOVA de log(valor) entre 12 sectores, sobre las 2.082 combinaciones país-sector con exportaciones positivas (de 2.400; 318 en cero), con robustez", "13 y 14"],
  ], { x: 0.6, y: 1.6, w: 12.13, colW: [3.9, 7.33, 0.9], fontSize: 13, rowH: 0.55 });
  encab(s, "Otros cambios", 0.6, 4.75, 6);
  lista(s, [
    "La pregunta guía pasó a ser una hipótesis contrastable (diap. 4).",
    "Para lo bilateral usamos el valor balanceado: concilia lo que declaran exportador e importador y es la medida que la metodología de BaTIS recomienda para los flujos entre pares. Para los totales al mundo sigue el valor final.",
  ], 0.6, 5.15, 12.1, 1.0, 13);
  banda(s, "Incorporamos las tres sugerencias del docente. La diversidad que medimos es sectorial, no de socios.", 6.25, 0.6);
  fuente(s);
}

// =====================================================================
// 3. Hipótesis
{
  const s = nueva("Hipótesis de trabajo", "Una hipótesis en tres partes, un método para cada una");
  tarjeta(s, 0.6, 1.6, 12.13, 1.35, COL.navy);
  s.addText("“Entre 2015 y 2024, las exportaciones de servicios de Argentina se concentran en menos socios que las de Brasil, Chile y Uruguay, y tanto esa concentración como el valor exportado difieren según el sector.”",
    { x: 0.9, y: 1.6, w: 11.6, h: 1.35, fontFace: FONT, fontSize: 17, italic: true, color: COL.blanco, valign: "middle", margin: 0, isTextBox: true });
  const partes = [
    ["1", "Se concentran en menos socios", "CR1, CR4 y HHI del total de servicios, por país", "Cuantitativo (Unidad 3)"],
    ["2", "La concentración difiere según el sector", "Los mismos índices, abiertos por sector", "Cuantitativo (Unidad 3)"],
    ["3", "El valor exportado difiere según el sector", "ANOVA de log(valor) entre 12 sectores, con robustez", "Inferencia (Unidad 2)"],
  ];
  partes.forEach(([n, p, m, t], i) => {
    const x = 0.6 + i * 4.13;
    tarjeta(s, x, 3.2, 3.87, 2.45, COL.blanco);
    s.addShape(pres.shapes.OVAL, { x: x + 0.25, y: 3.4, w: 0.5, h: 0.5, fill: { color: COL.terracota }, line: { color: COL.terracota, width: 0 } });
    s.addText(n, { x: x + 0.25, y: 3.4, w: 0.5, h: 0.5, fontFace: FONT, fontSize: 16, bold: true, color: COL.blanco, align: "center", valign: "middle", margin: 0, isTextBox: true });
    s.addText(p, { x: x + 0.9, y: 3.35, w: 2.8, h: 0.65, fontFace: FONT, fontSize: 14, bold: true, color: COL.titulo, valign: "middle", margin: 0, isTextBox: true });
    s.addText(m, { x: x + 0.25, y: 4.2, w: 3.4, h: 0.8, fontFace: FONT, fontSize: 13, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
    s.addText(t, { x: x + 0.25, y: 5.1, w: 3.4, h: 0.35, fontFace: FONT, fontSize: 11, bold: true, color: COL.teal, margin: 0, isTextBox: true });
  });
  banda(s, "Período 2015–2024: es cuando Argentina declara a quién le vende (diap. 6). El análisis describe asociaciones, no causas.", 5.95, 0.85);
  fuente(s);
}

// =====================================================================
// 4. Dos bases para dos preguntas
{
  const s = nueva("Las bases nuevas", "Dos bases para dos preguntas");
  const col = (x, titulo, filas) => {
    tarjeta(s, x, 1.6, 5.94, 3.1, COL.blanco);
    encab(s, titulo, x + 0.25, 1.75, 5.4, 16, COL.navy);
    lista(s, filas, x + 0.25, 2.2, 5.45, 2.4, 13);
  };
  col(0.6, "batis_bilateral: ¿a quién le vende?", [
    [{ text: "207.480 filas × 11 variables", options: { bold: true } }, { text: "; cero duplicados." }],
    "Unidad: país informante × socio × sector × año.",
    "4 países, 203 socios (202 economías + ROW, “resto del mundo”), 13 ítems (total + 12 sectores), 20 años.",
    [{ text: "Medida: ", options: { bold: true } }, { text: "balanceado (principal) y final (sensibilidad)." }],
    "Uso: concentración por socio (diap. 9 a 12).",
  ]);
  col(6.79, "batis_mundo_sectores: ¿cuánto exporta?", [
    [{ text: "51.870 filas × 10 variables", options: { bold: true } }, { text: "; combinaciones únicas." }],
    "Unidad: país × sector × año, socio = mundo.",
    "202 países, 13 ítems, 20 años.",
    [{ text: "Medida: ", options: { bold: true } }, { text: "valor final." }],
    "Uso: ANOVA entre sectores y diversidad sectorial (diap. 12 a 14).",
  ]);
  s.addText("Nulos: solo en Reported_value (95,18% en la bilateral; 18,44% en la base al mundo). Final_value y Balanced_value tienen 0 nulos. Ceros: Balanced_value bilateral 19.869; Final_value bilateral 53.707; Final_value al mundo 10.119.",
    { x: 0.6, y: 4.95, w: 12.1, h: 0.6, fontFace: FONT, fontSize: 12, color: COL.gris, margin: 0, isTextBox: true });
  banda(s, "No hay nulos en las medidas porque OCDE-OMC completa lo que nadie informa: el faltante real está en el origen del dato y en los ceros.", 6.2, 0.75);
  fuente(s);
}

// =====================================================================
// 5. Faltantes (I)
{
  const s = nueva("Faltantes (I)", "¿Quién declara a quién le vende?");
  tarjeta(s, 0.6, 1.6, 5.0, 4.35);
  encab(s, "Parte del valor con socio estimado por OCDE-OMC", 0.85, 1.75, 4.6, 14);
  lista(s, [
    [{ text: "Argentina: ", options: { bold: true } }, { text: "100% en 2005–2014 (retroproyección, E8.2); desde 2015, como máximo 0,4%. Declara entre 141 y 167 socios por año." }],
    [{ text: "Brasil: ", options: { bold: true } }, { text: "100% hasta 2009; en 2015–2024, entre 29,7% y 37,3%. Declara 37 socios." }],
    [{ text: "Chile y Uruguay: ", options: { bold: true } }, { text: "100% todos los años." }],
  ], 0.85, 2.2, 4.55, 2.2, 13);
  s.addShape(pres.shapes.RECTANGLE, { x: 0.85, y: 4.45, w: 4.5, h: 0.4, fill: { color: COL.terracota }, line: { color: COL.terracota, width: 0 } });
  s.addText("Estrategia: período 2015–2024 y sin imputar", { x: 0.85, y: 4.45, w: 4.5, h: 0.4, fontFace: FONT, fontSize: 12, bold: true, color: COL.blanco, align: "center", valign: "middle", margin: 0, isTextBox: true });
  s.addText("Se conservan los estimados con la salvedad explícita: OCDE-OMC ya completó y repetirlo no agrega información.", { x: 0.85, y: 4.95, w: 4.55, h: 0.9, fontFace: FONT, fontSize: 12, color: COL.titulo, margin: 0, isTextBox: true });
  grafico(s, "06_g1_origen_bilateral.png", 5.85, 1.6, 6.88, 4.35, 1600 / 1100);
  banda(s, "Solo Argentina y Brasil declaran a quién le venden. Por eso la medida principal es el balanceado: mide a los cuatro de la misma forma.");
  fuente(s, FUENTE + " Ponderado con el balanceado, sin ROW.");
}

// =====================================================================
// 6. Faltantes (II)
{
  const s = nueva("Faltantes (II)", "Un cero no siempre es “no exportó”");
  const bloque = (x, num, sub, items) => {
    tarjeta(s, x, 1.6, 3.87, 4.3, COL.blanco);
    s.addText(num, { x: x + 0.25, y: 1.75, w: 3.4, h: 0.8, fontFace: FONT, fontSize: 34, bold: true, color: COL.terracota, margin: 0, isTextBox: true });
    s.addText(sub, { x: x + 0.25, y: 2.55, w: 3.4, h: 0.6, fontFace: FONT, fontSize: 13, bold: true, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
    lista(s, items, x + 0.25, 3.25, 3.45, 2.55, 12);
  };
  bloque(0.6, "9,4% a 31,25%", "Filas país-año sin valor informado, 2015–2024, según el sector", [
    "Viajes, el mínimo; manufactura sobre insumos de terceros, el máximo (625 de 2.000).",
    "En la base del ANOVA, el 17,8% de los años es estimado.",
    "Se usa el valor final, que completa lo no informado, y se informa cuánto pesa lo estimado.",
  ]);
  bloque(4.73, "318 de 2.400", "Celdas país-sector en cero en la base al mundo", [
    "73 informadas como cero los diez años y 101 mixtas.",
    "17 nunca informadas y estimadas despreciables (E0); 127 nunca informadas y completadas con cero.",
    "Quedan fuera del ANOVA sobre log(valor); entran en Kruskal-Wallis, Friedman y RCA.",
    "Consecuencia: el ANOVA describe a los países que sí exportan (en manufactura quedan afuera 78).",
  ]);
  bloque(8.86, "7.978", "Flujos bilaterales en cero, 2015–2024", [
    "Solo 144 los declaró el país; 1.043 son E0 y el resto, ceros de otras estimaciones.",
    "Se conservan: en el HHI pesan cero y no cambian ningún índice; tampoco cuentan como socios con ventas.",
  ]);
  banda(s, "Chile nunca informa manufactura, mantenimiento, construcción ni gobierno: su posición en esos sectores no se interpreta.");
  fuente(s);
}

// =====================================================================
// 7. Atípicos
{
  const s = nueva("Valores atípicos", "Los atípicos son genuinos y se conservan");
  grafico(s, "06_g2_boxplot_sectores.png", 0.6, 1.6, 6.3, 4.4, 1800 / 1300);
  tarjeta(s, 7.15, 1.6, 5.58, 4.4);
  encab(s, "Criterio", 7.4, 1.72, 5, 14);
  s.addText("Regla del boxplot (1,5 rangos intercuartiles) sobre el log del valor y dentro de cada sector: la distribución es muy asimétrica y cada sector tiene su escala.", { x: 7.4, y: 2.08, w: 5.1, h: 0.95, fontFace: FONT, fontSize: 12, color: COL.titulo, margin: 0, isTextBox: true });
  encab(s, "Qué encontramos", 7.4, 3.08, 5, 14);
  lista(s, [
    "Base al mundo: 17 atípicos sobre 2.082 celdas con valor (16 bajos y 1 alto, EE.UU. en gobierno).",
    "14 de los 16 bajos son series intermitentes, con años en cero; los otros 2 (Papúa Nueva Guinea en viajes, Tuvalu en gobierno) son valores chicos de economías chicas.",
    "Bilateral 2024: 9 socios atípicos altos en 7 de 48 combinaciones país-sector. Un socio que compra mucho más es la concentración que queremos medir.",
  ], 7.4, 3.45, 5.15, 2.5, 12);
  banda(s, "No son errores de carga. El log reduce su influencia en el ANOVA y el Kruskal-Wallis no depende de ellos (diap. 14).", 6.2, 0.75);
  fuente(s);
}

// =====================================================================
// 8. Método de concentración
{
  const s = nueva("Método cuantitativo", "Concentración por socio: CR y HHI (clase 12)");
  tarjeta(s, 0.6, 1.6, 5.2, 4.35, COL.navy);
  s.addText("HHI = Σ (participación del socio, en %)²", { x: 0.85, y: 1.8, w: 4.75, h: 0.55, fontFace: FONT, fontSize: 18, bold: true, color: COL.blanco, margin: 0, isTextBox: true });
  s.addText([
    { text: "Escala 0 a 10.000: 10.000 = un solo comprador.", options: { breakLine: true } },
    { text: " ", options: { breakLine: true } },
    { text: "CR1: participación del primer socio. CR4: de los cuatro primeros.", options: { breakLine: true } },
    { text: " ", options: { breakLine: true } },
    { text: "Socios equivalentes asociados al HHI promedio 2015–2024 = 10.000 / HHI promedio: cuántos socios del mismo tamaño darían esa concentración." },
  ], { x: 0.85, y: 2.45, w: 4.75, h: 3.3, fontFace: FONT, fontSize: 13, color: COL.blanco, margin: 0, valign: "top", isTextBox: true });
  const dec = [
    ["Medida", "Balanceado como principal (mide igual a los cuatro); valor final como sensibilidad."],
    ["ROW excluido", "Es un residuo de socios no identificados; contarlo inventaría un comprador. Pesa como máximo 0,7%."],
    ["Cálculo", "Índices año por año y promedio 2015–2024."],
    ["Unidad", "Total de servicios para comparar países; los 12 sectores para la segunda parte de la hipótesis."],
  ];
  dec.forEach(([t, d], i) => {
    const y = 1.6 + i * 1.12;
    tarjeta(s, 6.05, y, 6.68, 1.0, COL.blanco);
    s.addText(t, { x: 6.3, y, w: 1.7, h: 1.0, fontFace: FONT, fontSize: 14, bold: true, color: COL.teal, valign: "middle", margin: 0, isTextBox: true });
    s.addText(d, { x: 8.05, y, w: 4.5, h: 1.0, fontFace: FONT, fontSize: 12, color: COL.titulo, valign: "middle", margin: 0, isTextBox: true });
  });
  banda(s, "Limitación: el CR4 mira solo los cuatro primeros socios y el HHI, a todos; pueden ordenar distinto, y el HHI depende de la medida.");
  fuente(s);
}

// =====================================================================
// 9. Resultado del total de servicios (+ socios de Brenda)
{
  const s = nueva("Resultado: total de servicios", "Argentina depende más que nadie de su primer comprador");
  grafico(s, "07_g1_hhi_total.png", 0.6, 1.5, 5.6, 3.25, 2000 / 1160);
  const t = (txt, b = false) => ({ text: txt, options: { bold: b } });
  tabla(s, [
    ["Promedio 2015–2024", "Argentina", "Brasil", "Chile", "Uruguay"],
    ["HHI balanceado", "878", "649", "897", "674"],
    ["CR4 balanceado", "42,3%", "35,6%", "50,1%", "47,0%"],
    ["CR1 balanceado", celda("25,7%", COL.ambar, { bold: true }), "22,3%", "22,8%", "15,9%"],
    ["Socios equivalentes (10.000 / HHI prom.)", "11,4", "15,4", "11,1", "14,8"],
    ["HHI final (sensibilidad)", "1.196", "787", "913", "676"],
    ["CR4 final (sensibilidad)", "51,9%", "35,7%", "45,4%", "42,3%"],
  ], { x: 6.45, y: 1.5, w: 6.28, colW: [2.48, 0.95, 0.95, 0.95, 0.95], fontSize: 11, rowH: 0.45, align: "center" });
  // Propuesta de Brenda: qué socios explican la concentración
  tarjeta(s, 0.6, 4.95, 12.13, 1.95);
  encab(s, "¿Quién explica la concentración de Argentina? Participación en el acumulado 2015–2024, balanceado", 0.85, 5.03, 11.6, 13);
  s.addText([
    { text: "EE.UU. 25,5%", options: { bold: true, color: COL.terracota } },
    { text: "  ·  Brasil 6,8%  ·  Chile 5,3%  ·  Uruguay 4,2%  ·  España 3,7%", options: { breakLine: true } },
    { text: "Primer socio de los vecinos: Brasil → EE.UU. 22,1%; Chile → EE.UU. 23,1%; Uruguay → Argentina 15,7%. HHI de Argentina: 859 en 2015, máximo de 1.006 en 2020 y 814 en 2024.", options: { fontSize: 12, breakLine: true } },
    { text: "Un solo comprador: CR1 más alto de los cuatro, pero CR4 más bajo que Chile y Uruguay. El 25,7% de la tabla es el promedio de los porcentajes anuales; el 25,5% es la participación en el acumulado: son medidas distintas.", options: { fontSize: 12, italic: true, color: COL.gris } },
  ], { x: 0.85, y: 5.4, w: 11.7, h: 1.45, fontFace: FONT, fontSize: 14, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
  fuente(s, FUENTE + " El valor final de Chile y Uruguay por socio es un modelo.");
}

// =====================================================================
// 10. Veredicto por vecino
{
  const s = nueva("Primera parte de la hipótesis", "¿Argentina está más concentrada que cada vecino?");
  s.addText("Años 2015–2024 en que Argentina está más concentrada que el vecino", { x: 0.6, y: 1.5, w: 7, h: 0.3, fontFace: FONT, fontSize: 12, color: COL.gris, margin: 0, isTextBox: true });
  const v = (txt) => {
    const n = parseInt(txt, 10);
    return celda(txt, n === 10 ? COL.verde : n <= 1 ? COL.rojo : COL.ambar, { bold: true, align: "center" });
  };
  tabla(s, [
    ["Vecino", "HHI balanceado", "CR4 balanceado", "HHI final", "CR4 final"],
    ["Brasil", v("10 de 10"), v("10 de 10"), v("10 de 10"), v("10 de 10")],
    ["Uruguay", v("10 de 10"), v("1 de 10"), v("10 de 10"), v("10 de 10")],
    ["Chile", v("5 de 10"), v("0 de 10"), v("10 de 10"), v("10 de 10")],
  ], { x: 0.6, y: 1.85, w: 7.0, colW: [1.4, 1.4, 1.4, 1.4, 1.4], fontSize: 14, rowH: 0.6 });
  s.addText("Medida principal: balanceado. Con el valor final, los socios de Chile y Uruguay salen de un modelo de gravedad.", { x: 0.6, y: 4.4, w: 7.0, h: 0.6, fontFace: FONT, fontSize: 12, italic: true, color: COL.gris, margin: 0, isTextBox: true });
  tarjeta(s, 7.85, 1.5, 4.88, 4.45, COL.blanco);
  lista(s, [
    [{ text: "Brasil: ", options: { bold: true } }, { text: "se cumple con las dos medidas y los dos índices." }],
    [{ text: "Uruguay: ", options: { bold: true } }, { text: "se cumple con el HHI, no con el CR4 balanceado. Reparte casi la mitad entre cuatro socios de tamaño parecido (CR4 47,0%)." }],
    [{ text: "Chile: ", options: { bold: true } }, { text: "con el balanceado, no se cumple con ningún índice. En el HHI empatan en años (5 de 10; Chile arriba en 2019 y 2021–2024) y Chile queda algo arriba en promedio (897 contra 878); en el CR4, Chile está más concentrado los 10 años." }],
  ], 8.1, 1.7, 4.45, 4.15, 13);
  banda(s, "Frente a Brasil se cumple; frente a Chile y Uruguay, depende de la medida y del índice. Lo reportamos como sale, sin ajustar la hipótesis.");
  fuente(s, FUENTE + " Chile 2023–2024: estimaciones de OCDE-OMC.");
}

// =====================================================================
// 11. Concentración por sector y diversidad sectorial
{
  const s = nueva("Segunda parte de la hipótesis", "La concentración difiere según el sector");
  grafico(s, "07_g2_socios_equivalentes_sectores.png", 0.6, 1.5, 5.6, 4.6, 1700 / 1400);
  tarjeta(s, 6.45, 1.5, 6.28, 2.85, COL.blanco);
  lista(s, [
    [{ text: "Argentina, balanceado: ", options: { bold: true } }, { text: "de 2,0 socios equivalentes en personales y culturales (EE.UU. 67,1%) a 18,9 en transporte." }],
    "Concentrados también: manufactura 4,0 (se lee con cautela: 98% estimado), financieros 4,4 y propiedad intelectual 4,5.",
    "En los cuatro países, el sector que más reparte tiene entre 3,6 y 9,3 veces los socios equivalentes del más concentrado (con el final, 3,0 a 7,9).",
  ], 6.7, 1.65, 5.85, 2.6, 12);
  tarjeta(s, 6.45, 4.5, 6.28, 1.6);
  encab(s, "Diversidad sectorial (sectores con RCA > 1)", 6.7, 4.58, 5.8, 13, COL.teal);
  s.addText("Argentina 5 de 12, más que el 82,8% de 199 economías; Brasil 4, Chile 3, Uruguay 3. Mide la canasta de sectores, no la diversidad de socios: no responde la primera parte.", { x: 6.7, y: 4.95, w: 5.85, h: 1.1, fontFace: FONT, fontSize: 12, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
  banda(s, "Se cumple con las dos medidas. “Argentina es la que más varía entre sectores” vale solo con el balanceado; con el final, Brasil varía más.", 6.25, 0.7);
  fuente(s, FUENTE + " *: más de la mitad del valor con socios estimados.");
}

// =====================================================================
// 12. ANOVA: pregunta, hipótesis y supuestos
{
  const s = nueva("Método de inferencia", "ANOVA entre sectores: pregunta, muestra y supuestos");
  tarjeta(s, 0.6, 1.5, 6.0, 4.55, COL.blanco);
  encab(s, "¿El valor que exporta un país típico difiere entre los 12 sectores?", 0.85, 1.6, 5.6, 13, COL.navy);
  lista(s, [
    [{ text: "Muestra: ", options: { bold: true } }, { text: "las 2.082 combinaciones país-sector con exportaciones positivas (de 2.400; 318 en cero). Promedio 2015–2024 del valor final, una observación por país y sector." }],
    [{ text: "Variable: ", options: { bold: true } }, { text: "log(valor): se comparan medias geométricas, el valor de un “país típico”." }],
    [{ text: "H0: ", options: { bold: true } }, { text: "la media de log(valor) es igual en los 12 sectores. H1: al menos uno difiere." }],
    [{ text: "Supuestos: ", options: { bold: true } }, { text: "Shapiro-Wilk W = 0,99 (p < 0,001; con n = 2.082 rechaza cualquier desvío chico). Levene F = 13,89 (11 y 2.070 gl), p < 0,001; cociente de desvíos 1,90 (< 2)." }],
    [{ text: "Criterio fijado antes: ", options: { bold: true } }, { text: "si Levene rechaza, Welch y Games-Howell. Además, Kruskal-Wallis y, por la independencia, país como bloque y Friedman." }],
  ], 0.85, 2.05, 5.55, 3.95, 12);
  grafico(s, "08_g2_qq_residuos.png", 6.85, 1.5, 5.88, 4.55, 2400 / 1800);
  banda(s, "Los residuos siguen a la normal en el centro y se apartan en las colas: por eso se contrasta con métodos que no la suponen.", 6.25, 0.7);
  fuente(s);
}

// =====================================================================
// 13. Resultados del ANOVA y robustez
{
  const s = nueva("Resultado del ANOVA", "El valor exportado difiere según el sector, con todos los métodos");
  grafico(s, "08_g1_medias_sectores.png", 0.6, 1.5, 5.9, 3.95, 3000 / 1950);
  tabla(s, [
    ["Test", "Estadístico", "gl", "p", "Efecto"],
    ["ANOVA de un factor", "F = 38,87", "11 y 2.070", "< 0,001", "eta² = 0,17"],
    ["ANOVA de Welch", "F = 43,82", "11 y 790,6", "< 0,001", "—"],
    ["Kruskal-Wallis con ceros", "513,84", "11", "< 0,001", "eps² = 0,21"],
    ["Kruskal-Wallis sin ceros", "348,48", "11", "< 0,001", "eps² = 0,17"],
    ["País como bloque", "F = 154,32", "11 y 1.872", "< 0,001", "eta² = 0,20*"],
    ["Friedman (con ceros)", "chi² = 1.220,84", "11", "< 0,001", "W = 0,55"],
  ], { x: 6.75, y: 1.5, w: 5.98, colW: [1.85, 1.3, 1.0, 0.8, 1.03], fontSize: 10.5, rowH: 0.36 });
  s.addText("* Sobre la SC total, comparable con el 0,17. Games-Howell: 41 de 66 pares difieren al 5% (Tukey: 42).", { x: 6.75, y: 4.1, w: 5.98, h: 0.3, fontFace: FONT, fontSize: 10, color: COL.gris, margin: 0, isTextBox: true });
  s.addText([
    { text: "Limitaciones. ", options: { bold: true } },
    { text: "El ANOVA simple no modela la dependencia entre las observaciones de un mismo país. Como control, agregamos el país como bloque y el test de Friedman; en estos datos, la F sube de 38,9 a 154,3 al descontar el país. El modelo con bloque es aditivo (con una observación por país y sector no se estima la interacción) y sus residuos cumplen peor los supuestos (Shapiro W = 0,96; cociente de desvíos 3,01): por eso se suma el Friedman.", options: { breakLine: false } },
  ], { x: 6.75, y: 4.45, w: 5.98, h: 1.4, fontFace: FONT, fontSize: 10.5, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
  s.addText("Medias geométricas: viajes 919,6 M USD por año; propiedad intelectual 9,8.", { x: 0.6, y: 5.5, w: 5.9, h: 0.35, fontFace: FONT, fontSize: 11, color: COL.gris, margin: 0, isTextBox: true });
  banda(s, "Se rechaza H0: el sector explica el 17% de la variabilidad del log del valor. En un país típico, viajes genera unas 94 veces lo que propiedad intelectual.", 5.95, 0.85);
  fuente(s, FUENTE + " Sin deflactar. Asociación, no causa.");
  s.addNotes("Si preguntan si es un ANOVA de medidas repetidas: \"No exactamente: usamos un ANOVA con el país como bloque y el test de Friedman como control dentro de cada país.\" El eta² parcial del modelo con bloque (0,48) no se compara con el 0,17: tiene otro denominador. El modelo con bloque es aditivo y sus residuos cumplen peor los supuestos (W = 0,96; cociente de desvíos 3,01), por eso se agregó el Friedman.");
}

// =====================================================================
// 14. Síntesis y próximos pasos
{
  const s = nueva("Síntesis", "Sectores: se cumple. Socios: depende de la medida y del índice");
  const ok = (t) => celda(t, COL.verde);
  tabla(s, [
    ["Parte de la hipótesis", "Resultado", "Método"],
    ["Argentina se concentra en menos socios que sus vecinos", celda("Frente a Brasil se cumple con las dos medidas y los dos índices; frente a Chile y Uruguay, depende de la medida y del índice", COL.ambar), "CR y HHI (cuantitativo)"],
    ["La concentración difiere según el sector", ok("Se cumple con las dos medidas (Argentina, de 2,0 a 18,9 socios equivalentes)"), "CR y HHI por sector"],
    ["El valor exportado difiere según el sector", ok("Se cumple con todos los métodos (F = 38,9; eta² = 0,17)"), "ANOVA y robustez (inferencia)"],
  ], { x: 0.6, y: 1.5, w: 12.13, colW: [3.6, 6.03, 2.5], fontSize: 13, rowH: 0.62 });
  tarjeta(s, 0.6, 4.25, 5.9, 2.65, COL.blanco);
  encab(s, "Cómo se relacionan los dos métodos", 0.85, 4.35, 5.4, 14, COL.navy);
  s.addText("Son complementarios: el ANOVA muestra que los sectores difieren en cuánto exporta un país típico; la concentración, en a cuántos socios les venden. No se puede afirmar que los sectores más chicos sean los más concentrados: en Argentina, transporte y viajes reparten mucho y mantenimiento, siendo chico, también.",
    { x: 0.85, y: 4.75, w: 5.45, h: 2.05, fontFace: FONT, fontSize: 12, color: COL.titulo, margin: 0, valign: "top", isTextBox: true });
  tarjeta(s, 6.75, 4.25, 5.98, 2.65);
  encab(s, "Próximos pasos (entrega final)", 7.0, 4.35, 5.5, 14, COL.navy);
  lista(s, [
    "Relacionar la concentración con el tamaño del sector.",
    "Test pareado de crecimiento entre países (pendiente de la Instancia 1).",
    "ANOVA en valores reales o relativos al tamaño de cada país.",
    "Revisar el resultado frente a Chile sin 2023–2024 (estimados).",
  ], 7.0, 4.75, 5.55, 2.05, 12);
  fuente(s, "Salvedades: millones de USD corrientes, sin deflactar; Chile y Uruguay con distribución por socio 100% estimada por OCDE-OMC; descriptivo, no causal.");
}

// =====================================================================
// Anexo
{
  const s = nueva("Anexo", "Comparaciones de a pares y principales socios");
  grafico(s, "08_g3_pares_sectores.png", 0.6, 1.5, 6.6, 5.1, 3300 / 2550);
  tabla(s, [
    ["País", "1.º socio", "2.º", "3.º"],
    ["Argentina", "EE.UU. 25,5%", "Brasil 6,8%", "Chile 5,3%"],
    ["Brasil", "EE.UU. 22,1%", "China 4,8%", "Países Bajos 3,8%"],
    ["Chile", "EE.UU. 23,1%", "China 10,6%", "Argentina 8,1%"],
    ["Uruguay", "Argentina 15,7%", "EE.UU. 12,8%", "China 10,0%"],
  ], { x: 7.45, y: 1.5, w: 5.28, colW: [1.08, 1.5, 1.2, 1.5], fontSize: 11, rowH: 0.45 });
  s.addText("Participación en el acumulado 2015–2024, valor balanceado (07_principales_socios). Games-Howell: 41 de 66 pares difieren al 5%. Sensibilidad de Brasil, 2010–2014 contra 2015–2024: HHI 781 → 649 (balanceado) y 882 → 787 (final).",
    { x: 7.45, y: 3.95, w: 5.28, h: 1.5, fontFace: FONT, fontSize: 11, color: COL.gris, margin: 0, valign: "top", isTextBox: true });
  fuente(s);
}

const salida = "gestion/insumos/Instancia 2 - borrador.pptx";
pres.writeFile({ fileName: salida }).then(() => console.log("ok: " + salida));
