# Cambia el hallazgo 5 (diversificacion) y las dos preguntas de la diap. 12 (D-022).
# Reutiliza la edicion de aplicar_hallazgos.py (un parrafo, formato del primer run).
# Uso: python aplicar_preguntas.py <deck.pptx>
import sys

import aplicar_hallazgos as ah

ah.CAMBIOS = {
    "ppt/slides/slide12.xml": {
        "Text 16": "Canastas más diversificadas",
        "Text 17": "Las tres categorías principales pesan menos en los cuatro países; en Argentina, de 87,2% a 79,9% (−7,3 pp con las dos medidas).",
        "Text 22": "¿Argentina tiene ventaja comparativa revelada en servicios de conocimiento?",
        "Text 25": "¿Argentina crece significativamente menos que sus vecinos?",
    },
}

if __name__ == "__main__":
    ah.main(sys.argv[1])
