"""Genera le icone Android dell'app da tool/icona/originale.jpg.

Uso (serve Pillow):  python tool/genera_icona.py
L'originale è una foto di una piastra nera con un cancelletto bianco in rilievo.
"""
from PIL import Image, ImageDraw, ImageFilter

ORIGINALE = 'tool/icona/originale.jpg'
RES = 'android/app/src/main/res'

# Posizione di piastra e cancelletto nella foto (misurate sui pixel scuri/chiari).
PIASTRA = (320, 81, 703, 484)
RAGGIO_PIASTRA = 70
CANCELLETTO = (415, 175, 608, 383)

LEGACY = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
ADATTIVA = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}


def colore_piastra(img):
    """Colore medio della piastra in una zona senza cancelletto."""
    zona = img.crop((PIASTRA[0] + 40, PIASTRA[1] + 120, PIASTRA[0] + 80, PIASTRA[1] + 280))
    r, g, b = [sum(c) // len(c) for c in zip(*zona.get_flattened_data())]
    return (r, g, b)


def maschera_arrotondata(size, box, raggio, scala=4):
    """Rettangolo arrotondato antialiasato (disegnato in grande e poi ridotto)."""
    m = Image.new('L', (size[0] * scala, size[1] * scala), 0)
    ImageDraw.Draw(m).rounded_rectangle([c * scala for c in box], raggio * scala, fill=255)
    return m.resize(size, Image.LANCZOS)


def legacy(img):
    """Piastra intera con lo sfondo della foto reso trasparente."""
    x0, y0, x1, y1 = PIASTRA
    lato = max(x1 - x0, y1 - y0)
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    box = (cx - lato // 2, cy - lato // 2, cx + lato // 2, cy + lato // 2)
    ritaglio = img.crop(box).convert('RGBA')
    # Maschera appena più piccola della piastra: toglie il bordo chiaro della foto.
    r = 6
    m = maschera_arrotondata(ritaglio.size,
                             (x0 - box[0] + r, y0 - box[1] + r, x1 - box[0] - r, y1 - box[1] - r),
                             RAGGIO_PIASTRA - r)
    ritaglio.putalpha(m)
    # Un piccolo margine trasparente, come le icone di sistema.
    tela = Image.new('RGBA', (int(lato * 1.06),) * 2, (0, 0, 0, 0))
    tela.paste(ritaglio, ((tela.width - lato) // 2,) * 2, ritaglio)
    return tela


def primo_piano(img, colore, lato=432, quota=0.44):
    """Primo piano dell'icona adattiva: il cancelletto occupa circa il 44% del lato,
    così resta dentro la zona sicura anche con le maschere rotonde."""
    hx0, hy0, hx1, hy1 = CANCELLETTO
    cx, cy = (hx0 + hx1) / 2, (hy0 + hy1) / 2
    # Un quadrato interno alla piastra, lontano dagli angoli arrotondati.
    mezzo = 150
    pezzo = img.crop((int(cx - mezzo), int(cy - mezzo), int(cx + mezzo), int(cy + mezzo)))
    scala = lato * quota / max(hx1 - hx0, hy1 - hy0)
    pezzo = pezzo.resize((round(pezzo.width * scala),) * 2, Image.LANCZOS)
    # Bordi sfumati per fondere il ritaglio con il colore pieno della piastra.
    sfumatura = Image.new('L', pezzo.size, 0)
    margine = pezzo.width // 10
    ImageDraw.Draw(sfumatura).rectangle(
        (margine, margine, pezzo.width - margine, pezzo.height - margine), fill=255)
    sfumatura = sfumatura.filter(ImageFilter.GaussianBlur(margine / 2))
    tela = Image.new('RGB', (lato, lato), colore)
    pos = ((lato - pezzo.width) // 2,) * 2
    tela.paste(pezzo, pos, sfumatura)
    return tela


def main():
    img = Image.open(ORIGINALE).convert('RGB')
    colore = colore_piastra(img)
    icona = legacy(img)
    davanti = primo_piano(img, colore)
    for densita, px in LEGACY.items():
        icona.resize((px, px), Image.LANCZOS).save(f'{RES}/mipmap-{densita}/ic_launcher.png')
    for densita, px in ADATTIVA.items():
        davanti.resize((px, px), Image.LANCZOS).save(
            f'{RES}/mipmap-{densita}/ic_launcher_foreground.png')
    # Anteprime ad alta risoluzione, per controllo.
    icona.resize((512, 512), Image.LANCZOS).save('tool/icona/icona.png')
    davanti.save('tool/icona/primo_piano.png')
    print('colore piastra #%02X%02X%02X' % colore)


main()
