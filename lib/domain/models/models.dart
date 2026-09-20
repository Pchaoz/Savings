/// Tipos base del dominio. Sin dependencias de Flutter ni de la base de datos:
/// esto tiene que poder testearse sin emulador.
library;

/// El cubo al que pertenece una categoria. Es lo que decide como afecta
/// un movimiento al calculo del mes.
enum CategoryKind {
  /// Nomina, ingresos extra. Suma a la ganancia neta.
  income,

  /// Suscripciones, T-Jove, luz. Resta de la ganancia neta.
  fixed,

  /// Comida, restaurantes, ropa. Resta de la ganancia neta.
  variable,

  /// Caprichos. NO toca la ganancia neta: sale de la bolsa.
  treat,
}

/// Un movimiento tal y como lo necesita el motor de calculo.
///
/// [amountCents] es normalmente positivo. Un valor **negativo** representa
/// una devolucion (ver doc 08).
class TxInput {
  const TxInput({
    required this.kind,
    required this.amountCents,
    this.deleted = false,
  });

  final CategoryKind kind;
  final int amountCents;

  /// Corresponde a `deleted_at != null` en la base de datos.
  /// Los movimientos borrados no entran en ningun calculo.
  final bool deleted;
}

/// Resultado completo de un mes. Nada de esto se guarda en la base de datos:
/// se calcula siempre a partir de los movimientos.
class MonthResult {
  const MonthResult({
    required this.incomeCents,
    required this.fixedCents,
    required this.variableCents,
    required this.netCents,
    required this.generatedCents,
    required this.savedCents,
    required this.openingBalanceCents,
    required this.closingBalanceCents,
    required this.bagOpeningCents,
    required this.bagAvailableCents,
    required this.bagSpentCents,
    required this.bagClosingCents,
  });

  /// Total de ingresos del mes.
  final int incomeCents;

  /// Total de gastos fijos.
  final int fixedCents;

  /// Total de gastos variables.
  final int variableCents;

  /// Ingresos - fijos - variables. Puede ser negativa.
  final int netCents;

  /// El 10 % apartado para la bolsa. Nunca negativo.
  final int generatedCents;

  /// Lo que engorda el ahorro: neta - generado.
  final int savedCents;

  final int openingBalanceCents;
  final int closingBalanceCents;

  /// Arrastre de la bolsa del mes anterior.
  final int bagOpeningCents;

  /// Arrastre + generado, antes de gastar.
  final int bagAvailableCents;

  /// Lo gastado en caprichos este mes.
  final int bagSpentCents;

  /// Lo que queda en la bolsa. Puede ser negativo si te pasaste.
  final int bagClosingCents;

  /// Ahorro + bolsa. Esto es lo que deberia decir tu banco.
  int get netWorthCents => closingBalanceCents + bagClosingCents;

  /// Cuanto de la bolsa disponible llevas gastado, de 0 a 1.
  /// Devuelve 0 si no habia nada disponible, para no dividir entre cero.
  double get bagSpentRatio =>
      bagAvailableCents <= 0 ? 0 : bagSpentCents / bagAvailableCents;
}
