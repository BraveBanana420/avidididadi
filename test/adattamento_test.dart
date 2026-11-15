import 'package:allenamenti_app/adattamento.dart';
import 'package:allenamenti_app/csv.dart';
import 'package:allenamenti_app/feedback.dart';
import 'package:allenamenti_app/generatore_endurance.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lunedi = DateTime(2026, 10, 26);
  DateTime giorno(int settimana, int g) =>
      lunedi.add(Duration(days: 7 * settimana + g));

  /// Nuoto il martedì per 6 settimane.
  final piano = [
    for (var w = 0; w < 6; w++)
      PianoRiga(
        data: giorno(w, 1),
        fascia: 'Mattina',
        sport: 'Nuoto',
        tipo: 'Tecnica',
        durataMin: 50,
      ),
  ];

  /// Quattro nuotate da 1400 m nelle settimane prima: la base è 1400 m.
  final storico = [
    for (var w = 1; w <= 4; w++)
      Sessione(
        id: 'hc-$w',
        data: lunedi.subtract(Duration(days: 7 * w - 1)),
        sport: 'Nuoto',
        durataMin: 50,
        distanzaKm: 1.4,
      ),
  ];

  PianoEndurance genera({
    Map<String, List<(DateTime, EsitoSeduta)>> esiti = const {},
    int? passo = 118,
    DateTime? da,
  }) => generaPianoEndurance(
    piano: piano,
    storico: storico,
    sport: {'Nuoto'},
    inizio: lunedi,
    da: da ?? lunedi,
    passoCritico: passo,
    esiti: esiti,
  );

  List<WorkoutStep> seduta(PianoEndurance p, DateTime d) =>
      p.passi.where((w) => w.id == 'nuoto_${isoData(d)}').toList();

  WorkoutStep principale(List<WorkoutStep> s) =>
      s.firstWhere((w) => w.fase == 'principale');

  group('feedback pesante → riduzione', () {
    test('il tuo caso: fatica 7 su tecnica e passo non tenuto', () {
      final martedi = giorno(0, 1);
      final f = FeedbackSessione(
        data: martedi,
        sport: 'Nuoto',
        fatica: 7,
        esitoPasso: 'molto_lento',
      );
      final scarto = scartoPasso(f, 118);
      final esito = valutaSeduta(
        f: f,
        atteso: faticaPrevista('Tecnica'),
        scarto: scarto,
      );
      expect(esito, EsitoSeduta.pesante);

      final senza = genera(da: giorno(1, 0));
      final con = genera(
        esiti: {
          'Nuoto': [(martedi, esito)],
        },
        da: giorno(1, 0),
      );
      final prossima = giorno(1, 1);
      final prima = seduta(senza, prossima), dopo = seduta(con, prossima);
      expect(metriDi(dopo), lessThan(metriDi(prima)));
      // Mai più della seduta appena andata male (1400 m).
      expect(metriDi(dopo), lessThanOrEqualTo(1400));
      expect(
        int.parse(principale(dopo).serie),
        lessThan(int.parse(principale(prima).serie)),
      );
      final cambi = cambiSeduta(prima, dopo);
      expect(cambi.first, startsWith('principale '));
      expect(cambi.join(), contains('invece di'));
    });

    test('due sedute pesanti di fila: settimana di scarico', () {
      final a = adatta([
        (giorno(0, 1), EsitoSeduta.pesante),
        (giorno(1, 1), EsitoSeduta.pesante),
      ]);
      expect(a.scaricoFino, giorno(2, 1));
      expect(a.volume, closeTo(0.875 * 0.875, 1e-9));
      expect(a.intensita, 0);
    });
  });

  group('feedback nella norma → progressione', () {
    test('una sola variabile alla volta, alternate', () {
      final d = giorno(0, 1);
      final una = adatta([(d, EsitoSeduta.ok)]);
      expect(una.volume, closeTo(1.05, 1e-9));
      expect(una.intensita, 0);
      final due = adatta([
        (d, EsitoSeduta.ok),
        (d.add(const Duration(days: 7)), EsitoSeduta.ok),
      ]);
      expect(due.volume, closeTo(1.05, 1e-9));
      expect(due.intensita, 1);
    });

    test('con la progressione per durata cresce solo il volume', () {
      final d = giorno(0, 1);
      final a = adatta([
        (d, EsitoSeduta.ok),
        (d.add(const Duration(days: 7)), EsitoSeduta.ok),
      ], modo: 'durata');
      expect(a.volume, closeTo(1.05 * 1.05, 1e-9));
      expect(a.intensita, 0);
    });

    test('facile: piccola progressione', () {
      expect(adatta([(giorno(0, 1), EsitoSeduta.facile)]).volume, 1.075);
    });

    test('la progressione parte dall\'adattamento: niente +10% da solo', () {
      final con = genera(
        esiti: {
          'Nuoto': [(giorno(0, 1), EsitoSeduta.ok)],
        },
        da: giorno(1, 0),
      );
      // Base 1400 × 1,05 = 1470 → 1450/1500 m, non 1550 della sola progressione.
      expect(metriDi(seduta(con, giorno(1, 1))), lessThanOrEqualTo(1500));
    });

    test('il volume della settimana cresce al massimo del 10%', () {
      final p = genera(
        esiti: {
          'Nuoto': [
            for (var i = 0; i < 6; i++) (giorno(0, 1), EsitoSeduta.facile),
          ],
        },
        da: giorno(1, 0),
      );
      // Settimana prima: 1400 m fatti → al massimo 1540 m.
      expect(metriDi(seduta(p, giorno(1, 1))), lessThanOrEqualTo(1540));
    });
  });

  group('attività diversa dal piano', () {
    final previsto = PianoRiga(
      data: giorno(0, 1),
      fascia: 'Mattina',
      sport: 'Nuoto',
      tipo: 'Soglia',
      durataMin: 50,
    );
    final garmin = Sessione(
      id: 'hc-abc',
      data: giorno(0, 1),
      sport: 'Nuoto',
      tipo: 'Piscina',
      durataMin: 90,
      distanzaKm: 3,
    );

    test('distanza e durata molto diverse: seduta sostituita', () {
      expect(
        statoSeduta(previsto: previsto, fatte: [garmin], metriPrevisti: 1400),
        StatoSeduta.sostituita,
      );
      expect(
        statoSeduta(previsto: previsto, fatte: const [], metriPrevisti: 1400),
        StatoSeduta.nonSvolta,
      );
    });

    test('lungo più lungo del previsto: è sempre il lungo', () {
      // Caso reale: lungo da 70 minuti, corso con Garmin in 101 minuti.
      final lungo = PianoRiga(
        data: giorno(0, 6),
        fascia: 'Mattina',
        sport: 'Corsa',
        tipo: 'Lungo',
        durataMin: 70,
      );
      Sessione corsa(int min) => Sessione(
        id: 'hc-lungo',
        data: giorno(0, 6),
        sport: 'Corsa',
        tipo: 'Milano Corsa',
        durataMin: min,
        distanzaKm: 15.02,
      );
      expect(
        statoSeduta(previsto: lungo, fatte: [corsa(101)], lungo: true),
        StatoSeduta.svolta,
      );
      // Molto più corto resta un'altra seduta.
      expect(
        statoSeduta(previsto: lungo, fatte: [corsa(35)], lungo: true),
        StatoSeduta.sostituita,
      );
      // Senza sapere che è un lungo vale la regola di prima.
      expect(
        statoSeduta(previsto: lungo, fatte: [corsa(101)]),
        StatoSeduta.sostituita,
      );
      expect(tipoLungo('Lungo · 70 min'), true);
      expect(tipoLungo('Allunghi'), false);
    });

    test('la fatica attesa è quella dell\'attività vera, non della soglia', () {
      expect(faticaPrevista(previsto.tipo), 7);
      expect(
        faticaAttesa(
          attivita: garmin,
          previsto: previsto,
          stato: StatoSeduta.sostituita,
        ),
        4,
      );
      // Una corsa con il tipo nel titolo (es. "Fartlek") vale per sé.
      expect(
        faticaAttesa(
          attivita: garmin.copyWith(tipo: 'Fartlek'),
          stato: StatoSeduta.sostituita,
        ),
        7,
      );
    });

    test('il feedback ricorda l\'attività svolta (e le righe vecchie restano valide)', () {
      final f = FeedbackSessione(
        data: giorno(0, 1),
        sport: 'Nuoto',
        fatica: 6,
        idSessione: 'hc-abc',
        passoS: 165,
      );
      final t = Tabella.da(toCsv([feedbackHeader, f.toRow()]))!;
      final letto = FeedbackSessione.da(t, t.righe.single)!;
      expect(letto.idSessione, 'hc-abc');
      expect(letto.passoS, 165);
      final vecchio = Tabella.da(
        toCsv([
          feedbackHeader.sublist(0, 6),
          ['2026-10-20', '7', 'si', 'no', '', 'Nuoto'],
        ]),
      )!;
      final v = FeedbackSessione.da(vecchio, vecchio.righe.single)!;
      expect(v.idSessione, '');
      expect(v.passoS, 0);
    });
  });

  group('passo target realistico', () {
    test('mai più veloce del 3% rispetto al riferimento', () {
      for (final k in [-3, 0, 1, 2]) {
        expect(targetNuoto(165, soglia: true, k: k), greaterThanOrEqualTo(160));
        expect(
          targetNuoto(165, soglia: false, k: k),
          greaterThanOrEqualTo(160),
        );
      }
      expect(targetNuoto(165, soglia: false), 165);
    });

    test('dopo una nuotata a 2:45 il target non resta 1:58', () {
      final s = Sessione(
        id: 'hc-1',
        data: giorno(0, 1),
        sport: 'Nuoto',
        durataMin: 50,
        distanzaKm: 1.4,
      );
      final f = FeedbackSessione(
        data: giorno(0, 1),
        sport: 'Nuoto',
        fatica: 7,
        passoS: 165,
      );
      final scritto = passoEseguito(s: s, f: f, target: 118);
      expect(scritto, 165);
      final risposta = passoEseguito(
        s: s,
        f: FeedbackSessione(
          data: giorno(0, 1),
          sport: 'Nuoto',
          fatica: 7,
          esitoPasso: 'molto_lento',
        ),
        target: 118,
      );
      expect(risposta, 136);
      final rif = passoRiferimento([165, 160, 150])!;
      expect(rif, 160);
      final p = genera(passo: rif, da: giorno(1, 0));
      final intensita = principale(seduta(p, giorno(1, 1))).intensita;
      expect(intensita, isNot(contains('1:58')));
      expect(intensita, anyOf(contains('2:40'), contains('2:35')));
    });

    test('valori assurdi ignorati, stima dal tempo in acqua', () {
      final s = Sessione(
        id: 'hc-1',
        data: giorno(0, 1),
        sport: 'Nuoto',
        durataMin: 50,
        distanzaKm: 1.4,
      );
      final strano = FeedbackSessione(
        data: giorno(0, 1),
        sport: 'Nuoto',
        fatica: 5,
        passoS: 20,
      );
      // 50 min, tolti 6 min di recuperi previsti: 2640 s / 14 = 189 s.
      expect(passoEseguito(s: s, f: strano, recuperoS: 360), 189);
      expect(
        passoTargetDi([
          const WorkoutStep(
            id: 'x',
            sport: 'Nuoto',
            nome: '',
            durataTot: 0,
            ordine: 3,
            fase: 'principale',
            descrizione: '',
            serie: '4',
            ripetizioni: '',
            distanzaM: '200',
            durataMin: '',
            intensita: 'passo 1:58/100 m',
            recuperoS: '20',
            note: '',
          ),
        ]),
        118,
      );
    });
  });

  test('Test FTP scritto a mano: fatica attesa al massimo', () {
    expect(faticaPrevista('Test FTP'), 9);
    final r = RitoccoSessione('hc-1', nome: 'Test FTP', alChiuso: true);
    final t = Tabella.da(toCsv([ritocchiHeader, r.toRow()]))!;
    final letto = RitoccoSessione.da(t, t.righe.single)!;
    expect(letto.nome, 'Test FTP');
    expect(letto.alChiuso, isTrue);
    expect(
      faticaAttesa(
        attivita: Sessione(
          id: 'hc-1',
          data: DateTime(2026, 10, 27),
          sport: 'Bici',
          tipo: 'Test FTP',
        ),
      ),
      9,
    );
  });
}
