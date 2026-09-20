/// El motor. Funciones puras: entra un objeto, sale un objeto.
/// Ni base de datos, ni providers, ni widgets. Por eso se puede testear
/// sin emulador y por eso los tests son la fuente de verdad del proyecto.
library;

import '../models/models.dart';

/// Margen por defecto para la bolsa de caprichos.
/// Es el 0,1 de la celda B49 del Excel original.
const double kDefaultTreatRate = 0.10;

/// Calcula un mes completo.
///
/// Replica exactamente las formulas del Excel `Control_de_Ahorros_2026-2027`:
///
/// ```
/// neta      = ingresos - fijos - variables
/// generado  = MAX(0, neta) * rate          <- el MAX(0,...) importa
/// ahorrado  = neta - generado
/// saldoFin  = saldoIni + ahorrado
/// bolsaFin  = bolsaIni + generado - gastadoCaprichos
/// ```
MonthResult calculateMonth({
  required int openingBalanceCents,
  required int bagOpeningCents,
  required List<TxInput> transactions,
  double treatRate = kDefaultTreatRate,
}) {
  var income = 0, fixed = 0, variable = 0, treat = 0;

  for (final t in transactions) {
    if (t.deleted) continue;
    switch (t.kind) {
      case CategoryKind.income:
        income += t.amountCents;
      case CategoryKind.fixed:
        fixed += t.amountCents;
      case CategoryKind.variable:
        variable += t.amountCents;
      case CategoryKind.treat:
        treat += t.amountCents;
    }
  }

  final net = income - fixed - variable;

  // Un mes en perdidas no genera capricho negativo. Sin este MAX(0,...)
  // el ahorro bajaria menos de lo que has perdido y apareceria dinero
  // de la nada. Es el MAX(0;B45)*B49 del Excel.
  final generated = net <= 0 ? 0 : _roundHalfAwayFromZero(net * treatRate);

  final saved = net - generated;
  final bagAvailable = bagOpeningCents + generated;

  return MonthResult(
    incomeCents: income,
    fixedCents: fixed,
    variableCents: variable,
    netCents: net,
    generatedCents: generated,
    savedCents: saved,
    openingBalanceCents: openingBalanceCents,
    closingBalanceCents: openingBalanceCents + saved,
    bagOpeningCents: bagOpeningCents,
    bagAvailableCents: bagAvailable,
    bagSpentCents: treat,
    bagClosingCents: bagAvailable - treat,
  );
}

/// Encadena meses igual que las formulas `='Ago 2026'!B69` del Excel.
///
/// [monthlyTransactions] va en orden cronologico. El saldo y la bolsa de
/// cada mes salen del cierre del anterior.
///
/// Se recalcula entero cada vez que tocas cualquier movimiento. Con 24 meses
/// son microsegundos, asi que no merece la pena cachear nada.
List<MonthResult> recalculateCascade({
  required int seedBalanceCents,
  required List<List<TxInput>> monthlyTransactions,
  double treatRate = kDefaultTreatRate,
}) {
  final results = <MonthResult>[];
  var balance = seedBalanceCents;
  var bag = 0;

  for (final transactions in monthlyTransactions) {
    final r = calculateMonth(
      openingBalanceCents: balance,
      bagOpeningCents: bag,
      transactions: transactions,
      treatRate: treatRate,
    );
    results.add(r);
    balance = r.closingBalanceCents;
    bag = r.bagClosingCents;
  }

  return results;
}

/// El unico redondeo de toda la app, y solo se aplica al calcular el 10 %.
/// `num.round()` de Dart ya redondea alejandose del cero; lo envolvemos
/// para dejar constancia de que es una decision, no un descuido.
int _roundHalfAwayFromZero(double value) => value.round();
