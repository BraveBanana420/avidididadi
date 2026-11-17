"""Prepara la variante "foss" dell'app: senza Google Play Services, per F-Droid.

Due plugin portano con sé librerie di Google che non sono libere:
- geolocator_android: play-services-location (posizione "fused");
- maplibre_gl: play-services-base e -location (solo per il pallino "la mia
  posizione" sulla mappa, che l'app non usa).

Lo script copia i due plugin dalla cache di pub in .foss/, toglie le parti di
Google (tutti e due ripiegano già sul LocationManager di Android quando Google
manca) e scrive pubspec_overrides.yaml, che fa usare a Flutter le copie.
La build normale non cambia: senza pubspec_overrides.yaml è quella di sempre.

Uso:
    flutter pub get
    python3 tool/prepara_foss.py
    flutter build apk --release --split-per-abi --dart-define=COMMIT=...
    python3 tool/prepara_foss.py --ripristina   # torna alla build normale

Se un plugin cambia versione e una modifica non si applica più, lo script si
ferma con un errore: va aggiornato insieme al plugin.
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

radice = Path(__file__).resolve().parent.parent
cartella = radice / ".foss"
overrides = radice / "pubspec_overrides.yaml"
GMS = "com.google.android.gms"


def pub_get():
    flutter = shutil.which("flutter")
    if flutter is None:
        sys.exit("Manca il comando flutter nel PATH.")
    subprocess.run([flutter, "pub", "get"], cwd=radice, check=True)


def pacchetti():
    """Nome → cartella di ogni pacchetto, da .dart_tool/package_config.json."""
    config = radice / ".dart_tool" / "package_config.json"
    if not config.exists():
        sys.exit("Lancia prima 'flutter pub get'.")
    dati = json.loads(config.read_text(encoding="utf-8"))
    base = config.parent
    risultato = {}
    for p in dati["packages"]:
        uri = p["rootUri"]
        if uri.startswith("file://"):
            percorso = Path(unquote(urlparse(uri).path))
        else:
            percorso = (base / unquote(uri)).resolve()
        risultato[p["name"]] = percorso
    return risultato


def sostituisci(file, vecchio, nuovo, regex=False):
    testo = file.read_text(encoding="utf-8")
    if regex:
        nuovo_testo, n = re.subn(vecchio, nuovo, testo, flags=re.S)
    else:
        n = testo.count(vecchio)
        nuovo_testo = testo.replace(vecchio, nuovo)
    if n == 0:
        sys.exit(f"Modifica non applicabile in {file}: il plugin è cambiato?\n  {vecchio!r}")
    file.write_text(nuovo_testo, encoding="utf-8")


def togli_righe(file, schema):
    """Toglie le righe che contengono lo schema (almeno una deve esserci)."""
    righe = file.read_text(encoding="utf-8").splitlines(keepends=True)
    rimaste = [r for r in righe if schema not in r]
    if len(rimaste) == len(righe):
        sys.exit(f"Nessuna riga con {schema!r} in {file}: il plugin è cambiato?")
    file.write_text("".join(rimaste), encoding="utf-8")


def geolocator_android(d):
    java = d / "android/src/main/java/com/baseflow/geolocator/location"
    (java / "FusedLocationClient.java").unlink()
    gm = java / "GeolocationManager.java"
    togli_righe(gm, f"import {GMS}.")
    # Sempre il LocationManager di Android.
    sostituisci(
        gm,
        r"return isGooglePlayServicesAvailable\(context\)\s*"
        r"\?\s*new FusedLocationClient\(context, locationOptions\)\s*"
        r":\s*new LocationManagerClient\(context, locationOptions\);",
        "return new LocationManagerClient(context, locationOptions);",
        regex=True,
    )
    sostituisci(
        gm,
        r"\n  private boolean isGooglePlayServicesAvailable\(Context context\) \{.*?\n  \}\n",
        "\n",
        regex=True,
    )
    togli_righe(d / "android/build.gradle", GMS)


def maplibre_gl(d):
    java = d / "android/src/main/java/org/maplibre/maplibregl"
    (java / "GMSLocationEngine.java").unlink()
    f = java / "LocationEngineFactory.kt"
    togli_righe(f, f"import {GMS}.")
    # Il motore GPS di MapLibre al posto di quello di Google.
    sostituisci(
        f,
        r"val locationEngineImpl = if \(isGooglePlayServicesAvailable\(context\)\) \{\s*"
        r"GMSLocationEngine\(context\)\s*\} else \{\s*"
        r"MapLibreGPSLocationEngine\(context\)\s*\}",
        "val locationEngineImpl = MapLibreGPSLocationEngine(context)",
        regex=True,
    )
    sostituisci(
        f,
        r"\n    private fun isGooglePlayServicesAvailable\(context: Context\): Boolean \{.*?\n    \}\n",
        "\n",
        regex=True,
    )
    togli_righe(d / "android/build.gradle", GMS)


DA_PATCHARE = {"geolocator_android": geolocator_android, "maplibre_gl": maplibre_gl}


def controlla(tutti):
    """Nessun plugin con codice Android deve più nominare Google Play Services."""
    trovati = []
    for nome, percorso in tutti.items():
        if nome in DA_PATCHARE:
            percorso = cartella / nome
        android = percorso / "android"
        if not android.is_dir():
            continue
        for f in android.rglob("*"):
            if f.suffix in {".gradle", ".kts", ".java", ".kt"} and GMS in f.read_text(
                encoding="utf-8", errors="ignore"
            ):
                trovati.append(f"{nome}: {f.relative_to(percorso)}")
    for f in (radice / "android").rglob("*"):
        if f.is_file() and f.suffix in {".gradle", ".kts", ".java", ".kt"} and "build" not in f.parts:
            if GMS in f.read_text(encoding="utf-8", errors="ignore"):
                trovati.append(f"app: {f.relative_to(radice)}")
    if trovati:
        sys.exit("Google Play Services ancora presente in:\n  " + "\n  ".join(trovati))


def prepara():
    tutti = pacchetti()
    if overrides.exists():
        sys.exit("pubspec_overrides.yaml c'è già: lancia prima --ripristina.")
    shutil.rmtree(cartella, ignore_errors=True)
    cartella.mkdir()
    # pub get con le copie riscrive pubspec.lock: si rimette com'era con --ripristina.
    shutil.copyfile(radice / "pubspec.lock", cartella / "pubspec.lock")
    righe = [
        "# Scritto da tool/prepara_foss.py (variante foss): non va nel repository.\n",
        "dependency_overrides:\n",
    ]
    for nome, patch in DA_PATCHARE.items():
        if nome not in tutti:
            sys.exit(f"Il pacchetto {nome} non è tra le dipendenze.")
        copia = cartella / nome
        shutil.copytree(tutti[nome], copia)
        patch(copia)
        righe += [f"  {nome}:\n", f"    path: .foss/{nome}\n"]
    controlla(tutti)
    overrides.write_text("".join(righe), encoding="utf-8")
    pub_get()
    print("Variante foss pronta: ora 'flutter build apk ...'.")


def ripristina():
    overrides.unlink(missing_ok=True)
    lock = cartella / "pubspec.lock"
    if lock.exists():
        shutil.copyfile(lock, radice / "pubspec.lock")
    shutil.rmtree(cartella, ignore_errors=True)
    pub_get()
    print("Tornati alla build normale.")


if __name__ == "__main__":
    if sys.argv[1:] == ["--ripristina"]:
        ripristina()
    elif sys.argv[1:] == []:
        prepara()
    else:
        sys.exit(__doc__)
