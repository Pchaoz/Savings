/// Todo el dinero de la app vive aqui como `int` de centimos.
///
/// Nunca uses `double` para importes: 0.1 + 0.2 != 0.3, y tras encadenar
/// 24 meses aparecen desajustes de centimos. Una app de dinero de la que
/// no te fias es una app que no abres.
library;

import 'package:intl/intl.dart';

final _eur = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
final _plain = NumberFormat('#,##0.00', 'es_ES');

/// `643331` -> `"6.433,31 €"`
String formatCents(int cents) => _eur.format(cents / 100);

/// Sin simbolo, para tablas donde la moneda ya se sobreentiende.
/// `643331` -> `"6.433,31"`
String formatCentsPlain(int cents) => _plain.format(cents / 100);

/// Fuerza el signo. `111719` -> `"+1.117,19 €"`, `-6470` -> `"−64,70 €"`
///
/// Usa el menos tipografico (U+2212), no el guion del teclado: se alinea
/// con las cifras y no se confunde con un separador.
String formatCentsSigned(int cents) {
  final body = formatCents(cents.abs());
  if (cents == 0) return body;
  return cents > 0 ? '+$body' : '−$body';
}

/// Acumulador para el teclado numerico de "Nuevo gasto".
///
/// Funciona como el de una calculadora de caja: los digitos entran por la
/// derecha. Tecleando 1, 8, 0 se obtiene 1,80 €.
class CentsInput {
  CentsInput([this._cents = 0]);

  int _cents;
  int get cents => _cents;
  bool get isEmpty => _cents == 0;

  /// Tope de 999.999,99 € para que no se desborde el layout ni el int.
  static const int _max = 99999999;

  void pushDigit(int digit) {
    assert(digit >= 0 && digit <= 9);
    final next = _cents * 10 + digit;
    if (next <= _max) _cents = next;
  }

  /// La tecla "00", que ahorra dos pulsaciones en importes redondos.
  void pushDoubleZero() {
    final next = _cents * 100;
    _cents = next <= _max ? next : _max;
  }

  void backspace() => _cents ~/= 10;

  void clear() => _cents = 0;

  /// Lo que se ve mientras tecleas: `"0,00"`, `"1,80"`, `"1.234,56"`
  String get display => formatCentsPlain(_cents);
}
