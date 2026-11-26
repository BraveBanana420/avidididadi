import 'package:allenamenti_app/allenamento_agente.dart';
import 'package:allenamenti_app/assistente.dart';
import 'package:allenamenti_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sedute con i passi importati (blocco "allenamenti"): restano loro quando
/// la seduta si sposta, e l'app non le rigenera (caso reale: la bici
/// "Sweet spot 2x15" del 24/11 spostata al 26/11 era diventata "Ripetute 3x6").
void main() {
  final oggi = DateTime(2026, 11, 23); // lunedì
  final lun = DateTime(2026, 11, 23);
  DateTime g(int giorno) => lun.add(Duration(days: giorno));

  // L'allenamento preciso dell'assistente, come arriva nel blocco.
  final sweetSpot = allenamentoDa({
    'data': '2026-11-24',
    'sport': 'bici',
    'tipo': 'Intervalli',
    'nome': 'Sweet spot 2x15',
    'passi': [
      {'fase': 'riscaldamento', 'nome': 'Riscaldamento', 'minuti': 15},
      {
        'fase': 'principale',
        'nome': 'Sweet spot',
        'minuti': 15,
        'ripeti': 2,
        'recupero_s': 300,
        'intensita': '88-93% FTP',
        'secondario': '85-95 rpm',
      },
      {'fase': 'defaticamento', 'nome': 'Defaticamento', 'minuti': 10},
    ],
  });

  // Settimana: corsa mar, forza mer, bici sab (generata).
  final base = [
    PianoRiga(
      data: g(1),
      fascia: 'Mattina',
      sport: 'Corsa',
      tipo: 'Lento',
      durataMin: 45,
    ),
    PianoRiga(data: g(2), fascia: 'Sera', sport: 'Forza', durataMin: 45),
    PianoRiga(
      data: g(5),
      fascia: 'Mattina',
      sport: 'Bici',
      tipo: 'Endurance',
      durataMin: 90,
    ),
  ];
  final piano = pianoCon(base, sweetSpot);
  final passi = sweetSpot.passi;
  final id24 = idAllenamentoAgente(g(1), 'Bici');
  final id26 = idAllenamentoAgente(g(3), 'Bici');

  PianoRiga bici(List<PianoRiga> p, DateTime d) =>
      p.singleWhere((r) => r.data == d && r.sport == 'Bici');

  test('importazione in un giorno senza seduta di quello sport', () {
    // Il 24/11 c'era solo la corsa: la bici si aggiunge, segnata importata.
    expect(base.where((r) => r.data == g(1) && r.sport == 'Bici'), isEmpty);
    final b = bici(piano, g(1));
    expect(b.importata, isTrue);
    expect(b.origine, origineImportato);
    expect(b.tipo, 'Intervalli');
    expect(b.durataMin, durataPassi(passi)); // anche i recuperi
    // Le altre sedute restano com'erano, generate.
    expect(piano.where((r) => r.data == g(1)).length, 2);
    expect(piano.where((r) => r.importata).length, 1);
    expect(bici(piano, g(5)).importata, isFalse);
  });

  test('sposta: la seduta tiene i suoi passi, cambia solo la data', () {
    final m = Modifica(
      azione: Azione.sposta,
      data: g(1),
      sport: 'Bici',
      nuovaData: g(3),
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.accettate, [m]);
    expect(esito.avvisi, isEmpty);
    final spostata = bici(esito.piano, g(3));
    expect(spostata.importata, isTrue);
    expect(spostata.tipo, 'Intervalli');
    expect(spostata.durataMin, bici(piano, g(1)).durataMin);
    expect(
      esito.piano.where((r) => r.data == g(1) && r.sport == 'Bici'),
      isEmpty,
    );

    // I passi seguono la seduta: id del 26/11, nessuno resta sul 24/11.
    final dopo = passiDopoModifiche(passi, piano, esito.accettate);
    expect(dopo.where((w) => w.id == id24), isEmpty);
    final al26 = dopo.where((w) => w.id == id26).toList();
    expect(al26.length, passi.length);
    expect(al26.map((w) => w.nome).toSet(), {'Sweet spot 2x15'});
    expect(
      al26.map((w) => w.intensita).toList(),
      passi.map((w) => w.intensita).toList(),
    );
  });

  test('sposta con la fascia: data e fascia cambiano, i passi no', () {
    final m = Modifica(
      azione: Azione.sposta,
      data: g(1),
      sport: 'Bici',
      nuovaData: g(3),
      fascia: 'Sera',
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(bici(esito.piano, g(3)).importata, isTrue);
    final dopo = passiDopoModifiche(passi, piano, esito.accettate);
    expect(dopo.where((w) => w.id == id26).length, passi.length);
  });

  test('cambia senza cambio di tipo: i passi importati restano', () {
    final m = Modifica(
      azione: Azione.cambia,
      data: g(1),
      sport: 'Bici',
      durataMin: 60,
      fascia: 'Sera',
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.accettate, [m]);
    expect(esito.avvisi, isEmpty);
    final b = bici(esito.piano, g(1));
    expect(b.importata, isTrue);
    expect(b.tipo, 'Intervalli');
    expect(b.durataMin, 60);
    expect(b.fascia, 'Sera');
    expect(passiDopoModifiche(passi, piano, esito.accettate), passi);
  });

  test('cambia con lo stesso tipo scritto diversamente: niente avviso', () {
    final m = Modifica(
      azione: Azione.cambia,
      data: g(1),
      sport: 'Bici',
      tipo: 'intervalli',
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.avvisi, isEmpty);
    expect(bici(esito.piano, g(1)).importata, isTrue);
  });

  test('cambia con cambio di tipo: avviso, poi passi dell\'app', () {
    final m = Modifica(
      azione: Azione.cambia,
      data: g(1),
      sport: 'Bici',
      tipo: 'Endurance',
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.accettate, [m]);
    // L'avviso c'è prima di applicare, con il tipo di prima e quello nuovo.
    expect(esito.avvisi.single.$1, m);
    expect(esito.avvisi.single.$2, contains('Intervalli'));
    expect(esito.avvisi.single.$2, contains('Endurance'));
    final b = bici(esito.piano, g(1));
    expect(b.importata, isFalse);
    expect(b.tipo, 'Endurance');
    expect(
      passiDopoModifiche(
        passi,
        piano,
        esito.accettate,
      ).where((w) => w.id == id24),
      isEmpty,
    );
  });

  test('cambia di tipo su una seduta generata: nessun avviso', () {
    final m = Modifica(
      azione: Azione.cambia,
      data: g(5),
      sport: 'Bici',
      tipo: 'Tempo',
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.avvisi, isEmpty);
    expect(bici(esito.piano, g(5)).tipo, 'Tempo');
  });

  test('scambia: ognuna porta con sé i suoi passi', () {
    final m = Modifica(
      azione: Azione.scambia,
      data: g(1),
      sport: 'Bici',
      nuovaData: g(5),
    );
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.accettate, [m]);
    expect(bici(esito.piano, g(5)).importata, isTrue);
    expect(bici(esito.piano, g(1)).importata, isFalse);
    final dopo = passiDopoModifiche(passi, piano, esito.accettate);
    expect(
      dopo.where((w) => w.id == idAllenamentoAgente(g(5), 'Bici')).length,
      passi.length,
    );
    expect(dopo.where((w) => w.id == id24), isEmpty);
  });

  test('rimuovi: i passi importati se ne vanno con la seduta', () {
    final m = Modifica(azione: Azione.rimuovi, data: g(1), sport: 'Bici');
    final esito = valutaProposta(piano, [m], oggi);
    expect(esito.accettate, [m]);
    expect(passiDopoModifiche(passi, piano, esito.accettate), isEmpty);
  });

  test(
    'l\'origine si salva in fondo a piano.csv; le righe vecchie sono generate',
    () {
      final b = bici(piano, g(1));
      final riga = b.toRow();
      expect(pianoHeader.last, 'origine');
      expect(riga.length, pianoHeader.length);
      expect(PianoRiga.fromRow(riga).importata, isTrue);
      // Una riga scritta prima della colonna nuova (8 colonne).
      final vecchia = riga.sublist(0, 8);
      expect(PianoRiga.fromRow(vecchia).importata, isFalse);
      expect(PianoRiga.fromRow(vecchia).tipo, 'Intervalli');
    },
  );

  test(
    'migrazione: le sedute future con passi importati diventano importate',
    () {
      // Come era salvato prima: stessa seduta, senza origine.
      final senza = [for (final r in piano) r.copia(origine: '')];
      final passata = senza.first.copia(
        data: g(0).subtract(const Duration(days: 7)),
      );
      final idPassata = idAllenamentoAgente(passata.data, passata.sport);
      final migrato = conOrigineImportata(
        [passata, ...senza],
        [...passi, ...passi.map((w) => w.conId(idPassata))],
        oggi,
      );
      expect(bici(migrato, g(1)).importata, isTrue);
      expect(bici(migrato, g(5)).importata, isFalse);
      // Quelle già passate restano come sono.
      expect(migrato.first.importata, isFalse);
    },
  );
}
