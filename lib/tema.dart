import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Tema scelto dall'utente (scuro di default), salvato in tema.txt.
final tema = ValueNotifier<ThemeMode>(ThemeMode.dark);

/// Il tema in uso adesso: lo aggiorna l'app a ogni cambio, così i colori degli
/// sport seguono il tema anche dove non c'è un BuildContext (grafici, liste).
bool temaScuroAttivo = true;

/// Versione "neon" (rosa, verde acqua, azzurro) al posto del rosso standard,
/// sia nel tema chiaro sia nello scuro. Salvata in neon.txt.
final neon = ValueNotifier<bool>(false);

/// Come [temaScuroAttivo], per i colori degli sport.
bool neonAttivo = false;

Future<File> _file([String nome = 'tema.txt']) async {
  final d = await getApplicationDocumentsDirectory();
  return File('${d.path}/$nome');
}

Future<void> caricaTema() async {
  try {
    final f = await _file();
    if (await f.exists() && (await f.readAsString()).trim() == 'chiaro') {
      tema.value = ThemeMode.light;
    }
    final n = await _file('neon.txt');
    if (await n.exists() && (await n.readAsString()).trim() == 'si') {
      neon.value = true;
    }
  } catch (_) {
    // file illeggibile: resta il tema scuro, rosso
  }
}

Future<void> cambiaNeon() async {
  neon.value = !neon.value;
  try {
    await (await _file('neon.txt')).writeAsString(neon.value ? 'si' : 'no');
  } catch (_) {
    // non salvato: vale solo per questa sessione
  }
}

Future<void> cambiaTema() async {
  tema.value = tema.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  try {
    await (await _file()).writeAsString(
      tema.value == ThemeMode.light ? 'chiaro' : 'scuro',
    );
  } catch (_) {
    // non salvato: vale solo per questa sessione
  }
}

// Stile "Pulse": fondo grafite (scuro) o bianco (chiaro); accento rosso
// (standard) oppure neon rosa, verde acqua e azzurro. Sfumature e ombre solo
// sugli elementi importanti (seduta di oggi, pulsanti principali, anelli);
// testi e liste restano su fondi piatti.

const famigliaTitoli = 'SpaceGrotesk';
const famigliaTesto = 'Manrope';

/// Rosso del tema scuro e neon del tema chiaro.
const rossoPulse = Color(0xFFFF3B47);
const rosaNeon = Color(0xFFFF2E93);
const acquaNeon = Color(0xFF00D2C3);
const azzurroNeon = Color(0xFF2EA8FF);
const violaNeon = Color(0xFFB566FF);

/// Sfumature, ombre e luci dello stile, per tema.
@immutable
class Pulse extends ThemeExtension<Pulse> {
  final Gradient hero; // la seduta di oggi
  final Gradient primario; // pulsanti principali, sezione attiva
  final Gradient superficie; // riquadri in rilievo
  final Gradient barra; // barra di navigazione fluttuante
  final List<Color> anello; // anelli del tempo e della settimana
  final List<Gradient> sfondo; // bagliori del fondo, uno sopra l'altro
  final List<BoxShadow> ombraHero;
  final List<BoxShadow> ombraPrimario;
  final List<BoxShadow> ombraSuperficie;
  final Color suPrimario; // testo e icone sopra hero e pulsanti
  final Color suBarra; // icone non attive nella barra
  final Color bagliore; // alone degli anelli

  const Pulse({
    required this.hero,
    required this.primario,
    required this.superficie,
    required this.barra,
    required this.anello,
    required this.sfondo,
    required this.ombraHero,
    required this.ombraPrimario,
    required this.ombraSuperficie,
    required this.suPrimario,
    required this.suBarra,
    required this.bagliore,
  });

  static Pulse di(BuildContext context) =>
      Theme.of(context).extension<Pulse>() ?? scuro;

  /// Lo stile per fondo (scuro o chiaro) e accento (rosso o neon).
  static Pulse per({required bool scuro, required bool neon}) =>
      scuro ? (neon ? scuroNeon : Pulse.scuro) : (neon ? chiaro : chiaroRosso);

  /// Fondo grafite con l'accento neon.
  static const scuroNeon = Pulse(
    hero: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF5FAE),
        Color(0xFFFF2E93),
        Color(0xFFB566FF),
        Color(0xFF4FB6FF),
      ],
      stops: [0, 0.38, 0.72, 1],
    ),
    primario: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6FB5), Color(0xFFFF2E93), Color(0xFFC25BFF)],
      stops: [0, 0.5, 1],
    ),
    superficie: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF23232A), Color(0xFF141418)],
    ),
    barra: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF26262D), Color(0xFF131317)],
    ),
    anello: [Color(0xFF00E5D4), Color(0xFF2EA8FF), Color(0xFFB566FF)],
    sfondo: [
      RadialGradient(
        center: Alignment(-1, -1),
        radius: 1.1,
        colors: [Color(0xFF0B2A28), Color(0x000B0B0D)],
        stops: [0, 0.65],
      ),
      RadialGradient(
        center: Alignment(1, -0.3),
        radius: 1.1,
        colors: [Color(0xFF2E0E22), Color(0x000B0B0D)],
        stops: [0, 0.65],
      ),
    ],
    ombraHero: [
      BoxShadow(
        color: Color(0x66FF2E93),
        blurRadius: 32,
        spreadRadius: -6,
        offset: Offset(0, 10),
      ),
      BoxShadow(
        color: Color(0x592EA8FF),
        blurRadius: 30,
        spreadRadius: -14,
        offset: Offset(12, 14),
      ),
    ],
    ombraPrimario: [
      BoxShadow(
        color: Color(0x73FF2E93),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
    ombraSuperficie: [
      BoxShadow(
        color: Color(0xB3000000),
        blurRadius: 24,
        spreadRadius: -6,
        offset: Offset(0, 10),
      ),
    ],
    suPrimario: Color(0xFF14141A),
    suBarra: Color(0xFFA1A1AA),
    bagliore: Color(0x7300D2C3),
  );

  /// Fondo bianco con l'accento rosso.
  static const chiaroRosso = Pulse(
    hero: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B73), Color(0xFFFF3B47), Color(0xFFB3122A)],
      stops: [0, 0.42, 1],
    ),
    primario: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B73), Color(0xFFFF3B47), Color(0xFFC8162A)],
      stops: [0, 0.45, 1],
    ),
    superficie: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFD)],
    ),
    barra: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2A2A33), Color(0xFF121218)],
    ),
    anello: [Color(0xFFEEA82F), Color(0xFFFF3B47), Color(0xFFB3122A)],
    sfondo: [
      RadialGradient(
        center: Alignment(1, -1),
        radius: 1.2,
        colors: [Color(0xFFFFE1E3), Color(0x00F6F6FA)],
        stops: [0, 0.7],
      ),
    ],
    ombraHero: [
      BoxShadow(
        color: Color(0x59FF3B47),
        blurRadius: 32,
        spreadRadius: -6,
        offset: Offset(0, 10),
      ),
    ],
    ombraPrimario: [
      BoxShadow(
        color: Color(0x59FF3B47),
        blurRadius: 22,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
    ombraSuperficie: [
      BoxShadow(
        color: Color(0x401E143C),
        blurRadius: 24,
        spreadRadius: -12,
        offset: Offset(0, 10),
      ),
    ],
    suPrimario: Color(0xFF160304),
    suBarra: Color(0xFFC9C9D3),
    bagliore: Color(0x59FF3B47),
  );

  static const scuro = Pulse(
    hero: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B73), Color(0xFFFF3B47), Color(0xFFB3122A)],
      stops: [0, 0.42, 1],
    ),
    primario: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B73), Color(0xFFFF3B47), Color(0xFFC8162A)],
      stops: [0, 0.45, 1],
    ),
    superficie: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF23232A), Color(0xFF141418)],
    ),
    barra: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF26262D), Color(0xFF131317)],
    ),
    anello: [Color(0xFFEEA82F), Color(0xFFFF3B47), Color(0xFFB3122A)],
    sfondo: [
      RadialGradient(
        center: Alignment(1, -1),
        radius: 1.3,
        colors: [Color(0xFF2E0F14), Color(0x000B0B0D)],
        stops: [0, 0.6],
      ),
    ],
    ombraHero: [
      BoxShadow(
        color: Color(0x66FF3B47),
        blurRadius: 32,
        spreadRadius: -6,
        offset: Offset(0, 10),
      ),
    ],
    ombraPrimario: [
      BoxShadow(
        color: Color(0x73FF3B47),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
    ombraSuperficie: [
      BoxShadow(
        color: Color(0xB3000000),
        blurRadius: 24,
        spreadRadius: -6,
        offset: Offset(0, 10),
      ),
    ],
    suPrimario: Color(0xFF160304),
    suBarra: Color(0xFFA1A1AA),
    bagliore: Color(0x73FF3B47),
  );

  static const chiaro = Pulse(
    hero: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF5FAE),
        Color(0xFFFF2E93),
        Color(0xFFB566FF),
        Color(0xFF4FB6FF),
      ],
      stops: [0, 0.38, 0.72, 1],
    ),
    primario: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6FB5), Color(0xFFFF2E93), Color(0xFFC25BFF)],
      stops: [0, 0.5, 1],
    ),
    superficie: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFD)],
    ),
    barra: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2A2A33), Color(0xFF121218)],
    ),
    anello: [Color(0xFF00E5D4), Color(0xFF2EA8FF), Color(0xFFB566FF)],
    sfondo: [
      RadialGradient(
        center: Alignment(-1, -1),
        radius: 1.1,
        colors: [Color(0xFFD8FBF7), Color(0x00F6F6FA)],
        stops: [0, 0.7],
      ),
      RadialGradient(
        center: Alignment(1, -0.3),
        radius: 1.1,
        colors: [Color(0xFFFFE2F1), Color(0x00F6F6FA)],
        stops: [0, 0.7],
      ),
    ],
    ombraHero: [
      BoxShadow(
        color: Color(0x66FF2E93),
        blurRadius: 32,
        spreadRadius: -6,
        offset: Offset(0, 10),
      ),
      BoxShadow(
        color: Color(0x592EA8FF),
        blurRadius: 30,
        spreadRadius: -14,
        offset: Offset(12, 14),
      ),
    ],
    ombraPrimario: [
      BoxShadow(
        color: Color(0x66FF2E93),
        blurRadius: 22,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
    ombraSuperficie: [
      BoxShadow(
        color: Color(0x401E143C),
        blurRadius: 24,
        spreadRadius: -12,
        offset: Offset(0, 10),
      ),
    ],
    suPrimario: Color(0xFF14141A),
    suBarra: Color(0xFFC9C9D3),
    bagliore: Color(0x7300D2C3),
  );

  @override
  Pulse copyWith() => this;

  @override
  Pulse lerp(covariant Pulse? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// Tema grafite (scuro) o bianco (chiaro), con l'accento rosso o neon e i
/// caratteri Pulse.
ThemeData creaTema(Brightness b, {bool neon = false}) {
  final scuro = b == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: const Color(0xFF262624),
    brightness: b,
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
  );
  // L'accento: rosso standard o neon, per fondo scuro o chiaro.
  final accento = switch ((scuro, neon)) {
    (true, false) => (
      primary: rossoPulse,
      onPrimary: const Color(0xFF160304),
      primaryContainer: const Color(0xFF3A1216),
      onPrimaryContainer: const Color(0xFFFFDAD5),
      secondary: const Color(0xFFFF7A59),
      secondaryContainer: const Color(0xFF2A0D10),
      onSecondaryContainer: const Color(0xFFFFC9CC),
      tertiary: const Color(0xFF4ADE80),
      testo: const Color(0xFFFF5A63),
    ),
    (true, true) => (
      primary: rosaNeon,
      onPrimary: const Color(0xFF14141A),
      primaryContainer: const Color(0xFF3A1030),
      onPrimaryContainer: const Color(0xFFFFD6EC),
      secondary: acquaNeon,
      secondaryContainer: const Color(0xFF0E2E2C),
      onSecondaryContainer: const Color(0xFFB8FFF7),
      tertiary: azzurroNeon,
      testo: const Color(0xFFFF6FB5),
    ),
    (false, false) => (
      primary: rossoPulse,
      onPrimary: const Color(0xFF160304),
      primaryContainer: const Color(0xFFFFE1E3),
      onPrimaryContainer: const Color(0xFF8C0B1A),
      secondary: const Color(0xFFFF7A59),
      secondaryContainer: const Color(0xFFFFE6DE),
      onSecondaryContainer: const Color(0xFF8A2A10),
      tertiary: const Color(0xFF16A34A),
      testo: const Color(0xFFC8102E),
    ),
    (false, true) => (
      primary: rosaNeon,
      onPrimary: const Color(0xFF14141A),
      primaryContainer: const Color(0xFFFFE0EF),
      onPrimaryContainer: const Color(0xFF8F004E),
      secondary: acquaNeon,
      secondaryContainer: const Color(0xFFFFE0EF),
      onSecondaryContainer: const Color(0xFFA3004F),
      tertiary: azzurroNeon,
      // Il rosa neon sul bianco non si legge come testo: un rosa più scuro.
      testo: const Color(0xFFC2006A),
    ),
  };
  final scheme = scuro
      ? base.copyWith(
          primary: accento.primary,
          onPrimary: accento.onPrimary,
          primaryContainer: accento.primaryContainer,
          onPrimaryContainer: accento.onPrimaryContainer,
          secondary: accento.secondary,
          onSecondary: accento.onPrimary,
          secondaryContainer: accento.secondaryContainer,
          onSecondaryContainer: accento.onSecondaryContainer,
          tertiary: accento.tertiary,
          surface: const Color(0xFF0B0B0D),
          onSurface: const Color(0xFFF4F4F5),
          onSurfaceVariant: const Color(0xFFA1A1AA),
          surfaceContainerLowest: const Color(0xFF0B0B0D),
          surfaceContainerLow: const Color(0xFF17171B),
          surfaceContainer: const Color(0xFF1C1C21),
          surfaceContainerHigh: const Color(0xFF222227),
          surfaceContainerHighest: const Color(0xFF2A2A30),
          outline: const Color(0xFF52525B),
          outlineVariant: const Color(0xFF27272A),
        )
      : base.copyWith(
          primary: accento.primary,
          onPrimary: accento.onPrimary,
          primaryContainer: accento.primaryContainer,
          onPrimaryContainer: accento.onPrimaryContainer,
          secondary: accento.secondary,
          onSecondary: accento.onPrimary,
          secondaryContainer: accento.secondaryContainer,
          onSecondaryContainer: accento.onSecondaryContainer,
          tertiary: accento.tertiary,
          surface: const Color(0xFFF6F6FA),
          onSurface: const Color(0xFF14141A),
          onSurfaceVariant: const Color(0xFF55555F),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFFFFFFF),
          surfaceContainer: const Color(0xFFF3F3F8),
          surfaceContainerHigh: const Color(0xFFEFEFF5),
          surfaceContainerHighest: const Color(0xFFE8E8EF),
          outline: const Color(0xFFB9B9C4),
          outlineVariant: const Color(0xFFE4E4EC),
        );
  final testoAccento = accento.testo;

  // Dimensioni di Material 3 più colori e caratteri dello stile.
  final testo = Typography.englishLike2021
      .merge(
        scuro ? Typography.whiteMountainView : Typography.blackMountainView,
      )
      .apply(
        fontFamily: famigliaTesto,
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      );
  TextStyle? titolo(TextStyle? s, {double spazio = -0.5}) => s?.copyWith(
    fontFamily: famigliaTitoli,
    fontWeight: FontWeight.w700,
    letterSpacing: spazio,
  );
  final textTheme = testo.copyWith(
    displayLarge: titolo(testo.displayLarge, spazio: -1.5),
    displayMedium: titolo(testo.displayMedium, spazio: -1),
    displaySmall: titolo(testo.displaySmall, spazio: -1),
    headlineLarge: titolo(testo.headlineLarge, spazio: -1),
    headlineMedium: titolo(testo.headlineMedium, spazio: -0.8),
    headlineSmall: titolo(testo.headlineSmall),
    titleLarge: titolo(testo.titleLarge, spazio: -0.3),
    titleMedium: testo.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    titleSmall: testo.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: testo.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  const pillola = StadiumBorder();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: famigliaTesto,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [Pulse.per(scuro: scuro, neon: neon)],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pillola,
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(
          fontFamily: famigliaTesto,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pillola,
        minimumSize: const Size(64, 48),
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        textStyle: const TextStyle(
          fontFamily: famigliaTesto,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: testoAccento,
        minimumSize: const Size(48, 44),
        textStyle: const TextStyle(
          fontFamily: famigliaTesto,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: pillola,
        foregroundColor: scheme.onSurfaceVariant,
        selectedBackgroundColor: scheme.onSurface,
        selectedForegroundColor: scheme.surface,
        textStyle: const TextStyle(
          fontFamily: famigliaTesto,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: pillola,
      side: BorderSide.none,
      backgroundColor: scheme.surfaceContainerHigh,
      labelStyle: TextStyle(
        fontFamily: famigliaTesto,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: neon ? acquaNeon : rossoPulse,
      linearTrackColor: scheme.surfaceContainerHighest,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
  );
}
