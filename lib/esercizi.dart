import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'csv.dart';
import 'models.dart';

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

const attrezzi = [
  Attrezzo(
    'manubri',
    'Manubri',
    Icons.fitness_center_rounded,
    conPeso: true,
    aiutoPeso: 'Il peso di ogni manubrio, es. 4, 8, 12. Se sono regolabili scrivi l\'intervallo, es. 2-20.',
  ),
  Attrezzo(
    'kettlebell',
    'Kettlebell',
    Icons.fitness_center_rounded,
    conPeso: true,
    aiutoPeso: 'Il peso di ogni kettlebell che hai.',
  ),
  Attrezzo(
    'bilanciere',
    'Bilanciere',
    Icons.fitness_center_rounded,
    conPeso: true,
    aiutoPeso: 'Il peso della sola barra (di solito 20 kg).',
  ),
  Attrezzo(
    'dischi',
    'Dischi',
    Icons.album_rounded,
    conPeso: true,
    aiutoPeso: 'Il peso dei dischi che hai. Si usano anche senza bilanciere.',
  ),
  Attrezzo(
    'palla_medica',
    'Palla medica',
    Icons.sports_volleyball_rounded,
    conPeso: true,
    aiutoPeso: 'Il peso della palla.',
  ),
  Attrezzo('elastici', 'Elastici', Icons.gesture_rounded),
  Attrezzo('sbarra', 'Sbarra per trazioni', Icons.horizontal_rule_rounded),
  Attrezzo('parallele', 'Parallele per dip', Icons.drag_handle_rounded),
  Attrezzo('trx', 'Anelli o TRX', Icons.link_rounded),
  Attrezzo('panca', 'Panca', Icons.weekend_rounded),
  Attrezzo('rialzo', 'Step o box', Icons.crop_square_rounded),
  Attrezzo('fitball', 'Fitball', Icons.circle_outlined),
  Attrezzo('rullo', 'Rullo (foam roller)', Icons.view_week_rounded),
  // In palestra: macchine e cavi.
  Attrezzo(
    'lat_machine',
    'Lat machine',
    Icons.vertical_align_bottom_rounded,
    palestra: true,
  ),
  Attrezzo('pulley', 'Pulley basso', Icons.rowing_rounded, palestra: true),
  Attrezzo(
    'cavi',
    'Cavi regolabili (croce ai cavi)',
    Icons.cable_rounded,
    palestra: true,
  ),
  Attrezzo(
    'chest_press',
    'Chest press',
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'pectoral',
    'Pectoral machine',
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'shoulder_press',
    'Shoulder press',
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'rematore_macchina',
    'Rematore alla macchina',
    Icons.rowing_rounded,
    palestra: true,
  ),
  Attrezzo(
    'multipower',
    'Multipower (Smith machine)',
    Icons.fitness_center_rounded,
    palestra: true,
  ),
  Attrezzo(
    'leg_press',
    'Leg press',
    Icons.airline_seat_legroom_extra_rounded,
    palestra: true,
  ),
  Attrezzo(
    'hack_squat',
    'Hack squat',
    Icons.airline_seat_legroom_extra_rounded,
    palestra: true,
  ),
  Attrezzo(
    'leg_extension',
    'Leg extension',
    Icons.airline_seat_legroom_normal_rounded,
    palestra: true,
  ),
  Attrezzo(
    'leg_curl',
    'Leg curl',
    Icons.airline_seat_legroom_normal_rounded,
    palestra: true,
  ),
  Attrezzo(
    'adduttori',
    'Adduttori e abduttori',
    Icons.airline_seat_legroom_reduced_rounded,
    palestra: true,
  ),
  Attrezzo(
    'calf_machine',
    'Calf machine (polpacci)',
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
const nomiMuscoli = {
  'abs': 'Addominali',
  'obliques': 'Obliqui',
  'adductors': 'Adduttori',
  'biceps': 'Bicipiti',
  'calves': 'Polpacci',
  'chest': 'Petto',
  'forearm': 'Avambracci',
  'gluteal': 'Glutei',
  'hamstring': 'Femorali',
  'upper-back': 'Dorsali',
  'lower-back': 'Lombari',
  'neck': 'Collo',
  'quadriceps': 'Quadricipiti',
  'deltoids': 'Spalle',
  'trapezius': 'Trapezio',
  'triceps': 'Tricipiti',
};

const nomiSchemi = {
  'spinta_orizzontale': 'Spinta orizzontale (petto)',
  'spinta_verticale': 'Spinta verticale (spalle)',
  'trazione_orizzontale': 'Trazione orizzontale (rematori)',
  'trazione_verticale': 'Trazione verticale (trazioni)',
  'squat': 'Squat',
  'affondo': 'Affondi e step',
  'cerniera': 'Cerniera d\'anca (stacchi e ponti)',
  'core': 'Core',
  'spalle': 'Spalle e postura',
  'braccia': 'Braccia',
  'polpacci': 'Polpacci',
  'isolamento_gambe': 'Gambe alle macchine',
  'pliometria': 'Pliometria',
  'total_body': 'Total body',
  'mobilita': 'Mobilità e stretching',
  'rullo': 'Rullo (automassaggio)',
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
String quantiEsercizi(int n) => n == 1 ? '1 esercizio' : '$n esercizi';
