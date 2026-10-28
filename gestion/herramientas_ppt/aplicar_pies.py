# Reescribe los pies de las diap. 3 y 5 a 12 y empareja su formato (D-022):
# texto sin rotulos, 14 pt en los pies de lectura, filete verde 2F7D7A de 0,08".
# Uso: python aplicar_pies.py <deck.pptx>
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

from lxml import etree

NS = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main",
      "p": "http://schemas.openxmlformats.org/presentationml/2006/main"}
A = "{%s}" % NS["a"]
EMU = 914400
VERDE = "2F7D7A"

# (texto, tamanio en centesimas de punto o None para conservarlo)
TEXTOS = {
    "ppt/slides/slide3.xml": {"TextBox 24": ("Análisis descriptivo, sin inferir causas, en USD corrientes sin deflactar.", None)},
    "ppt/slides/slide5.xml": {"TextBox 26": ("La brecha no es pareja: Argentina queda siempre por debajo (−2,8% a −18,5%) y Chile llega a +57%. Por eso la elección de la medida cambia resultados (diap. 11).", 1400)},
    "ppt/slides/slide6.xml": {"TextBox 21": ("Brasil opera en otra escala: su mediana es 2,5 veces la argentina. El CV alto de Uruguay refleja su crecimiento, no oscilaciones; la volatilidad se mide con las tasas (diap. 8).", 1400)},
    "ppt/slides/slide7.xml": {"TextBox 26": ("Argentina queda tercera. Son valores nominales, que incluyen la inflación de EE.UU.; el orden no cambia en 2005–2022, los años que Chile informó.", 1400)},
    "ppt/slides/slide8.xml": {"TextBox 26": ("El rebote de 2022 (+50,3%) eleva la media argentina; la mediana (1,6%, la más baja) refleja un crecimiento típico bajo. Su desvío no es el mayor: Uruguay y Chile oscilan más.", 1400)},
    "ppt/slides/slide9.xml": {"TextBox 26": ("Los dos atípicos de Argentina coinciden con el shock de 2020 y su rebote de 2022, y se conservan. Contra 2019, es la que menos se recuperó (+15,7%).", 1400)},
    "ppt/slides/slide10.xml": {"TextBox 26": ("En los cuatro, la canasta se desplaza hacia conocimiento (informática + servicios empresariales) y transporte pierde peso. Participaciones sobre el total de servicios; Chile 2024 es estimado.", 1400)},
    "ppt/slides/slide11.xml": {"TextBox 26": ("La dirección del cambio no depende de la medida; el nivel y el perfil de Argentina, sí. Por eso esos resultados se leen con cautela.", 1400)},
    "ppt/slides/slide12.xml": {"TextBox 31": ("Resultados descriptivos, en USD corrientes y con Chile 2023–2024 estimado. La próxima etapa deberá deflactar y contrastar las diferencias con herramientas inferenciales.", None)},
}
# Filetes: (color, x en pulgadas o None, ancho en pulgadas o None)
FILETES = {
    "ppt/slides/slide6.xml": {"Rectangle 20": (VERDE, 0.56, 0.08)},
    "ppt/slides/slide7.xml": {"Rectangle 25": (VERDE, None, None)},
    "ppt/slides/slide10.xml": {"Rectangle 25": (VERDE, None, None)},
}


def poner_texto(sh, texto, tam):
    """Un solo parrafo y un solo run, con el formato del primer run."""
    cuerpo = sh.find(".//p:txBody", NS)
    ps = cuerpo.findall("a:p", NS)
    for p in ps[1:]:
        cuerpo.remove(p)
    p = ps[0]
    runs = p.findall("a:r", NS)
    for e in list(p):
        if e.tag == A + "br" or (e.tag == A + "r" and e is not runs[0]):
            p.remove(e)
    runs[0].find("a:t", NS).text = texto
    if tam:
        runs[0].find("a:rPr", NS).set("sz", str(tam))
        epr = p.find("a:endParaRPr", NS)
        if epr is not None:
            epr.set("sz", str(tam))


def poner_filete(sh, color, x, w):
    clr = sh.find("p:spPr/a:solidFill/a:srgbClr", NS)
    clr.set("val", color)
    xf = sh.find("p:spPr/a:xfrm", NS)
    if x is not None:
        xf.find("a:off", NS).set("x", str(round(x * EMU)))
    if w is not None:
        xf.find("a:ext", NS).set("cx", str(round(w * EMU)))


def main(ruta):
    ruta = Path(ruta)
    tmp = Path(tempfile.mkdtemp()) / ruta.name
    with zipfile.ZipFile(ruta) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            datos = zin.read(item.filename)
            textos = dict(TEXTOS.get(item.filename, {}))
            filetes = dict(FILETES.get(item.filename, {}))
            if textos or filetes:
                arbol = etree.fromstring(datos)
                for sh in arbol.iter("{%s}sp" % NS["p"]):
                    nombre = sh.find(".//p:cNvPr", NS).get("name")
                    if nombre in textos:
                        poner_texto(sh, *textos.pop(nombre))
                    elif nombre in filetes:
                        poner_filete(sh, *filetes.pop(nombre))
                if textos or filetes:
                    raise KeyError(f"{item.filename}: faltan {list(textos) + list(filetes)}")
                datos = etree.tostring(arbol, xml_declaration=True, encoding="UTF-8", standalone=True)
            zout.writestr(item, datos)
    shutil.copyfile(tmp, ruta)
    print("OK:", ruta)


if __name__ == "__main__":
    main(sys.argv[1])
