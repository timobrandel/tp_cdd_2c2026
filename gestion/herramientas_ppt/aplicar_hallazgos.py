# Reescribe los hallazgos y el cierre de la diap. 12 y la lectura de la diap. 11 (D-022).
# Edita el XML en su lugar conservando el formato del primer run de cada caja.
# Uso: python aplicar_hallazgos.py <deck.pptx>
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

from lxml import etree

NS = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main",
      "p": "http://schemas.openxmlformats.org/presentationml/2006/main"}
A = "{%s}" % NS["a"]

CAMBIOS = {
    "ppt/slides/slide12.xml": {
        "Text 4": "Nivel: Argentina, muy lejos de Brasil",
        "Text 5": "La mediana anual brasileña (USD 33.156 M) es 2,5 veces la argentina; con el valor balanceado, 3,0 veces.",
        "Text 7": "Argentina creció menos que Uruguay y Brasil",
        "Text 8": "5,3% anual nominal en 2005–2024, contra 9,2% de Uruguay y 6,5% de Brasil. El orden se mantiene con el balanceado.",
        "Text 10": "Menor recuperación tras la pandemia",
        "Text 11": "En 2024 supera a 2019 solo en 15,7% (vecinos: 25,8% a 46,8%). Su desvío anual no es el mayor: Uruguay y Chile oscilan más.",
        "Text 13": "Giro hacia servicios de conocimiento",
        "Text 14": "Informática y servicios empresariales ganan peso en los cuatro. Mayor suba: Uruguay (+35,6 pp); segunda, Argentina (+19,9 pp).",
        "Text 16": "El dato es informado, pero la medida importa",
        "Text 17": "Argentina, Brasil y Uruguay informan ≥98,5% de sus datos; Chile, 62,3%. Con el balanceado cambian 11 de 20 afirmaciones.",
        "TextBox 31": "Cierre: resultados descriptivos, en USD corrientes y con Chile 2023–2024 estimado. La próxima etapa deberá deflactar y contrastar las diferencias con herramientas inferenciales.",
    },
    "ppt/slides/slide11.xml": {
        "TextBox 26": "Lectura: la dirección del cambio no depende de la medida; el nivel y el perfil de Argentina, sí. Por eso esos resultados se leen con cautela.",
    },
}


def poner_texto(sh, texto):
    """Deja un solo parrafo y un solo run, con el formato del primer run."""
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


def main(ruta):
    ruta = Path(ruta)
    tmp = Path(tempfile.mkdtemp()) / ruta.name
    with zipfile.ZipFile(ruta) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            datos = zin.read(item.filename)
            if item.filename in CAMBIOS:
                arbol = etree.fromstring(datos)
                pendientes = dict(CAMBIOS[item.filename])
                for sh in arbol.iter("{%s}sp" % NS["p"]):
                    nombre = sh.find(".//p:cNvPr", NS).get("name")
                    if nombre in pendientes:
                        poner_texto(sh, pendientes.pop(nombre))
                if pendientes:
                    raise KeyError(f"{item.filename}: no encontré {list(pendientes)}")
                datos = etree.tostring(arbol, xml_declaration=True, encoding="UTF-8", standalone=True)
            zout.writestr(item, datos)
    shutil.copyfile(tmp, ruta)
    print("OK:", ruta)


if __name__ == "__main__":
    main(sys.argv[1])
