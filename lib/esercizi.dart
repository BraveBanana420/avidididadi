import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'csv.dart';
import 'models.dart';
import 'l10n/lingua.dart';

/// Un attrezzo che si può avere a disposizione.
class Attrezzo {
  final String chiave;
  final String nome;
  final IconData icona;
  final bool conPeso; // se selezionato, chiede i pesi disponibili
  final String aiutoPeso;
  final bool palestra; // macchine e cavi: i pesi li legge sulla macchina
  const Attrezzo(
    this.chiave,
    this.nome,
    this.icona, {
    this.conPeso = false,
    this.aiutoPeso = '',
    this.palestra = false,
  });
}

List<Attrezzo> get attrezzi => [
  Attrezzo(
    'manubri',
    l10n.manubri,
    Icons.fitness_center_rounded,
    conPeso: true,
    aiutoPeso: l10n.pesoOgniManubrioEs,
  ),
  Attrezzo(
    'kettlebell',
    l10n.kettlebell,
    Icons.fitness_center_rounded,
    conPeso: true,
    aiutoPeso: l10n.pesoOgniKettlebellHai,
  ),
  Attrezzo(
    'bilanciere',
    l10n.bilanciere,
    Icons.fitness_center_rounded,
    conPeso: true,
    aiutoPeso: l10n.pesoSolaBarraSolito,
  ),
  Attrezzo(
    'dischi',
    l10n.dischi,
    Icons.album_rounded,
    conPeso: true,
    aiutoPeso: l10n.pesoDeiDischiHai,
  ),
  Attrezzo(
    'palla_medica',
    l10n.pallaMedica,
    Icons.sports_volleyball_rounded,
    conPeso: true,
    aiutoPeso: l10n.pesoPalla,
  ),
  Attrezzo('elastici', l10n.elastici, Icons.gesture_rounded),
  Attrezzo('sbarra', l10n.sbarraTrazioni, Icons.horizontal_rule_rounded),
  Attrezzo('parallele', l10n.paralleleDip, Icons.drag_handle_rounded),
  Attrezzo('trx', l10n.anelliOTrx, Icons.link_rounded),
  Attrezzo('panca', l10n.panca, Icons.weekend_rounded),
  Attrezzo('rialzo', l10n.stepOBox, Icons.crop_square_rounded),
  Attrezzo('fitball', l10n.fitball, Icons.circle_outlined),
  Attrezzo('rullo', l10n.rulloFoamRoller, Icons.view_week_rounded),
  // In palestra: macchine e cavi.
  Attrezzo(
    'lat_machine',
    l10n.latMachine,
    Icons.vertical_align_bottom_rounded,
    palestra: true,
  ),
  Attrezzo('pulley', l10n.pulleyBasso, Icons.rowing_rounded, palestra: true),
  Attrezzo(
    'cavi',
    l10n.caviRegolabiliCroceAi,
    Icons.cable_rounded,
    palestra: true,
  ),
  Attrezzo(
    'chest_press',
    l10n.chestPress,
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'pectoral',
    l10n.pectoralMachine,
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'shoulder_press',
    l10n.shoulderPress,
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'rematore_macchina',
    l10n.rematoreAllaMacchina,
    Icons.rowing_rounded,
    palestra: true,
  ),
  Attrezzo(
    'multipower',
    l10n.multipowerSmithMachine,
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'leg_press',
    l10n.legPress,
    Icons.airline_seat_legroom_extra_rounded,
    palestra: true,
  ),
  Attrezzo(
    'hack_squat',
    l10n.hackSquat,
    Icons.airline_seat_legroom_extra_rounded,
    palestra: true,
  ),
  Attrezzo(
    'leg_extension',
    l10n.legExtension,
    Icons.airline_seat_legroom_normal_rounded,
    palestra: true,
  ),
  Attrezzo(
    'leg_curl',
    l10n.legCurl,
    Icons.airline_seat_legroom_normal_rounded,
    palestra: true,
  ),
  Attrezzo(
    'adduttori',
    l10n.adduttoriAbduttori,
    Icons.airline_seat_legroom_reduced_rounded,
    palestra: true,
  ),
  Attrezzo(
    'calf_machine',
    l10n.calfMachinePolpacci,
    Icons.directions_walk_rounded,
    palestra: true,
  ),
];

Attrezzo? attrezzoDa(String chiave) {
  for (final a in attrezzi) {
    if (a.chiave == chiave) return a;
  }
  return null;
}

const attrezzaturaHeader = ['attrezzo', 'pesi_kg'];

/// Attrezzatura posseduta: chiave -> pesi disponibili in kg (vuoto se senza peso).
typedef Attrezzatura = Map<String, List<double>>;

Attrezzatura attrezzaturaDa(Tabella? t) => {
  if (t != null)
    for (final r in t.righe)
      if (t.v(r, 'attrezzo').isNotEmpty)
        t.v(r, 'attrezzo'): [
          for (final p in t.v(r, 'pesi_kg').split(';'))
            if (numero(p) > 0) numero(p),
        ],
};

List<List<String>> attrezzaturaRighe(Attrezzatura a) => [
  for (final e in a.entries) [e.key, e.value.map(fmtNum).join(';')],
];

/// Pesi scritti come "8, 12, 16"; un intervallo "2-20" (manubri regolabili)
/// diventa tutti i pesi a passi di 2 kg.
List<double> leggiPesi(String testo) {
  final pesi = <double>{};
  final intervallo = RegExp(r'^(\d+(?:[.,]\d+)?)-(\d+(?:[.,]\d+)?)$');
  // Separano i pesi spazi, punto e virgola e ", ". Una sola virgola tra cifre
  // è il decimale (2,5); più virgole senza spazi sono una lista (8,12,16).
  final parole = testo.replaceAll(', ', ' ').split(RegExp(r'[;\s]+'));
  for (final t in [
    for (final p in parole)
      ...(','.allMatches(p).length > 1 ? p.split(',') : [p]),
  ]) {
    final m = intervallo.firstMatch(t);
    if (m != null) {
      final a = math.min(numero(m[1]!), numero(m[2]!));
      final b = math.max(numero(m[1]!), numero(m[2]!));
      for (var p = a; p < b; p += 2) {
        if (p > 0) pesi.add(p);
      }
      pesi.add(b);
    } else if (numero(t) > 0) {
      pesi.add(numero(t));
    }
  }
  return pesi.toList()..sort();
}

String scriviPesi(List<double> pesi) =>
    pesi.isEmpty ? '' : '${pesi.map(fmtNum).join(', ')} kg';

/// Muscoli della mappa (lib/muscoli_dati.dart) in italiano.
Map<String, String> get nomiMuscoli => {
  'abs': l10n.addominali,
  'obliques': l10n.obliqui,
  'adductors': l10n.adduttori,
  'biceps': l10n.bicipiti,
  'calves': l10n.polpacci,
  'chest': l10n.petto,
  'forearm': l10n.avambracci,
  'gluteal': l10n.glutei,
  'hamstring': l10n.femorali,
  'upper-back': l10n.dorsali,
  'lower-back': l10n.lombari,
  'neck': l10n.collo,
  'quadriceps': l10n.quadricipiti,
  'deltoids': l10n.spalle,
  'trapezius': l10n.trapezio,
  'triceps': l10n.tricipiti,
};

Map<String, String> get nomiSchemi => {
  'spinta_orizzontale': l10n.spintaOrizzontalePetto,
  'spinta_verticale': l10n.spintaVerticaleSpalle,
  'trazione_orizzontale': l10n.trazioneOrizzontaleRematori,
  'trazione_verticale': l10n.trazioneVerticaleTrazioni,
  'squat': l10n.squat,
  'affondo': l10n.affondiStep,
  'cerniera': l10n.cernieraAncaStacchiPonti,
  'core': l10n.core,
  'spalle': l10n.spallePostura,
  'braccia': l10n.braccia,
  'polpacci': l10n.polpacci,
  'isolamento_gambe': l10n.gambeAlleMacchine,
  'pliometria': l10n.pliometria,
  'total_body': l10n.totalBody,
  'mobilita': 'Mobilità e stretching',
  'rullo': l10n.rulloAutomassaggio,
};

/// Un esercizio del catalogo (selezione in italiano di free-exercise-db).
class Esercizio {
  final String id;
  final String nome;
  final String nomeEn;
  final String tipo; // forza | mobilita
  final String schema;
  final String livello;
  final List<List<String>>
  attrezzi; // basta uno dei gruppi; vuoto = corpo libero
  final List<String> muscoli;
  final List<String> muscoliSecondari;
  final List<String> istruzioni;
  final List<String> immagini;

  Esercizio.da(Map<String, dynamic> j)
    : id = j['id'],
      nome = j['nome'],
      nomeEn = j['nome_en'],
      tipo = j['tipo'],
      schema = j['schema'],
      livello = j['livello'],
      attrezzi = [
        for (final g in j['attrezzi'] as List)
          [for (final a in g as List) a as String],
      ],
      muscoli = List<String>.from(j['muscoli']),
      muscoliSecondari = List<String>.from(j['muscoli_secondari']),
      istruzioni = List<String>.from(j['istruzioni']),
      immagini = List<String>.from(j['immagini']);

  bool get corpoLibero => attrezzi.isEmpty;

  /// Fattibile con l'attrezzatura indicata.
  bool fattibile(Attrezzatura a) =>
      attrezzi.isEmpty || attrezzi.any((g) => g.every(a.containsKey));

  /// "Corpo libero", oppure le alternative: "Kettlebell o Manubri".
  String get descrizioneAttrezzi => attrezzi.isEmpty
      ? 'Corpo libero'
      : attrezzi
            .map((g) => g.map((k) => attrezzoDa(k)?.nome ?? k).join(' + '))
            .join(' o ');
}

Future<List<Esercizio>> caricaEsercizi() async {
  final testo = await rootBundle.loadString('assets/esercizi.json');
  return [
    for (final j in jsonDecode(testo) as List)
      Esercizio.da(j as Map<String, dynamic>),
  ];
}

/// Il conteggio scritto bene: "1 esercizio", "6 esercizi".
String quantiEsercizi(int n) => n == 1 ? l10n.n1Esercizio : '$n esercizi';
