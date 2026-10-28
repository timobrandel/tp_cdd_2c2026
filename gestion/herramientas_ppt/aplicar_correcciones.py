# Aplica a la PPT del grupo las correcciones de revision_ppt_entrega1.md y agrega la
# diapositiva de robustez (D-020, D-021). Trabaja sobre una copia; no toca el original.
# Uso: python aplicar_correcciones.py <deck_grupo.pptx> <grafico_04_g3.png> <salida.pptx>
import copy
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

from lxml import etree

BASE = Path(__file__).resolve().parent
SKILL = BASE / "skill_scripts"
NS = {
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "rel": "http://schemas.openxmlformats.org/package/2006/relationships",
}
A = "{%s}" % NS["a"]
P = "{%s}" % NS["p"]
R = "{%s}" % NS["r"]
EMU = 914400


# ---------------------------------------------------------------- utilidades
def emu(v):
    return str(int(round(v * EMU)))


def cargar(ruta):
    return etree.parse(str(ruta))


def guardar(arbol, ruta):
    arbol.write(str(ruta), xml_declaration=True, encoding="UTF-8", standalone=True)


def forma(arbol, nombre):
    for sh in arbol.find(".//p:spTree", NS):
        c = sh.find(".//p:cNvPr", NS)
        if c is not None and c.get("name") == nombre:
            return sh
    raise KeyError(nombre)


def xfrm_de(sh):
    for ruta in ("p:spPr/a:xfrm", "p:xfrm", ".//a:xfrm"):
        x = sh.find(ruta, NS)
        if x is not None:
            return x
    raise KeyError("sin xfrm")


def mover(sh, x=None, y=None, w=None, h=None):
    xf = xfrm_de(sh)
    off, ext = xf.find("a:off", NS), xf.find("a:ext", NS)
    if x is not None: off.set("x", emu(x))
    if y is not None: off.set("y", emu(y))
    if w is not None: ext.set("cx", emu(w))
    if h is not None: ext.set("cy", emu(h))


def parrafo_unico(sh):
    cuerpo = sh.find(".//p:txBody", NS)
    ps = cuerpo.findall("a:p", NS)
    for p in ps[1:]:
        cuerpo.remove(p)
    return ps[0]


def poner_texto(sh, texto):
    """Un solo parrafo y un solo run, con el formato del primer run."""
    p = parrafo_unico(sh)
    runs = p.findall("a:r", NS)
    for e in list(p):
        if e.tag == A + "br" or (e.tag == A + "r" and e is not runs[0]):
            p.remove(e)
    runs[0].find("a:t", NS).text = texto


def poner_runs(sh, textos):
    """Mantiene los primeros runs (con su formato propio) y les pone estos textos."""
    p = parrafo_unico(sh)
    runs = p.findall("a:r", NS)
    for r, t in zip(runs, textos):
        r.find("a:t", NS).text = t
    for r in runs[len(textos):]:
        p.remove(r)


def poner_lineas(sh, lineas):
    """Un parrafo con saltos de linea <a:br/>, con el formato del primer run."""
    p = parrafo_unico(sh)
    modelo = copy.deepcopy(p.find("a:r", NS))
    for e in list(p):
        if e.tag in (A + "r", A + "br"):
            p.remove(e)
    fin = p.find("a:endParaRPr", NS)
    pos = list(p).index(fin) if fin is not None else len(p)
    nuevos = []
    for i, linea in enumerate(lineas):
        if i:
            br = etree.Element(A + "br")
            br.append(copy.deepcopy(modelo.find("a:rPr", NS)))
            nuevos.append(br)
        r = copy.deepcopy(modelo)
        r.find("a:t", NS).text = linea
        nuevos.append(r)
    for j, e in enumerate(nuevos):
        p.insert(pos + j, e)


def tamano_fuente(sh, sz):
    for rp in sh.iter(A + "rPr", A + "endParaRPr"):
        rp.set("sz", str(sz))


def quitar(arbol, nombre):
    sh = forma(arbol, nombre)
    sh.getparent().remove(sh)


def nuevo_id(arbol):
    return max(int(c.get("id")) for c in arbol.iter(P + "cNvPr")) + 1


def copiar_formas(origen, destino, nombres):
    arbol_formas = destino.find(".//p:spTree", NS)
    for nombre in nombres:
        sh = copy.deepcopy(forma(origen, nombre))
        sh.find(".//p:cNvPr", NS).set("id", str(nuevo_id(destino)))
        arbol_formas.append(sh)


def franja_lectura(origen8, destino, y, h, texto, sz=None):
    """Copia la franja de lectura de la diapositiva 8 del grupo y la ubica en y."""
    copiar_formas(origen8, destino, ["Rectangle 24", "Rectangle 25", "TextBox 26"])
    mover(forma(destino, "Rectangle 24"), x=0.56, y=y, w=12.15, h=h)
    mover(forma(destino, "Rectangle 25"), x=0.56, y=y, w=0.08, h=h)
    caja = forma(destino, "TextBox 26")
    mover(caja, x=0.81, y=y + 0.07, w=11.64, h=h - 0.14)
    caja.find(".//a:bodyPr", NS).set("anchor", "ctr")
    poner_texto(caja, texto)
    if sz:
        tamano_fuente(caja, sz)


def numero_diapositiva(arbol, n):
    """Numero de diapositiva (campo automatico) abajo a la derecha."""
    xml = (
        f'<p:sp xmlns:p="{NS["p"]}" xmlns:a="{NS["a"]}">'
        f'<p:nvSpPr><p:cNvPr id="{nuevo_id(arbol)}" name="Numero de diapositiva"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>'
        f'<p:spPr><a:xfrm><a:off x="{emu(12.25)}" y="{emu(7.19)}"/><a:ext cx="{emu(0.7)}" cy="{emu(0.22)}"/></a:xfrm>'
        f'<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr>'
        f'<p:txBody><a:bodyPr wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="b"/><a:lstStyle/>'
        f'<a:p><a:pPr algn="r"/><a:fld id="{{B6F15528-21DE-4FAA-801E-634DDDAF4B2B}}" type="slidenum">'
        f'<a:rPr lang="es-AR" sz="1000"><a:solidFill><a:srgbClr val="667580"/></a:solidFill><a:latin typeface="Aptos"/></a:rPr>'
        f'<a:t>{n}</a:t></a:fld><a:endParaRPr lang="es-AR" sz="1000"/></a:p></p:txBody></p:sp>'
    )
    arbol.find(".//p:spTree", NS).append(etree.fromstring(xml))


def duplicar(trabajo, fuente, despues):
    res = subprocess.run([sys.executable, "add_slide.py", str(trabajo), fuente, "--after", despues],
                         cwd=SKILL, capture_output=True, text=True)
    print(res.stdout.strip(), res.stderr.strip())
    return res.stdout.split("Created ppt/slides/")[1].split(" ")[0].strip()


def apuntar_imagen(trabajo, slide, media):
    ruta = trabajo / "ppt" / "slides" / "_rels" / (slide + ".rels")
    rels = cargar(ruta)
    for r in rels.getroot():
        if r.get("Type").endswith("/image"):
            r.set("Target", f"../media/{media}")
    guardar(rels, ruta)


# ---------------------------------------------------------------- programa
def main(deck, grafico, salida):
    trabajo = Path(salida).resolve().parent / (Path(salida).stem + "_build")
    if trabajo.exists():
        shutil.rmtree(trabajo)
    with zipfile.ZipFile(deck) as z:
        z.extractall(trabajo)
    slides = trabajo / "ppt" / "slides"

    # 1. ESTRUCTURA: composicion rehecha con el esquema de la diap. 7, robustez con el de
    #    la 9; se saca la composicion vieja (grafico estirado). Todo antes de editar textos.
    comp = duplicar(trabajo, "slide7.xml", "slide10.xml")
    robu = duplicar(trabajo, "slide9.xml", comp)
    apuntar_imagen(trabajo, comp, "image7.png")                  # 03_g5 composicion
    shutil.copy(grafico, trabajo / "ppt" / "media" / "image8.png")
    apuntar_imagen(trabajo, robu, "image8.png")                  # 04_g3 conocimiento
    pres = cargar(trabajo / "ppt" / "presentation.xml")
    rels_pres = {r.get("Id"): r.get("Target") for r in cargar(trabajo / "ppt" / "_rels" / "presentation.xml.rels").getroot()}
    lista = pres.find("p:sldIdLst", NS)
    for sid in list(lista):
        if rels_pres[sid.get(R + "id")] == "slides/slide10.xml":
            lista.remove(sid)
    guardar(pres, trabajo / "ppt" / "presentation.xml")
    res = subprocess.run([sys.executable, "clean.py", str(trabajo)], cwd=SKILL, capture_output=True, text=True)
    print(res.stdout.strip(), res.stderr.strip())

    s = {n: cargar(slides / f"slide{n}.xml") for n in range(1, 10)}
    s[11] = cargar(slides / "slide11.xml")
    s["comp"] = cargar(slides / comp)
    s["robu"] = cargar(slides / robu)
    s8_original = copy.deepcopy(s[8])  # modelo de la franja de lectura

    # 2. DIAP. 1 · PORTADA: rotulo de la entrega, fecha, FCE-UBA y consistencia
    copiar_formas(s[2], s[1], ["Text 1"])
    rotulo = s[1].find(".//p:spTree", NS)[-1]
    rotulo.find(".//p:cNvPr", NS).set("name", "Rotulo entrega")
    mover(rotulo, x=1.04, y=1.08, w=9.0, h=0.2)
    poner_texto(rotulo, "TRABAJO PRÁCTICO · INSTANCIA 1: ANÁLISIS EXPLORATORIO DE DATOS")
    poner_runs(forma(s[1], "Text 4"), ["Comparado con Brasil, Chile y Uruguay", " · ", "2005–2024"])
    poner_lineas(forma(s[1], "Text 9"), [
        "Brenda Firmano · Diego Sebastián Díez de Los Ríos · Timothy Brandel",
        "Ciencia de Datos para Economía y Negocios · FCE-UBA · 21 de septiembre de 2026"])
    poner_texto(forma(s[1], "TextBox 13"),
                "Fuente: OCDE-OMC, Balanced Trade in Services (BaTiS), edición BPM6 — diciembre de 2025")

    # 3. DIAP. 2 · cobertura: 13 items = 12 categorias + el total
    poner_texto(forma(s[2], "TextBox 44"), "4 países · 12 categorías de servicio y el total.")

    # 4. DIAP. 4 · tabla de variables con descripcion y nulos (criterio de evaluacion)
    tabla_gf = forma(s[4], "Table 0")
    tbl = tabla_gf.find(".//a:tbl", NS)
    grilla = tbl.find("a:tblGrid", NS)
    nueva_col = copy.deepcopy(grilla.findall("a:gridCol", NS)[-1])
    nueva_col.find(".//{http://schemas.microsoft.com/office/drawing/2014/main}colId").set("val", "20003")
    grilla.append(nueva_col)
    for col, ancho in zip(grilla.findall("a:gridCol", NS), [1.30, 0.90, 2.10, 0.60]):
        col.set("w", emu(ancho))
    contenido = [
        ("Variable / grupo", "Tipo", "Descripción y uso", "Nulos"),
        ("Final_value", "Numérica", "Valor exportado que informa el país; variable principal", "0"),
        ("Reported_value", "Numérica", "Dato informado; vacío (NA) si el valor fue estimado", "103"),
        ("Balanced_value", "Numérica", "Valor conciliado con los socios; control de calidad", "0"),
        ("Year", "Temporal", "Año, de 2005 a 2024", "0"),
        ("Reporter, Item_code", "Categóricas", "País (4) y categoría de servicio (13); agrupan", "0"),
        ("Partner, Flow", "Categóricas", "Socio y flujo; filtros: mundo y exportaciones", "0"),
        ("Methodology, type_*", "Categóricas", "Método del dato y tipos; constantes o trazabilidad", "0"),
    ]
    for fila, textos in zip(tbl.findall("a:tr", NS), contenido):
        # La celda nueva va antes del extLst de la fila (id de fila): si va despues, PowerPoint la ignora
        ext = fila.find("a:extLst", NS)
        pos = list(fila).index(ext) if ext is not None else len(fila)
        fila.insert(pos, copy.deepcopy(fila.findall("a:tc", NS)[-1]))
        for celda, texto in zip(fila.findall("a:tc", NS), textos):
            celda.find(".//a:r/a:t", NS).text = texto
        tamano_fuente(fila, 1050)
    mover(tabla_gf, w=4.90)
    mover(forma(s[4], "Shape 3"), w=4.90)
    mover(forma(s[4], "Text 5"), w=4.41)
    mover(forma(s[4], "Text 6"), w=4.41)
    poner_texto(forma(s[4], "Text 6"),
                "Pocos rubros concentran montos muy altos (asimetría a la derecha): la mediana (USD 228 M) "
                "describe mejor el valor típico que la media (USD 1.219 M). Los 150 ceros quedan fuera de la "
                "escala logarítmica; 80 son de Chile, en categorías que no informa.")
    mover(forma(s[4], "Shape 7"), x=5.72, w=6.99)
    mover(forma(s[4], "Text 8"), x=5.95)
    mover(forma(s[4], "Distribución de valores"), x=5.82, w=6.80, h=6.80 * 5.01 / 7.31)

    # 5. DIAP. 5 · fuente oficial (no "nacional"), definicion de Final_value y lectura del grafico
    poner_texto(forma(s[5], "TextBox 14"),
                "Porcentaje de las 260 observaciones de cada país informado por una fuente oficial "
                "(FMI, fuente nacional u OCDE). En Chile, 4 categorías y los años 2023–2024 son estimados.")
    poner_runs(forma(s[5], "TextBox 13"), [
        "Final_value", " ",
        "es el valor que informa cada país en su balanza de pagos, completado con estimaciones de "
        "OCDE-OMC donde falta, sin conciliarlo con lo que declaran sus socios."])
    mover(forma(s[5], "Shape 3"), h=4.62)
    mover(forma(s[5], "Shape 7"), h=4.62)
    alto = 4.50
    mover(forma(s[5], "Brecha balanceado final"), x=5.48 + (7.58 - alto * 8 / 5.5) / 2, y=1.59,
          w=alto * 8 / 5.5, h=alto)
    franja_lectura(s8_original, s[5], y=6.30, h=0.82, sz=1400, texto=(
        "Lectura: la brecha no es pareja. Argentina queda siempre por debajo (−2,8% a −18,5%), Chile llega "
        "a +57% y Uruguay pasa de +44% a negativo desde 2012; en Chile las dos medidas casi no se mueven "
        "juntas (correlación 0,67)."))

    # 6. DIAP. 6 · coeficiente de variacion y lectura que interpreta el grafico
    for nombre, texto in [("Text 6", "Brasil · millones de USD · CV 0,26"), ("Text 8", "Argentina · CV 0,23"),
                          ("Text 10", "Chile · CV 0,20"), ("Text 12", "Uruguay · CV 0,41")]:
        poner_texto(forma(s[6], nombre), texto)
    poner_texto(forma(s[6], "TextBox 21"),
                "Lectura: Brasil lidera en escala (su mediana es 2,5 veces la argentina). Los cuatro caen en "
                "2020 y vuelven a crecer. Uruguay es el más disperso en términos relativos (CV = desvío / media).")

    # 7. DIAP. 7 · inicio -> fin, robustez frente a los anios estimados de Chile y aumento absoluto
    for nombre, texto in [("Text 6", "+430% · 9,2% anual · 1.311 → 6.948"),
                          ("Text 10", "+228% · 6,5% anual · 14.763 → 48.477"),
                          ("Text 14", "+165% · 5,3% anual · 6.458 → 17.122"),
                          ("Text 18", "+76% · 3,0% anual · 6.658 → 11.744")]:
        poner_texto(forma(s[7], nombre), texto)
    poner_texto(forma(s[7], "TextBox 26"),
                "Valores nominales en millones de USD (2005 → 2024), que incluyen la inflación de EE.UU. "
                "En 2005–2022, los años que Chile informó, el orden es el mismo. Brasil tiene el mayor "
                "aumento absoluto: +33.714.")

    # 8. DIAP. 8 · desvio (la medida de volatilidad) y lectura
    for titulo, cuerpo, t1, t2 in [("Text 5", "Text 6", "Argentina · 8 caídas", "Media 6,7% · mediana 1,6% · desvío 17,6 pp"),
                                   ("Text 9", "Text 10", "Brasil · 6 caídas", "Media 7,3% · mediana 5,0% · desvío 13,8 pp"),
                                   ("Text 13", "Text 14", "Chile · 7 caídas", "Media 4,6% · mediana 6,9% · desvío 18,0 pp"),
                                   ("Text 17", "Text 18", "Uruguay · 5 caídas", "Media 10,7% · mediana 4,6% · desvío 19,0 pp")]:
        poner_texto(forma(s[8], titulo), t1)
        poner_texto(forma(s[8], cuerpo), t2)
    mover(forma(s[8], "Rectangle 24"), y=6.13, h=0.80)
    mover(forma(s[8], "Rectangle 25"), y=6.13, h=0.80)
    caja8 = forma(s[8], "TextBox 26")
    mover(caja8, y=6.20, h=0.66)
    caja8.find(".//a:bodyPr", NS).set("anchor", "ctr")
    poner_texto(caja8, "Lectura: la media argentina se parece a la regional, pero su mediana es la más baja y tiene "
                       "más años de caída (8 de 19). Su desvío no es el más alto: Uruguay y Chile oscilan más.")

    # 9. DIAP. 9 · los atipicos se explican, no se borran (advertencia 2 del docente)
    franja_lectura(s8_original, s[9], y=6.33, h=0.80, texto=(
        "Lectura: los años atípicos coinciden con el shock de la pandemia y su rebote: se explican, no se "
        "eliminan. La recuperación se mide contra 2019, el nivel previo al shock."))

    # 10. DIAP. 10 · COMPOSICION con el esquema del resto (grafico en su proporcion real)
    c = s["comp"]
    poner_texto(forma(c, "Text 1"), "09 · COMPOSICIÓN 2005 VS. 2024")
    mover(forma(c, "Text 1"), w=3.2)
    poner_texto(forma(c, "Text 2"), "Composición de las exportaciones de servicios, 2005 y 2024")
    tarjetas = [("Shape 3", "Shape 4", "Text 5", "Text 6", "Argentina", "Conocimiento: creció del 31% al 51% del total."),
                ("Shape 7", "Shape 8", "Text 9", "Text 10", "Uruguay", "La mayor transformación: 12% → 47%."),
                ("Shape 11", "Shape 12", "Text 13", "Text 14", "Patrón regional", "Transporte pierde peso en los cuatro. Viajes cae salvo en Chile."),
                ("Shape 15", "Shape 16", "Text 17", "Text 18", "Diversificación", "Las tres categorías principales pesan menos que en 2005 en todos los países.")]
    for i, (caja, linea, tit, cue, t1, t2) in enumerate(tarjetas):
        y0 = 1.16 + i * 1.327
        mover(forma(c, caja), y=y0, h=1.12)
        mover(forma(c, linea), y=y0, h=1.12)
        mover(forma(c, tit), y=y0 + 0.15)
        mover(forma(c, cue), y=y0 + 0.47, h=0.60)
        poner_texto(forma(c, tit), t1)
        poner_texto(forma(c, cue), t2)
    quitar(c, "Text 20")
    img = forma(c, "Evolución relativa")
    img.find(".//p:cNvPr", NS).set("name", "Composición 2005 2024")
    alto = 5.0
    mover(img, x=4.31 + (8.84 - alto * 10 / 6.5) / 2, y=1.21, w=alto * 10 / 6.5, h=alto)
    poner_texto(forma(c, "TextBox 26"),
                "Lectura: la canasta se desplazó hacia informática y otros servicios empresariales, y transporte "
                "perdió peso. Las participaciones se calculan sobre el total S; “conocimiento” reúne ambos rubros; "
                "Chile 2024 es estimado.")

    # 11. DIAP. 11 · ROBUSTEZ (misma construccion que armar_robustez.py)
    b = s["robu"]
    poner_texto(forma(b, "Text 1"), "10 · ROBUSTEZ DE LA MEDIDA")
    mover(forma(b, "Text 1"), w=3.2)
    poner_texto(forma(b, "Text 2"), "¿Cambian los hallazgos si se usa el valor balanceado?")
    mover(forma(b, "Shape 3"), h=4.55)
    poner_texto(forma(b, "Text 4"), "Chequeo con el valor balanceado")
    mover(forma(b, "Shape 5"), y=2.05, h=1.45)
    poner_texto(forma(b, "Text 6"), "SE MANTIENEN CON LAS DOS MEDIDAS"); mover(forma(b, "Text 6"), y=2.15)
    poner_texto(forma(b, "Text 7"), "9 de 20"); mover(forma(b, "Text 7"), y=2.38)
    poner_texto(forma(b, "Text 8"), "La dirección del cambio en la composición, la diversificación de las "
                                    "canastas y la menor recuperación de Argentina frente a 2019.")
    mover(forma(b, "Text 8"), y=2.82, h=0.62)
    mover(forma(b, "Shape 9"), y=3.62, h=1.45)
    poner_texto(forma(b, "Text 10"), "CAMBIAN CON EL BALANCEADO"); mover(forma(b, "Text 10"), y=3.72)
    poner_texto(forma(b, "Text 11"), "11 de 20"); mover(forma(b, "Text 11"), y=3.95)
    poner_texto(forma(b, "Text 12"), "El nivel y el perfil de Argentina: conocimiento en 2024 "
                                     "(51,0% → 36,5%), su ventaja sobre Chile y ser la que más cae.")
    mover(forma(b, "Text 12"), y=4.39, h=0.62)
    poner_texto(forma(b, "Text 13"), "Como la medida cambia resultados, se elige por lo que mide: el valor "
                                     "final es lo que informa cada país.")
    mover(forma(b, "Text 13"), y=5.22, h=0.70)
    mover(forma(b, "Shape 14"), h=4.55)
    quitar(b, "Text 15")
    pic = forma(b, "Boxplot tasas")
    cnv = pic.find(".//p:cNvPr", NS)
    cnv.set("name", "Conocimiento final vs balanceado")
    cnv.set("descr", "Peso de los servicios de conocimiento en 2005 y 2024, con el valor final y el balanceado")
    mover(pic, x=5.52 + (7.19 - 7.0) / 2, y=1.46 + (4.55 - 7.0 * 4.4 / 7.2) / 2, w=7.0, h=7.0 * 4.4 / 7.2)
    franja_lectura(s8_original, b, y=6.21, h=0.64, texto=(
        "Lectura: se mantiene la dirección del cambio; el nivel y el perfil de Argentina dependen de la medida."))

    # 12. DIAP. 12 · HALLAZGOS: numeracion de seccion y dos correcciones de cifras
    h = s[11]
    poner_texto(forma(h, "Text 1"), "11 · HALLAZGOS Y PREGUNTAS")
    poner_texto(forma(h, "Text 7"), "Argentina creció menos que Uruguay y Brasil")
    poner_texto(forma(h, "Text 8"), "+165% nominal (5,3% anual), frente a +430% de Uruguay y +228% de Brasil; Chile, +76%.")
    poner_texto(forma(h, "Text 17"), "Su mediana anual es USD 33.156 M: más del doble que Argentina y casi cuatro veces Chile.")
    poner_texto(forma(h, "TextBox 31"),
                "Cierre: los resultados son descriptivos y nominales. La próxima etapa deberá deflactar los valores "
                "y contrastar las diferencias entre países con herramientas inferenciales.")

    # 13. NUMERACION de las diapositivas 2 a 12, en el orden final
    orden = [2, 3, 4, 5, 6, 7, 8, 9, "comp", "robu", 11]
    for n, clave in enumerate(orden, start=2):
        numero_diapositiva(s[clave], n)

    nombres = {n: f"slide{n}.xml" for n in list(range(1, 10)) + [11]}
    nombres["comp"], nombres["robu"] = comp, robu
    for clave, arbol in s.items():
        guardar(arbol, slides / nombres[clave])

    # 14. Empaquetar ([Content_Types].xml primero)
    archivos = sorted(p for p in trabajo.rglob("*") if p.is_file())
    archivos.sort(key=lambda p: p.name != "[Content_Types].xml")
    if Path(salida).exists():
        Path(salida).unlink()
    with zipfile.ZipFile(salida, "w", zipfile.ZIP_DEFLATED) as z:
        for p in archivos:
            z.write(p, p.relative_to(trabajo).as_posix())
    print("Creado:", salida, "| composición:", comp, "| robustez:", robu)


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main(*sys.argv[1:4])
