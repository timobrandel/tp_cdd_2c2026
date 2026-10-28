# Vuelca el contenido de un .pptx por diapositiva: textos (por forma y parrafo),
# tablas, imagenes y graficos. Uso: python volcar_pptx.py deck.pptx > salida.md
import sys
import zipfile
import posixpath
from lxml import etree

NS = {
    "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "rel": "http://schemas.openxmlformats.org/package/2006/relationships",
}
EMU_POR_PULGADA = 914400


def leer_xml(z, ruta):
    return etree.fromstring(z.read(ruta))


def relaciones(z, ruta_parte):
    carpeta, nombre = posixpath.split(ruta_parte)
    ruta_rels = posixpath.join(carpeta, "_rels", nombre + ".rels")
    if ruta_rels not in z.namelist():
        return {}
    rels = leer_xml(z, ruta_rels)
    return {
        r.get("Id"): posixpath.normpath(posixpath.join(carpeta, r.get("Target")))
        for r in rels.findall("rel:Relationship", NS)
    }


def texto_parrafos(elem):
    parrafos = []
    for p in elem.iter("{%s}p" % NS["a"]):
        t = "".join(x.text or "" for x in p.iter("{%s}t" % NS["a"]))
        if t.strip():
            parrafos.append(t)
    return parrafos


def posicion(sp):
    off = sp.find(".//a:xfrm/a:off", NS)
    ext = sp.find(".//a:xfrm/a:ext", NS)
    if off is None or ext is None:
        return ""
    f = lambda v: round(int(v) / EMU_POR_PULGADA, 2)
    return f"[x={f(off.get('x'))} y={f(off.get('y'))} w={f(ext.get('cx'))} h={f(ext.get('cy'))}]"


def main(ruta):
    z = zipfile.ZipFile(ruta)
    pres = leer_xml(z, "ppt/presentation.xml")
    rels_pres = relaciones(z, "ppt/presentation.xml")
    tam = pres.find("p:sldSz", NS)
    print(f"# {ruta}  (lienzo {int(tam.get('cx'))/EMU_POR_PULGADA:.2f} x {int(tam.get('cy'))/EMU_POR_PULGADA:.2f} in)\n")
    for n, sid in enumerate(pres.find("p:sldIdLst", NS), start=1):
        ruta_slide = rels_pres[sid.get("{%s}id" % NS["r"])]
        slide = leer_xml(z, ruta_slide)
        rels = relaciones(z, ruta_slide)
        print(f"\n<!-- Diapositiva {n}: {ruta_slide} -->")
        for forma in slide.find(".//p:spTree", NS):
            etiqueta = etree.QName(forma).localname
            nombre = forma.find(".//p:cNvPr", NS)
            nombre = nombre.get("name") if nombre is not None else "?"
            if etiqueta == "sp":
                pars = texto_parrafos(forma)
                if pars:
                    print(f"- TEXTO '{nombre}' {posicion(forma)}")
                    for t in pars:
                        print(f"    | {t}")
            elif etiqueta == "pic":
                blip = forma.find(".//a:blip", NS)
                destino = rels.get(blip.get("{%s}embed" % NS["r"])) if blip is not None else "?"
                print(f"- IMAGEN '{nombre}' {posicion(forma)} -> {destino}")
            elif etiqueta == "graphicFrame":
                tabla = forma.find(".//a:tbl", NS)
                if tabla is not None:
                    print(f"- TABLA '{nombre}' {posicion(forma)}")
                    for fila in tabla.findall("a:tr", NS):
                        celdas = [" ".join(texto_parrafos(c)) for c in fila.findall("a:tc", NS)]
                        print("    | " + " | ".join(celdas))
                else:
                    print(f"- MARCO GRAFICO '{nombre}' {posicion(forma)} (grafico u objeto)")
            elif etiqueta == "grpSp":
                pars = texto_parrafos(forma)
                print(f"- GRUPO '{nombre}' {posicion(forma)}")
                for t in pars:
                    print(f"    | {t}")
                for pic in forma.iter("{%s}pic" % NS["p"]):
                    blip = pic.find(".//a:blip", NS)
                    if blip is not None:
                        print(f"    (imagen) -> {rels.get(blip.get('{%s}embed' % NS['r']))}")
        notas = [d for d in rels.values() if "notesSlide" in d]
        if notas:
            pars = texto_parrafos(leer_xml(z, notas[0]))
            pars = [t for t in pars if not t.strip().isdigit()]
            if pars:
                print("- NOTAS DEL ORADOR:")
                for t in pars:
                    print(f"    | {t}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main(sys.argv[1])
