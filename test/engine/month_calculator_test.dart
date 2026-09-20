/// Estos tests son la fuente de verdad del proyecto.
///
/// El TEST 1 usa los datos reales de agosto de 2026 del Excel original.
/// Si pasa, el motor es correcto y no hay que volver a dudar de el.
///
/// Ejecutar con:  flutter test
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:savings/domain/engine/month_calculator.dart';
import 'package:savings/domain/models/models.dart';

// Atajos para que los casos se lean como el Excel.
TxInput income(int c) => TxInput(kind: CategoryKind.income, amountCents: c);
TxInput fixed(int c) => TxInput(kind: CategoryKind.fixed, amountCents: c);
TxInput variable(int c) => TxInput(kind: CategoryKind.variable, amountCents: c);
TxInput treat(int c) => TxInput(kind: CategoryKind.treat, amountCents: c);

/// Agosto de 2026, tal cual esta en el Excel.
final agosto = <TxInput>[
  income(111719), //   Nomina              1.117,19
  fixed(6470), //      Suscripciones          64,70
  variable(6346), //   Comida                 63,46
  variable(1960), //   Restaurantes           19,60
  treat(2478), //      Xiaomi band 8 pro      24,78
  treat(2200), //      Skin Gwen              22,00
  treat(2000), //      De fiesta              20,00
];

const saldoAgosto = 556082; // 5.560,82

void main() {
  group('Agosto 2026 — contra el Excel real', () {
    final r = calculateMonth(
      openingBalanceCents: saldoAgosto,
      bagOpeningCents: 0,
      transactions: agosto,
    );

    test('ganancia neta = 969,43', () => expect(r.netCents, 96943));
    test('generado 10% = 96,94', () => expect(r.generatedCents, 9694));
    test('ahorrado = 872,49', () => expect(r.savedCents, 87249));
    test('saldo final = 6.433,31', () => expect(r.closingBalanceCents, 643331));
    test('bolsa disponible = 96,94', () => expect(r.bagAvailableCents, 9694));
    test('bolsa final = 30,16', () => expect(r.bagClosingCents, 3016));
    test('patrimonio = 6.463,47', () => expect(r.netWorthCents, 646347));
  });

  group('Mes en perdidas', () {
    final r = calculateMonth(
      openingBalanceCents: 643331,
      bagOpeningCents: 3016,
      transactions: [income(111719), fixed(6470), variable(130000)],
    );

    test('la neta puede ser negativa', () => expect(r.netCents, -24751));

    test('no se genera capricho negativo', () {
      expect(r.generatedCents, 0);
    });

    test('el ahorro baja el importe completo', () {
      expect(r.savedCents, -24751);
    });

    test('la bolsa no se toca: ese dinero ya estaba apartado', () {
      expect(r.bagClosingCents, 3016);
    });
  });

  group('Devoluciones', () {
    test('devolver un capricho deja la bolsa como estaba', () {
      final r = calculateMonth(
        openingBalanceCents: saldoAgosto,
        bagOpeningCents: 0,
        transactions: [...agosto, treat(6000), treat(-6000)],
      );
      expect(r.bagClosingCents, 3016);
      expect(r.netCents, 96943);
    });

    test('devolver un gasto variable devuelve tambien el 10% de margen', () {
      final conCompra = calculateMonth(
        openingBalanceCents: saldoAgosto,
        bagOpeningCents: 0,
        transactions: [...agosto, variable(3000)],
      );
      final conDevolucion = calculateMonth(
        openingBalanceCents: saldoAgosto,
        bagOpeningCents: 0,
        transactions: [...agosto, variable(3000), variable(-3000)],
      );

      // Una camiseta de 30 EUR cuesta 3 EUR de margen para caprichos.
      expect(conCompra.bagClosingCents, 2716);
      expect(conDevolucion.bagClosingCents, 3016);
    });
  });

  group('Borrado', () {
    test('un movimiento borrado no entra en el calculo', () {
      final r = calculateMonth(
        openingBalanceCents: saldoAgosto,
        bagOpeningCents: 0,
        transactions: [
          ...agosto,
          const TxInput(
            kind: CategoryKind.variable,
            amountCents: 1800,
            deleted: true,
          ),
        ],
      );
      expect(r.bagClosingCents, 3016);
    });
  });

  group('Bolsa en numeros rojos', () {
    test('un capricho mayor que la bolsa arrastra el negativo', () {
      final r = calculateMonth(
        openingBalanceCents: 643331,
        bagOpeningCents: 3016,
        transactions: [income(111719), fixed(6470), treat(20000)],
      );
      // 30,16 + 105,25 - 200,00 = -64,59
      expect(r.bagClosingCents, -6459);
    });
  });

  group('Cascada de meses', () {
    final septiembre = [income(111719), fixed(6370)];
    final octubre = [income(111719), fixed(6370), fixed(4550)];

    final meses = recalculateCascade(
      seedBalanceCents: saldoAgosto,
      monthlyTransactions: [agosto, septiembre, octubre],
    );

    test('septiembre hereda el cierre de agosto', () {
      expect(meses[1].openingBalanceCents, 643331);
      expect(meses[1].bagOpeningCents, 3016);
    });

    test('septiembre cierra en 7.381,45', () {
      expect(meses[1].closingBalanceCents, 738145);
      expect(meses[1].bagClosingCents, 13551);
    });

    test('octubre cierra en 8.288,64', () {
      expect(meses[2].closingBalanceCents, 828864);
      expect(meses[2].bagClosingCents, 23631);
    });
  });

  group('Invariante contable', () {
    // Si esto falla, la app esta mintiendo sobre tu dinero.
    test('patrimonio siempre = saldo inicial + entradas - salidas', () {
      final casos = <List<TxInput>>[
        agosto,
        [income(111719), fixed(6470), variable(130000)],
        [income(111719), fixed(6470), treat(20000)],
        [...agosto, treat(6000), treat(-6000)],
      ];

      for (final movimientos in casos) {
        final r = calculateMonth(
          openingBalanceCents: saldoAgosto,
          bagOpeningCents: 5000,
          transactions: movimientos,
        );

        var flujo = 0;
        for (final t in movimientos) {
          if (t.deleted) continue;
          flujo += t.kind == CategoryKind.income
              ? t.amountCents
              : -t.amountCents;
        }

        expect(r.netWorthCents, saldoAgosto + 5000 + flujo);
      }
    });
  });
}
