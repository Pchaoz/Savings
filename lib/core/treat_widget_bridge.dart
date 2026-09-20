/// Puente con el widget nativo de Android de la bolsa de caprichos
/// (pantalla de inicio del telefono). Sin ningun paquete de terceros a
/// proposito -- solo un `MethodChannel` a `MainActivity.kt` /
/// `TreatBagWidgetProvider.kt`, para no repetir el problema de
/// compilacion en Windows que costo anadir `share_plus` (primera
/// dependencia nativa del proyecto). Flutter siempre manda el importe ya
/// formateado ("21,85 €"); el lado nativo no calcula nada, solo lo pinta.
library;

import 'package:flutter/services.dart';

abstract final class TreatWidgetBridge {
  static const _channel = MethodChannel('com.pchaozz.savings/treat_widget');

  /// Actualiza el texto, el color (si esta en negativo) y la barra de
  /// progreso del widget de pantalla de inicio. `overspent` y
  /// `spentRatio` son los mismos valores que ya calcula `_TreatBagCard`
  /// en home_screen.dart (`result.bagClosingCents < 0` y
  /// `result.bagSpentRatio`) -- el widget no decide nada por su cuenta,
  /// solo repite lo que Flutter ya sabe. Si el widget no esta puesto en
  /// ninguna pantalla de inicio, Android simplemente no tiene nada que
  /// repintar -- no hace falta comprobarlo desde aqui. Envuelto en
  /// try/catch porque esto es un extra visual: si algo falla (por
  /// ejemplo en un emulador raro sin lanzador de widgets) no debe romper
  /// Inicio.
  static Future<void> updateAmount({
    required String amountText,
    required bool overspent,
    required double spentRatio,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateAmount', {
        'amount': amountText,
        'overspent': overspent,
        'ratio': spentRatio.clamp(0.0, 1.0),
      });
    } catch (_) {
      // silencioso a proposito, ver comentario de arriba.
    }
  }
}
