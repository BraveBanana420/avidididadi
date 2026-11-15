"""Genera lib/l10n/testi_salvati.dart.

I generatori del piano scrivono nei CSV testi presi da l10n (nomi dei passi,
note, titoli) nella lingua in uso quando il piano nasce. Se poi si cambia
lingua, quei testi restano nella lingua di prima. Questo script raccoglie i
testi usati dai generatori con le loro traduzioni, così l'app li riconosce e
li mostra nella lingua scelta.

Uso (dalla cartella del progetto): python tool/genera_testi_salvati.py
Da rilanciare dopo aver cambiato i testi dei generatori negli ARB.
"""

import json
import re
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
FILE_GENERATORI = [
    "lib/generatore_forza.dart",
    "lib/generatore_endurance.dart",
    "lib/generatore_mobilita.dart",
    "lib/workout_base.dart",
    "lib/potenza.dart",
    "lib/generator.dart",
]
LINGUE = ["it", "en", "el"]


def arb(lingua):
    with open(RADICE / f"lib/l10n/app_{lingua}.arb", encoding="utf-8") as f:
        return json.load(f)


def chiavi_usate():
    chiavi = set()
    for nome in FILE_GENERATORI:
        testo = (RADICE / nome).read_text(encoding="utf-8")
        chiavi.update(re.findall(r"\bl10n\.(\w+)", testo))
    return chiavi


def stringa_dart(s):
    s = s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
    return "'" + s.replace("\n", "\\n") + "'"


def main():
    testi = {l: arb(l) for l in LINGUE}
    righe = []
    visti = set()
    for chiave in sorted(chiavi_usate()):
        valori = [testi[l].get(chiave) for l in LINGUE]
        if any(not isinstance(v, str) for v in valori):
            continue
        it = valori[0]
        # Testi troppo corti o con solo segnaposto non si riconoscono bene.
        if len(re.sub(r"\{p\d\}", "", it).strip()) < 3 or it in visti:
            continue
        visti.add(it)
        righe.append(
            "  (" + ", ".join(stringa_dart(v) for v in valori) + "),"
        )
    uscita = RADICE / "lib/l10n/testi_salvati.dart"
    uscita.write_text(
        "// File generato da tool/genera_testi_salvati.py: non modificarlo a mano.\n\n"
        "/// Testi che i generatori salvano nei dati (italiano, inglese, greco),\n"
        "/// con i segnaposto {p0}, {p1}… dove c'è un valore.\n"
        "const testiSalvati = <(String, String, String)>[\n"
        + "\n".join(righe)
        + "\n];\n",
        encoding="utf-8",
    )
    print(f"{len(righe)} testi in {uscita.relative_to(RADICE)}")


if __name__ == "__main__":
    main()
