/// Prueba de integracion: base de datos SQLite en memoria -> repositorio.
/// Repite los casos clave de doc 08 (devoluciones) y del motor, pero
/// pasando por Drift de verdad en vez de construir TxInput a mano. Este
/// test es el que habria pillado el bug del signo en addRefund.
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savings/data/database.dart';
import 'package:savings/data/savings_repository.dart';
import 'package:savings/data/tables.dart';

void main() {
  late AppDatabase db;
  late SavingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SavingsRepository(db);
  });

  tearDown(() => db.close());

  Future<int> categoryIdOf(String name) async {
    final cats = await repo.categories;
    return cats.firstWhere((c) => c.name == name).id;
  }

  test('agosto 2026 real via el repositorio da los mismos numeros que el motor', () async {
    final nomina = await categoryIdOf('Nómina');
    final suscripciones = await categoryIdOf('Suscripciones');
    final comida = await categoryIdOf('Comida / Supermercado');
    final restaurantes = await categoryIdOf('Restaurantes / Ocio');
    final capricho = await categoryIdOf('Capricho');

    await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));
    await repo.addTransaction(categoryId: suscripciones, amountCents: 6470, date: DateTime(2026, 8, 2));
    await repo.addTransaction(categoryId: comida, amountCents: 6346, date: DateTime(2026, 8, 9));
    await repo.addTransaction(categoryId: restaurantes, amountCents: 1960, date: DateTime(2026, 8, 20));
    await repo.addTransaction(categoryId: capricho, amountCents: 2478, date: DateTime(2026, 8, 9));
    await repo.addTransaction(categoryId: capricho, amountCents: 2200, date: DateTime(2026, 8, 9));
    await repo.addTransaction(categoryId: capricho, amountCents: 2000, date: DateTime(2026, 8, 20));

    await db.into(db.months).insert(
          MonthsCompanion.insert(
            yearMonth: '2026-08',
            openingBalanceCents: const Value(556082),
          ),
        );

    final r = await repo.monthResult('2026-08');

    expect(r.netCents, 96943);
    expect(r.generatedCents, 9694);
    expect(r.savedCents, 87249);
    expect(r.closingBalanceCents, 643331);
    expect(r.bagClosingCents, 3016);
  });

  test('addRefund resta de la bolsa de capricho en vez de sumar (regresion del bug de signo)', () async {
    final nomina = await categoryIdOf('Nómina');
    final capricho = await categoryIdOf('Capricho');

    await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));
    final auricularesId = await repo.addTransaction(
      categoryId: capricho,
      amountCents: 6000,
      date: DateTime(2026, 8, 3),
      note: 'Auriculares Soundcore',
    );

    final antes = await repo.monthResult('2026-08');
    await repo.addRefund(
      originalTransactionId: auricularesId,
      amountCents: 6000,
      date: DateTime(2026, 8, 10),
    );
    final despues = await repo.monthResult('2026-08');

    // Si el bug siguiera ahi, esto daria antes.bagClosingCents - 6000.
    expect(despues.bagClosingCents, antes.bagClosingCents + 6000);
    expect(despues.netCents, antes.netCents); // los caprichos no tocan la neta
  });

  test('devolver un gasto variable sube tambien el margen de capricho', () async {
    final nomina = await categoryIdOf('Nómina');
    final ropa = await categoryIdOf('Ropa');

    await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));
    final camisetaId = await repo.addTransaction(
      categoryId: ropa,
      amountCents: 3000,
      date: DateTime(2026, 8, 5),
    );

    final antes = await repo.monthResult('2026-08');
    await repo.addRefund(originalTransactionId: camisetaId, amountCents: 3000, date: DateTime(2026, 8, 6));
    final despues = await repo.monthResult('2026-08');

    expect(despues.netCents, antes.netCents + 3000);
    expect(despues.bagClosingCents, antes.bagClosingCents + 300); // 10% de 30 EUR
  });

  test('un movimiento borrado no cuenta en el resultado del mes', () async {
    final nomina = await categoryIdOf('Nómina');
    final comida = await categoryIdOf('Comida / Supermercado');

    await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));
    final malId = await repo.addTransaction(
      categoryId: comida,
      amountCents: 1800,
      date: DateTime(2026, 8, 24),
      note: 'Monster mal apuntado',
    );

    final antes = await repo.monthResult('2026-08');
    await repo.softDelete(malId, reason: 'mistake');
    final despues = await repo.monthResult('2026-08');

    expect(despues.netCents, antes.netCents + 1800);
  });

  test('movementsFor enlaza la devolucion con su compra original en ambos sentidos', () async {
    final nomina = await categoryIdOf('Nómina');
    final capricho = await categoryIdOf('Capricho');

    await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));
    final auricularesId = await repo.addTransaction(
      categoryId: capricho,
      amountCents: 6000,
      date: DateTime(2026, 8, 3),
      note: 'Auriculares Soundcore',
    );
    await repo.addRefund(
      originalTransactionId: auricularesId,
      amountCents: 6000,
      date: DateTime(2026, 8, 10),
    );

    final movimientos = await repo.movementsFor('2026-08');

    final original = movimientos.firstWhere((m) => m.transaction.id == auricularesId);
    expect(original.hasBeenRefunded, isTrue);
    expect(original.refundedBy?.amountCents, -6000);

    final devolucion = movimientos.firstWhere((m) => m.transaction.refundOfId == auricularesId);
    expect(devolucion.isRefund, isTrue);
    expect(devolucion.refundOf?.id, auricularesId);
  });

  group('pagar un gasto con una hucha', () {
    test('no cuenta en el resultado del mes, pero si resta de la hucha', () async {
      final nomina = await categoryIdOf('Nómina');
      final viajes = await categoryIdOf('Viajes');
      final pocketId = await repo.addPocket(name: 'Ahorro Japón');
      await repo.addPocketMovement(pocketId: pocketId, amountCents: 100000, date: DateTime(2026, 8, 1));

      await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));
      final antes = await repo.monthResult('2026-08');

      final vuelosId = await repo.addExpenseFromPocket(
        categoryId: viajes,
        amountCents: 60000,
        date: DateTime(2026, 8, 15),
        pocketId: pocketId,
        note: 'Vuelos',
      );

      final despues = await repo.monthResult('2026-08');
      final balances = await repo.pocketBalances();

      // El motor no se entera: el dinero ya estaba fuera de la neta
      // desde el dia que se metio en la hucha.
      expect(despues.netCents, antes.netCents);
      expect(despues.closingBalanceCents, antes.closingBalanceCents);
      // Pero la hucha si que baja.
      expect(balances[pocketId], 40000);

      // Sigue viendose en el historial, con su categoria de siempre.
      final movimientos = await repo.movementsFor('2026-08');
      final vuelos = movimientos.firstWhere((m) => m.transaction.id == vuelosId);
      expect(vuelos.category.id, viajes);
      expect(vuelos.transaction.paidFromPocketId, pocketId);
    });

    test('editar el importe reajusta el saldo de la hucha', () async {
      final viajes = await categoryIdOf('Viajes');
      final pocketId = await repo.addPocket(name: 'Ahorro Japón');
      await repo.addPocketMovement(pocketId: pocketId, amountCents: 100000, date: DateTime(2026, 8, 1));

      final vuelosId = await repo.addExpenseFromPocket(
        categoryId: viajes,
        amountCents: 60000,
        date: DateTime(2026, 8, 15),
        pocketId: pocketId,
      );

      await repo.updateTransaction(transactionId: vuelosId, categoryId: viajes, amountCents: 65000);

      expect((await repo.pocketBalances())[pocketId], 35000);
    });

    test('borrar (y deshacer) le devuelve, y le vuelve a quitar, el dinero a la hucha', () async {
      final viajes = await categoryIdOf('Viajes');
      final pocketId = await repo.addPocket(name: 'Ahorro Japón');
      await repo.addPocketMovement(pocketId: pocketId, amountCents: 100000, date: DateTime(2026, 8, 1));

      final vuelosId = await repo.addExpenseFromPocket(
        categoryId: viajes,
        amountCents: 60000,
        date: DateTime(2026, 8, 15),
        pocketId: pocketId,
      );
      expect((await repo.pocketBalances())[pocketId], 40000);

      await repo.softDelete(vuelosId, reason: 'mistake');
      expect((await repo.pocketBalances())[pocketId], 100000);

      await repo.restore(vuelosId);
      expect((await repo.pocketBalances())[pocketId], 40000);
    });

    test('una devolucion vuelve a la misma hucha, no a la cuenta principal', () async {
      final viajes = await categoryIdOf('Viajes');
      final pocketId = await repo.addPocket(name: 'Ahorro Japón');
      await repo.addPocketMovement(pocketId: pocketId, amountCents: 100000, date: DateTime(2026, 8, 1));

      final vuelosId = await repo.addExpenseFromPocket(
        categoryId: viajes,
        amountCents: 60000,
        date: DateTime(2026, 8, 15),
        pocketId: pocketId,
      );

      final antesMes = await repo.monthResult('2026-08');
      await repo.addRefund(originalTransactionId: vuelosId, amountCents: 10000, date: DateTime(2026, 8, 20));
      final despuesMes = await repo.monthResult('2026-08');

      expect((await repo.pocketBalances())[pocketId], 50000);
      // Tampoco la devolucion cuenta en el motor: sigue sin ser "dinero
      // nuevo" de la cuenta principal.
      expect(despuesMes.netCents, antesMes.netCents);
    });
  });

  group('borrar categorías', () {
    test('una categoria nueva sin usar se puede borrar', () async {
      final id = await repo.addCategory(name: 'Manias', kind: CategoryKindDb.variable);

      expect(await repo.categoryDeleteBlockReason(id), isNull);

      await repo.deleteCategory(id);
      final restantes = await repo.categories;
      expect(restantes.any((c) => c.id == id), isFalse);
    });

    test('no se puede borrar una categoria con movimientos', () async {
      final ropa = await categoryIdOf('Ropa');
      await repo.addTransaction(categoryId: ropa, amountCents: 3000, date: DateTime(2026, 8, 5));

      final reason = await repo.categoryDeleteBlockReason(ropa);
      expect(reason, isNotNull);

      final categoriasAntes = await repo.categories;
      expect(categoriasAntes.any((c) => c.id == ropa), isTrue);
    });

    test('no se puede borrar la ultima categoria de un tipo, aunque no se use', () async {
      final ingresos =
          (await repo.categories).where((c) => c.kind == CategoryKindDb.income).toList();

      // Nos quedamos con una sola categoria de ingreso para forzar el caso.
      for (final c in ingresos.skip(1)) {
        expect(await repo.categoryDeleteBlockReason(c.id), isNull);
        await repo.deleteCategory(c.id);
      }
      final ultima = (await repo.categories).where((c) => c.kind == CategoryKindDb.income).single;

      expect(await repo.categoryDeleteBlockReason(ultima.id), isNotNull);
    });
  });

  group('recurrentes no se adelantan a un dia que no ha llegado', () {
    // Helpers locales de fecha: el mismo formato "2026-08" que usa el
    // repositorio, pero construido a partir de la fecha real del test
    // (no hay reloj inyectado en `SavingsRepository`, igual que
    // `purgeExpiredTrash` ya usaba `DateTime.now()` de verdad).
    String ymOf(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
    String ymShift(String ym, int deltaMonths) {
      final parts = ym.split('-');
      var year = int.parse(parts[0]);
      var month = int.parse(parts[1]) + deltaMonths;
      while (month > 12) {
        month -= 12;
        year++;
      }
      while (month < 1) {
        month += 12;
        year--;
      }
      return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    }

    test('no genera un movimiento de un mes que todavia no ha llegado', () async {
      final nomina = await categoryIdOf('Nómina');
      final hoy = ymOf(DateTime.now());
      final mesQueViene = ymShift(hoy, 1);

      await repo.addRecurringTemplate(
        name: 'Nómina',
        categoryId: nomina,
        amountCents: 111719,
        dayOfMonth: 1,
        everyNMonths: 1,
        anchorYearMonth: hoy,
      );

      // Pedir el mes que viene no debe crear ya su nomina: ese dia, en la
      // vida real, todavia no ha llegado.
      await repo.generateRecurringForMonth(mesQueViene);
      final movimientos = await repo.movementsFor(mesQueViene);
      expect(movimientos, isEmpty);
    });

    test('si el dia ya ha pasado (o es hoy) si que lo genera', () async {
      final nomina = await categoryIdOf('Nómina');
      final hoy = DateTime.now();
      final hoyYm = ymOf(hoy);
      // min(hoy.day, 28): si hoy es dia 29-31, un dia 28 ya paso; si es
      // dia 1-28, es justo hoy -- las dos cosas deben generar.
      final diaQueYaToca = hoy.day < 28 ? hoy.day : 28;

      await repo.addRecurringTemplate(
        name: 'Nómina',
        categoryId: nomina,
        amountCents: 111719,
        dayOfMonth: diaQueYaToca,
        everyNMonths: 1,
        anchorYearMonth: hoyYm,
      );

      await repo.generateRecurringForMonth(hoyYm);
      final movimientos = await repo.movementsFor(hoyYm);
      expect(movimientos, hasLength(1));
    });

    test('retira solo un adelanto que ya existiera de antes del arreglo', () async {
      final nomina = await categoryIdOf('Nómina');
      final hoy = ymOf(DateTime.now());
      final mesQueViene = ymShift(hoy, 1);
      final parts = mesQueViene.split('-');
      final fechaFutura = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);

      final tplId = await repo.addRecurringTemplate(
        name: 'Nómina',
        categoryId: nomina,
        amountCents: 111719,
        dayOfMonth: 1,
        everyNMonths: 1,
        // Ancla en el mes que viene a proposito: que no le toque generar
        // nada en "hoy" evita ruido en el test, que solo quiere probar
        // que se retira el adelanto ya existente.
        anchorYearMonth: mesQueViene,
      );

      // Simula el estado que dejo el bug: un movimiento ya generado con
      // fecha futura, saltandose `generateRecurringForMonth` a proposito
      // (asi era como se creaba antes del arreglo).
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              date: fechaFutura,
              amountCents: 111719,
              categoryId: nomina,
              note: const Value('Nómina'),
              recurringTemplateId: Value(tplId),
            ),
          );
      expect(await repo.movementsFor(mesQueViene), hasLength(1));

      // Cualquier llamada (aunque sea para el mes de hoy) debe retirarlo,
      // porque su fecha sigue sin haber llegado de verdad.
      await repo.generateRecurringForMonth(hoy);
      expect(await repo.movementsFor(mesQueViene), isEmpty);
    });

    test('lo mismo para las aportaciones automaticas a huchas', () async {
      final pocketId = await repo.addPocket(name: 'Ahorro Japón');
      final hoy = ymOf(DateTime.now());
      final mesQueViene = ymShift(hoy, 1);

      await repo.addPocketRecurringTemplate(
        pocketId: pocketId,
        name: 'Aportación mensual',
        amountCents: 5000,
        dayOfMonth: 1,
        everyNMonths: 1,
        anchorYearMonth: hoy,
      );

      await repo.generatePocketRecurringForMonth(mesQueViene);
      final balances = await repo.pocketBalances();
      expect(balances[pocketId] ?? 0, 0);
    });
  });

  group('aviso de sobrante de caprichos', () {
    test('contestar lo marca, y se puede volver a preguntar', () async {
      expect((await repo.getAppSettings()).dismissedTreatSweepYearMonth, isNull);

      await repo.dismissTreatSweepPrompt('2026-09');
      expect((await repo.getAppSettings()).dismissedTreatSweepYearMonth, '2026-09');

      // El botón nuevo de Ajustes ("Volver a preguntar por el sobrante de
      // caprichos") llama a esto -- hacia falta porque adelantar la fecha
      // del móvil para probar el aviso lo deja contestado de verdad para
      // ese mes, sin ninguna forma de deshacerlo hasta ahora.
      await repo.resetTreatSweepPrompt();
      expect((await repo.getAppSettings()).dismissedTreatSweepYearMonth, isNull);
    });
  });

  group('mes de nómina a nómina (monthStartDay)', () {
    test('con el día 1 (por defecto) cada fecha va a su mes de calendario', () async {
      final nomina = await categoryIdOf('Nómina');
      await repo.addTransaction(categoryId: nomina, amountCents: 100000, date: DateTime(2026, 8, 1));
      await repo.addTransaction(categoryId: nomina, amountCents: 100000, date: DateTime(2026, 8, 31));

      final agosto = await repo.movementsFor('2026-08');
      expect(agosto, hasLength(2));
    });

    test('con el día 28, el 28 de agosto ya cuenta para "septiembre"', () async {
      await repo.setMonthStartDay(28);
      final nomina = await categoryIdOf('Nómina');

      await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 28));

      // Ya no aparece en agosto...
      expect(await repo.movementsFor('2026-08'), isEmpty);
      // ...sino en el ciclo que llamamos "septiembre" (28 ago - 27 sep).
      expect(await repo.movementsFor('2026-09'), hasLength(1));
    });

    test('el 27 de septiembre todavía es del mismo ciclo "septiembre"', () async {
      await repo.setMonthStartDay(28);
      final comida = await categoryIdOf('Comida / Supermercado');

      await repo.addTransaction(categoryId: comida, amountCents: 2000, date: DateTime(2026, 9, 27));

      expect(await repo.movementsFor('2026-09'), hasLength(1));
      expect(await repo.movementsFor('2026-10'), isEmpty);
    });

    test('el 28 de septiembre ya empieza el ciclo siguiente ("octubre")', () async {
      await repo.setMonthStartDay(28);
      final comida = await categoryIdOf('Comida / Supermercado');

      await repo.addTransaction(categoryId: comida, amountCents: 2000, date: DateTime(2026, 9, 28));

      expect(await repo.movementsFor('2026-09'), isEmpty);
      expect(await repo.movementsFor('2026-10'), hasLength(1));
    });

    test(
        'con el día 28, la nómina del 28 de agosto ya da margen de '
        'caprichos en septiembre desde el día 1 del ciclo', () async {
      await repo.setMonthStartDay(28);
      final nomina = await categoryIdOf('Nómina');

      // La nómina real ya existe con fecha 28 de agosto (como si ya
      // hubiera llegado). Nada más apuntado en el ciclo "septiembre"
      // todavía.
      await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 28));

      final r = await repo.monthResult('2026-09');
      // Sin este cambio, "septiembre" no tendría ningún ingreso todavía
      // y `generatedCents` saldría a 0 -- el problema real que reportó
      // Pol ("no tengo margen ningún de ahorros").
      expect(r.netCents, greaterThan(0));
      expect(r.generatedCents, greaterThan(0));
    });

    test('generateRecurringForMonth genera la nómina del día 28 dentro del ciclo correcto', () async {
      await repo.setMonthStartDay(28);
      final nomina = await categoryIdOf('Nómina');

      await repo.addRecurringTemplate(
        name: 'Nómina',
        categoryId: nomina,
        amountCents: 111719,
        dayOfMonth: 28,
        everyNMonths: 1,
        anchorYearMonth: '2026-08',
      );

      // Este dia (28 de agosto) ya paso de verdad hace tiempo en
      // cualquier caso real, asi que no lo bloquea la comprobacion de
      // "no adelantar movimientos futuros" -- lo comprobamos generando
      // el ciclo "septiembre" (que empieza justo ese dia).
      await repo.generateRecurringForMonth('2026-09');

      final movimientos = await repo.movementsFor('2026-09');
      expect(movimientos, hasLength(1));
      expect(movimientos.single.transaction.date, DateTime(2026, 8, 28));
    });

    test('volver a día 1 deshace el cambio (setMonthStartDay(null))', () async {
      await repo.setMonthStartDay(28);
      await repo.setMonthStartDay(null);
      expect((await repo.getAppSettings()).monthStartDay, isNull);

      final nomina = await categoryIdOf('Nómina');
      await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 28));
      expect(await repo.movementsFor('2026-08'), hasLength(1));
    });

    test(
        'con el día 28, no fabrica una nómina fantasma en el ciclo '
        '"agosto" (mes de calendario anterior al ancla de la plantilla)',
        () async {
      await repo.setMonthStartDay(28);
      final nomina = await categoryIdOf('Nómina');
      await repo.addRecurringTemplate(
        name: 'Nómina',
        categoryId: nomina,
        amountCents: 111719,
        dayOfMonth: 28,
        everyNMonths: 1,
        anchorYearMonth: '2026-08',
      );

      // El ciclo "2026-08" (con día de inicio 28) va del 28 de julio al
      // 27 de agosto. Antes del arreglo (bug del 01/09/2026, ver
      // resumen-proyecto.md), esto generaba una nómina fantasma fechada
      // el 28 de julio -- un cobro que nunca existió de verdad en la
      // app, porque la plantilla está anclada en agosto, no en julio.
      await repo.generateRecurringForMonth('2026-08');
      expect(await repo.movementsFor('2026-08'), isEmpty);

      // El ciclo real de la plantilla (septiembre) se sigue generando
      // exactamente igual que antes del arreglo.
      await repo.generateRecurringForMonth('2026-09');
      final septiembre = await repo.movementsFor('2026-09');
      expect(septiembre, hasLength(1));
      expect(septiembre.single.transaction.date, DateTime(2026, 8, 28));
    });

    test('un fantasma de ciclo ya generado antes del arreglo se retira solo',
        () async {
      final nomina = await categoryIdOf('Nómina');
      final tplId = await repo.addRecurringTemplate(
        name: 'Nómina',
        categoryId: nomina,
        amountCents: 111719,
        dayOfMonth: 28,
        everyNMonths: 1,
        anchorYearMonth: '2026-08',
      );

      // Simula el estado que habría dejado el bug: una nómina fantasma
      // fechada en julio (antes del mes ancla de la plantilla), enlazada
      // a la plantilla tal y como la habría creado
      // `generateRecurringForMonth` antes de este arreglo.
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              date: DateTime(2026, 7, 28),
              amountCents: 111719,
              categoryId: nomina,
              note: const Value('Nómina'),
              recurringTemplateId: Value(tplId),
            ),
          );
      await repo.setMonthStartDay(28);
      expect(await repo.movementsFor('2026-08'), hasLength(1));

      // Cualquier llamada la retira, aunque sea pidiendo un mes distinto
      // -- mismo patrón de autolimpieza que los adelantos de fecha.
      await repo.generateRecurringForMonth('2026-09');
      expect(await repo.movementsFor('2026-08'), isEmpty);

      final septiembre = await repo.movementsFor('2026-09');
      expect(septiembre, hasLength(1));
      expect(septiembre.single.transaction.date, DateTime(2026, 8, 28));
    });
  });

  group('resumen por categorias', () {
    test('agrupa y suma por categoria, de mayor a menor importe', () async {
      final comida = await categoryIdOf('Comida / Supermercado');
      final suscripciones = await categoryIdOf('Suscripciones');
      final nomina = await categoryIdOf('Nómina');

      await repo.addTransaction(categoryId: comida, amountCents: 15000, date: DateTime(2026, 8, 5));
      await repo.addTransaction(categoryId: comida, amountCents: 5000, date: DateTime(2026, 8, 12));
      await repo.addTransaction(
        categoryId: suscripciones, amountCents: 6000, date: DateTime(2026, 8, 2),
      );
      await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));

      final totals = await repo.categoryTotalsFor('2026-08');

      // Incluye tambien los ingresos -- separarlos de los gastos es cosa
      // de quien pinta la pantalla (`_CategorySummarySection`, mirando
      // `category.kind`), no de este metodo.
      expect(totals, hasLength(3));

      expect(totals[0].category.name, 'Nómina');
      expect(totals[0].totalCents, 111719);

      expect(totals[1].category.name, 'Comida / Supermercado');
      expect(totals[1].totalCents, 20000);
      expect(totals[1].count, 2);

      expect(totals[2].category.name, 'Suscripciones');
      expect(totals[2].totalCents, 6000);
      expect(totals[2].count, 1);
    });

    test('separa ingresos de gastos mirando category.kind', () async {
      final comida = await categoryIdOf('Comida / Supermercado');
      final nomina = await categoryIdOf('Nómina');
      await repo.addTransaction(categoryId: comida, amountCents: 2000, date: DateTime(2026, 8, 5));
      await repo.addTransaction(categoryId: nomina, amountCents: 111719, date: DateTime(2026, 8, 1));

      final totals = await repo.categoryTotalsFor('2026-08');
      final incomeNames =
          totals.where((t) => t.category.kind == CategoryKindDb.income).map((t) => t.category.name);
      final expenseNames =
          totals.where((t) => t.category.kind != CategoryKindDb.income).map((t) => t.category.name);

      expect(incomeNames, contains('Nómina'));
      expect(expenseNames, contains('Comida / Supermercado'));
      expect(expenseNames, isNot(contains('Nómina')));
    });

    test('una devolucion resta de su categoria en vez de aparecer aparte', () async {
      final comida = await categoryIdOf('Comida / Supermercado');
      final compraId = await repo.addTransaction(
        categoryId: comida, amountCents: 5000, date: DateTime(2026, 8, 5),
      );
      await repo.addRefund(
        originalTransactionId: compraId, amountCents: 2000, date: DateTime(2026, 8, 6),
      );

      final totals = await repo.categoryTotalsFor('2026-08');
      expect(totals, hasLength(1));
      expect(totals.single.totalCents, 3000);
      expect(totals.single.count, 2);
    });

    test('un mes sin gastos da una lista vacia', () async {
      expect(await repo.categoryTotalsFor('2026-08'), isEmpty);
    });

    group('comparativa entre meses (previousTotalCents)', () {
      test('una categoria que gasto mas que el mes anterior marca la diferencia en positivo', () async {
        final comida = await categoryIdOf('Comida / Supermercado');
        await repo.addTransaction(categoryId: comida, amountCents: 10000, date: DateTime(2026, 7, 10));
        await repo.addTransaction(categoryId: comida, amountCents: 15000, date: DateTime(2026, 8, 10));

        final totals = await repo.categoryTotalsFor('2026-08');
        final comidaTotal = totals.singleWhere((t) => t.category.name == 'Comida / Supermercado');

        expect(comidaTotal.totalCents, 15000);
        expect(comidaTotal.previousTotalCents, 10000);
      });

      test('una categoria que gasto menos que el mes anterior tambien se puede comparar', () async {
        final comida = await categoryIdOf('Comida / Supermercado');
        await repo.addTransaction(categoryId: comida, amountCents: 20000, date: DateTime(2026, 7, 10));
        await repo.addTransaction(categoryId: comida, amountCents: 5000, date: DateTime(2026, 8, 10));

        final totals = await repo.categoryTotalsFor('2026-08');
        final comidaTotal = totals.singleWhere((t) => t.category.name == 'Comida / Supermercado');

        expect(comidaTotal.totalCents, 5000);
        expect(comidaTotal.previousTotalCents, 20000);
      });

      test('una categoria sin ningun movimiento el mes anterior no tiene con que comparar', () async {
        final comida = await categoryIdOf('Comida / Supermercado');
        await repo.addTransaction(categoryId: comida, amountCents: 5000, date: DateTime(2026, 8, 10));

        final totals = await repo.categoryTotalsFor('2026-08');
        expect(totals.single.previousTotalCents, isNull);
      });

      test('con un ciclo de nomina a nomina, la comparativa mira el ciclo anterior, no el mes de calendario', () async {
        await repo.setMonthStartDay(28);
        final comida = await categoryIdOf('Comida / Supermercado');

        // Ciclo "2026-08" = 28 jul .. 27 ago. Ciclo "2026-07" = 28 jun .. 27 jul.
        await repo.addTransaction(categoryId: comida, amountCents: 8000, date: DateTime(2026, 7, 15));
        await repo.addTransaction(categoryId: comida, amountCents: 12000, date: DateTime(2026, 8, 1));

        final totals = await repo.categoryTotalsFor('2026-08');
        final comidaTotal = totals.singleWhere((t) => t.category.name == 'Comida / Supermercado');

        expect(comidaTotal.totalCents, 12000);
        expect(comidaTotal.previousTotalCents, 8000);
      });
    });
  });

  group('tutorial guiado (hasSeenTutorial)', () {
    test('por defecto no se ha visto el tutorial', () async {
      expect((await repo.getAppSettings()).hasSeenTutorial, isFalse);
    });

    test('se puede marcar como visto y se puede volver a resetear', () async {
      await repo.setHasSeenTutorial(true);
      expect((await repo.getAppSettings()).hasSeenTutorial, isTrue);

      await repo.setHasSeenTutorial(false);
      expect((await repo.getAppSettings()).hasSeenTutorial, isFalse);
    });
  });
}
