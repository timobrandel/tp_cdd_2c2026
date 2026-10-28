# Detalle de formas por diapositiva: posicion, relleno, fuentes por run, tablas y recortes.
# Uso: python detalle_pptx.py deck.pptx 1,2,4
import sys
import zipfile
import posixpath
from lxml import etree

NS = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main",
      "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
      "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      "rel": "http://schemas.openxmlformats.org/package/2006/relationships"}
E = 914400


def pos(sh):
    x = sh.find("p:spPr/a:xfrm", NS)
    if x is None:
        x = sh.find("p:xfrm", NS)
    if x is None:
        x = sh.find(".//a:xfrm", NS)
    if x is None:
        return ""
    o, e = x.find("a:off", NS), x.find("a:ext", NS)
    return f"x={int(o.get('x'))/E:.2f} y={int(o.get('y'))/E:.2f} w={int(e.get('cx'))/E:.2f} h={int(e.get('cy'))/E:.2f}"


def runs(elem):
    out = []
    for p in elem.findall(".//a:p", NS):
        partes = []
        for r in p:
            tag = etree.QName(r).localname
            if tag not in ("r", "fld"):
                continue
            rp = r.find("a:rPr", NS)
            t = r.find("a:t", NS)
            col = rp.find("a:solidFill/a:srgbClr", NS) if rp is not None else None
            partes.append(f"[{rp.get('sz') if rp is not None else '-'}{'b' if rp is not None and rp.get('b')=='1' else ''}"
                          f"{'i' if rp is not None and rp.get('i')=='1' else ''} {col.get('val') if col is not None else ''}]{t.text if t is not None else ''}")
        algn = p.find("a:pPr", NS)
        if partes:
            out.append(f"      p(algn={algn.get('algn') if algn is not None else ''}): " + " ".join(partes))
    return out


z = zipfile.ZipFile(sys.argv[1])
pres = etree.fromstring(z.read("ppt/presentation.xml"))
rels = {r.get("Id"): r.get("Target") for r in etree.fromstring(z.read("ppt/_rels/presentation.xml.rels"))}
ids = [rels[s.get("{%s}id" % NS["r"])] for s in pres.find("p:sldIdLst", NS)]
quiero = [int(n) for n in sys.argv[2].split(",")]
sys.stdout.reconfigure(encoding="utf-8")
for n in quiero:
    ruta = posixpath.join("ppt", ids[n - 1])
    s = etree.fromstring(z.read(ruta))
    print(f"===== Diapositiva {n} ({ruta}) =====")
    for sh in s.find(".//p:spTree", NS):
        tag = etree.QName(sh).localname
        if tag not in ("sp", "pic", "graphicFrame", "grpSp", "cxnSp"):
            continue
        c = sh.find(".//p:cNvPr", NS)
        sp = sh.find("p:spPr", NS)
        geo = sp.find("a:prstGeom", NS) if sp is not None else None
        fill = sp.find("a:solidFill/a:srgbClr", NS) if sp is not None else None
        ln = sp.find("a:ln/a:solidFill/a:srgbClr", NS) if sp is not None else None
        body = sh.find(".//a:bodyPr", NS)
        ins = f" ins(l,t,r,b)={body.get('lIns')},{body.get('tIns')},{body.get('rIns')},{body.get('bIns')} anchor={body.get('anchor')} autofit={'norm' if body is not None and body.find('a:normAutofit', NS) is not None else ('sp' if body is not None and body.find('a:spAutoFit', NS) is not None else '-')}" if body is not None else ""
        print(f"  {tag} '{c.get('name')}' {pos(sh)} geo={geo.get('prst') if geo is not None else ''} fill={fill.get('val') if fill is not None else '-'} ln={ln.get('val') if ln is not None else '-'}{ins}")
        if tag == "pic":
            src = sh.find(".//a:srcRect", NS)
            print(f"      srcRect={dict(src.attrib) if src is not None else None}")
        tbl = sh.find(".//a:tbl", NS)
        if tbl is not None:
            print("      cols=" + ", ".join(f"{int(g.get('w'))/E:.2f}" for g in tbl.findall("a:tblGrid/a:gridCol", NS)))
            for fila in tbl.findall("a:tr", NS):
                celdas = []
                for tc in fila.findall("a:tc", NS):
                    rp = tc.find(".//a:rPr", NS)
                    txt = " / ".join("".join(t.text or "" for t in p.iter("{%s}t" % NS["a"])) for p in tc.findall(".//a:p", NS))
                    celdas.append(f"{txt}[{rp.get('sz') if rp is not None else '-'}]")
                print(f"      fila h={int(fila.get('h'))/E:.2f}: " + " | ".join(celdas))
        else:
            for linea in runs(sh):
                print(linea)
