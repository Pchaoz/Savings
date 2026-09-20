/// Los tokens del documento 07. Cada color significa una cosa y solo esa.
///
/// La regla que no se rompe: **el verde es solo para la bolsa de caprichos.**
/// Si el verde significa "gastalo tranquilo", no puede significar ademas
/// "ha entrado dinero". Por eso los ingresos van en blanco con su signo +.
library;

import 'package:flutter/material.dart';

abstract final class C {
  /// Caprichos. Luz verde: este dinero es para gastarlo sin culpa.
  static const go = Color(0xFF4FD48C);

  /// Ahorro. Azul acero, dinero en reposo, no se toca.
  static const calm = Color(0xFF7E9BBF);

  /// Gastos.
  static const spend = Color(0xFFE8705F);

  /// Fondo. Negro azulado, NO negro puro: en OLED el negro absoluto
  /// con texto claro produce halos y cansa la vista de noche.
  static const bg = Color(0xFF12161C);
  static const surface = Color(0xFF1B212A);
  static const raised = Color(0xFF232B36);
  static const line = Color(0xFF2E3743);

  static const ink = Color(0xFFE8EDF2);
  static const inkDim = Color(0xFF8A96A5);
  static const inkFaint = Color(0xFF5C6775);

  /// Fondo y borde de la unica superficie tenida de la pantalla de inicio:
  /// la caja "A caprichos" del sifon.
  static final goTint = go.withValues(alpha: 0.07);
  static final goEdge = go.withValues(alpha: 0.16);
}

abstract final class R {
  static const card = 9.0;
  static const container = 14.0;
  static const fab = 19.0;
}

/// Cifras tabulares: sin esto los numeros cambian de ancho al actualizarse
/// y la pantalla "baila" cada vez que apuntas un gasto.
const _tabular = [FontFeature.tabularFigures()];

abstract final class T {
  /// El numero grande de la bolsa.
  static const hero = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.6,
    fontFeatures: _tabular,
  );

  /// Importes en listas y filas.
  static const amount = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  /// Totales destacados.
  static const amountLarge = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// Las etiquetas en versalitas de las secciones.
  static const eyebrow = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: C.inkFaint,
  );

  static const body = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500);
  static const meta = TextStyle(fontSize: 12, color: C.inkFaint);
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.go,
    brightness: Brightness.dark,
  ).copyWith(
    surface: C.bg,
    primary: C.go,
    onPrimary: const Color(0xFF05200F),
    outline: C.line,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    fontFamily: 'Inter',
    dividerTheme: const DividerThemeData(color: C.line, thickness: 1, space: 1),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: C.go,
      foregroundColor: const Color(0xFF05200F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.fab),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: T.body,
      bodySmall: T.meta,
      labelSmall: T.eyebrow,
    ).apply(bodyColor: C.ink, displayColor: C.ink),
  );
}
