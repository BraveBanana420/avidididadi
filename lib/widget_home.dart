import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'models.dart';
import 'storage.dart';
import 'tema.dart';
import 'widgets.dart';

// Widget per la schermata home di Android: l'app prepara i dati di due
// settimane (da lunedì) e le icone degli sport; il widget nativo sceglie da
// solo il giorno di oggi, così resta giusto anche se l'app non viene aperta.

const _canale = MethodChannel('avidididadi/avvio');

/// Azione con cui il pulsante ▶ del widget apre l'app.
const azioneAvviaWidget = 'it.avidididadi.app.AVVIA';

int _argb(Color c) => c.toARGB32();

/// Dati per il widget, in un formato semplice da leggere in Kotlin.
Map<String, dynamic> datiWidget({
  required List<PianoRiga> piano,
  required List<Sessione> sessioni,
  required DateTime oggi,
  required bool scuro,
  bool neon = false, // accento neon al posto del rosso
  required String cartellaIcone,
  required bool Function(PianoRiga) haPassi,
}) {
  final lunedi = DateTime(oggi.year, oggi.month, oggi.day - (oggi.weekday - 1));
  final giorni = <String, dynamic>{};
  for (var i = 0; i < 14; i++) {
    final d = DateTime(lunedi.year, lunedi.month, lunedi.day + i);
    final fatti = sessioni.where((s) => s.data == d).toList();
    final previsti = piano
        .where(
          (r) =>
              r.data == d &&
              !stessoSport(r.sport, 'Riposo') &&
              !fatti.any((s) => stessoSport(s.sport, r.sport)),
        )
        .toList();
    final String stato;
    final String sport;
    final String titolo;
    final String sottotitolo;
    var passi = false;
    if (previsti.isNotEmpty) {
      final r = previsti.first;
      stato = 'previsto';
      sport = normSport(r.sport);
      titolo = r.tipo.isEmpty ? sport : r.tipo;
      sottotitolo = [
        if (r.tipo.isNotEmpty) sport,
        if (r.durataMin > 0) '${r.durataMin} min',
        r.fascia.toLowerCase(),
      ].join(' · ');
      passi = haPassi(r);
    } else if (fatti.isNotEmpty) {
      final s = fatti.first;
      stato = 'fatto';
      sport = normSport(s.sport);
      titolo = 'Fatto: ${s.tipo.isEmpty ? sport : s.tipo}';
      sottotitolo = [
        if (s.tipo.isNotEmpty) sport,
        if (s.durataMin > 0) '${s.durataMin} min',
      ].join(' · ');
    } else {
      stato = 'riposo';
      sport = 'Riposo';
      titolo = 'Giorno di riposo';
      sottotitolo = 'Anche il riposo è allenamento';
    }
    giorni[isoData(d)] = {
      'stato': stato,
      'titolo': titolo,
      'sottotitolo': sottotitolo,
      'colore': _argb(coloreSport(sport)),
      'icona': '$cartellaIcone/${_nomeIcona(sport)}.png',
      'passi': passi,
      // Il cerchio della settimana: pieno se fatto, bordo se in programma.
      'cerchio': fatti.isNotEmpty
          ? 'fatto'
          : previsti.isNotEmpty
          ? 'previsto'
          : 'vuoto',
      'coloreCerchio': fatti.isNotEmpty
          ? _argb(coloreSport(fatti.first.sport))
          : 0,
      'altre': previsti.length > 1 ? previsti.length - 1 : 0,
    };
  }
  return {
    'scuro': scuro,
    'neon': neon,
    'giorni': giorni,
    // Fondo dal tema chiaro o scuro, accento dal rosso o dal neon.
    'colori': {
      'testo': scuro ? 0xFFF4F4F5 : 0xFF14141A,
      'testo2': scuro ? 0xFFA1A1AA : 0xFF55555F,
      'accento': neon
          ? 0xFFFF2E93
          : scuro
          ? 0xFFFF3B47
          : 0xFFC8102E,
      'suHero': neon ? 0xFF14141A : 0xFF160304,
      'traccia': scuro ? 0xFF3F3F46 : 0xFFB9B9C4,
    },
  };
}

String _nomeIcona(String sport) => switch (sport.toLowerCase()) {
  'forza' => 'forza',
  'corsa' => 'corsa',
  'nuoto' => 'nuoto',
  'bici' => 'bici',
  'mobilità' => 'mobilita',
  'arrampicata' => 'arrampicata',
  _ => 'riposo',
};

const _sportIcone = [
  'Forza',
  'Corsa',
  'Nuoto',
  'Bici',
  'Mobilità',
  'Arrampicata',
  'Riposo',
];

/// Icone degli sport in PNG bianchi, da colorare nel widget.
Future<String> _preparaIcone() async {
  final dir = Directory('${await Storage.cartella()}/widget_icone');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  for (final s in _sportIcone) {
    final f = File('${dir.path}/${_nomeIcona(s)}.png');
    if (f.existsSync()) continue;
    final icona = iconaSport(s);
    const lato = 96.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icona.codePoint),
        style: TextStyle(
          fontFamily: icona.fontFamily,
          package: icona.fontPackage,
          fontSize: lato,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset.zero);
    final img = await rec.endRecording().toImage(lato.toInt(), lato.toInt());
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    if (png != null) await f.writeAsBytes(png.buffer.asUint8List());
  }
  return dir.path;
}

/// Manda al widget i dati aggiornati (solo su Android; altrove non fa nulla).
Future<void> aggiornaWidgetHome(AppState state) async {
  if (!Platform.isAndroid) return;
  try {
    final dati = datiWidget(
      piano: state.piano,
      sessioni: state.sessioni,
      oggi: soloData(DateTime.now()),
      scuro: temaScuroAttivo,
      neon: neonAttivo,
      cartellaIcone: await _preparaIcone(),
      haPassi: (r) => state.passiSeduta(r.data, r.sport, r.tipo).isNotEmpty,
    );
    await _canale.invokeMethod('aggiornaWidget', jsonEncode(dati));
  } catch (e) {
    debugPrint('Widget: non aggiornato ($e)');
  }
}
