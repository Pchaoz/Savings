/// Conecta la base de datos real con el motor de calculo puro.
///
/// Regla de oro (doc 02): la base de datos SOLO guarda movimientos. Aqui es
/// donde se leen, se agrupan por mes y se le pasan al motor — nunca se
/// guarda un total. Cada vez que se pide un mes se recalcula la cadena
/// completa desde el primero; con SQLite en el telefono y unas pocas
/// docenas de meses esto tarda microsegundos (ver README original).
library;

import 'package:drift/drift.dart';

import '../core/pin_hash.dart';
import '../domain/engine/month_calculator.dart';
import '../domain/models/models.dart';
import 'database.dart';
import 'tables.dart';

/// Un movimiento listo para pintar: ya trae su categoria, y si es una
/// devolucion o si a el le han hecho una devolucion, el otro movimiento
/// enlazado (doc 08).
class MovementView {
  const MovementView({
    required this.transaction,
    required this.category,
    this.refundOf,
    this.refundedBy,
  });

  final TransactionRow transaction;
  final CategoryRow category;

  /// Si este movimiento ES una devolucion, la compra original.
  final TransactionRow? refundOf;

  /// Si a este movimiento LE HAN hecho una devolucion, esa devolucion.
  final TransactionRow? refundedBy;

  bool get isRefund => transaction.refundOfId != null;
  bool get hasBeenRefunded => refundedBy != null;
}

/// Cuanto se ha movido en una categoria un mes, para el resumen de
/// ingresos y gastos dentro de Evolución del ahorro (pedido por Pol el
/// 01/09/2026: "rollo 200€ en comida, 60€ en subscripciones", y despues
/// pidió tenerlo junto a la gráfica en vez de en un sitio aparte).
class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.totalCents,
    required this.count,
    this.previousTotalCents,
  });

  final CategoryRow category;

  /// Suma de los importes de esa categoria este mes, ya neta de
  /// devoluciones (una devolucion resta, porque se guarda en negativo,
  /// doc 08) -- el mismo numero que saldria de sumar a mano lo que se ve
  /// en Movimientos para esa categoria.
  final int totalCents;

  /// Cuantos movimientos de esa categoria entran en la suma (la
  /// devolucion cuenta como uno mas, si la hay).
  final int count;

  /// Lo mismo que [totalCents] pero del mes/ciclo anterior, para la
  /// comparativa entre meses. Null si esa categoria no tuvo ningun
  /// movimiento el mes anterior (no es lo mismo que "gasto 0" -- aqui no
  /// hay fila que sumar, asi que no mostramos diferencia).
  final int? previousTotalCents;
}

class SavingsRepository {
  SavingsRepository(this._db);

  final AppDatabase _db;

  Future<List<CategoryRow>> get categories =>
      (_db.select(_db.categories)..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .get();

  Future<List<QuickActionRow>> get quickActions =>
      (_db.select(_db.quickActions)..orderBy([(q) => OrderingTerm(expression: q.sortOrder)]))
          .get();

  /// Da de alta una categoria nueva (Ajustes > Categorias). No hay borrado
  /// aqui a proposito: una categoria puede tener movimientos historicos
  /// enlazados por `categoryId`, así que "esconderla" (columna `archived`,
  /// todavia sin UI) es mas seguro que borrarla de verdad.
  Future<int> addCategory({required String name, required CategoryKindDb kind}) async {
    final current = await categories;
    final nextSort = current.isEmpty
        ? 0
        : current.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: name,
            kind: kind,
            sortOrder: Value(nextSort),
          ),
        );
  }

  /// Oculta (o vuelve a mostrar) una categoria de los selectores de
  /// "nueva categoria" (Nuevo gasto, Accesos rapidos, Recurrentes...),
  /// sin tocar nada mas: el historico que ya la usa la sigue mostrando
  /// igual (`movementsFor` no filtra por esto) y el motor la sigue
  /// contando igual (agrupa por `kind`, nunca mira `archived`). Pensado
  /// para categorias que ya no usas pero que no quieres perder de las
  /// cuentas antiguas — por eso esto y no un borrado de verdad.
  Future<void> setCategoryArchived(int id, bool archived) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(archived: Value(archived)),
    );
  }

  /// Por que NO se puede borrar de verdad una categoria, si aplica algun
  /// motivo — null si se puede borrar sin problema. `deleteCategory` no
  /// comprueba nada por su cuenta: la UI llama primero a esto y solo deja
  /// pulsar "Borrar" cuando devuelve null, para no arriesgarse a dejar
  /// movimientos, accesos rapidos o recurrentes huerfanos (con un
  /// `categoryId` que ya no existe en ningun sitio).
  Future<String?> categoryDeleteBlockReason(int id) async {
    final all = await categories;
    final cat = all.firstWhere((c) => c.id == id);

    // Que nunca se pueda llegar a 0 categorias de un tipo: sin ninguna
    // "treat", por ejemplo, ya no habria donde apuntar un capricho
    // nuevo, y la bolsa de caprichos se quedaria sin ningun sitio al que
    // enlazar un gasto real.
    final sameKindCount = all.where((c) => c.kind == cat.kind).length;
    if (sameKindCount <= 1) {
      return 'Es la única categoría de este tipo — no puedes quedarte sin ninguna. '
          'Ocúltala en vez de borrarla si no la usas.';
    }

    final usedByTransactions =
        await (_db.select(_db.transactions)..where((t) => t.categoryId.equals(id))).get();
    if (usedByTransactions.isNotEmpty) {
      return 'Tiene movimientos guardados con ella — bórrala y perderías de qué '
          'categoría eran. Ocúltala en vez de borrarla para no perder ese histórico.';
    }

    final usedByQuickActions =
        await (_db.select(_db.quickActions)..where((q) => q.categoryId.equals(id))).get();
    if (usedByQuickActions.isNotEmpty) {
      return 'La usa un acceso rápido ("${usedByQuickActions.first.label}") — bórralo '
          'primero, o oculta la categoría en su lugar.';
    }

    final usedByRecurring =
        await (_db.select(_db.recurringTemplates)..where((r) => r.categoryId.equals(id))).get();
    if (usedByRecurring.isNotEmpty) {
      return 'La usa una plantilla recurrente ("${usedByRecurring.first.name}") — '
          'bórrala primero, o oculta la categoría en su lugar.';
    }

    return null;
  }

  /// Borrado real, sin papelera: solo se llama despues de comprobar
  /// `categoryDeleteBlockReason` (null), asi que nunca deja nada
  /// enlazado a un id que deja de existir.
  Future<void> deleteCategory(int id) {
    return (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  /// Inserta un movimiento normal (o una devolucion, si [amountCents] es
  /// negativo y se rellena [refundOfId]).
  Future<int> addTransaction({
    required int categoryId,
    required int amountCents,
    required DateTime date,
    String? note,
    int? refundOfId,
  }) {
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            date: date,
            amountCents: amountCents,
            categoryId: categoryId,
            note: Value(note),
            refundOfId: Value(refundOfId),
          ),
        );
  }

  /// Devolucion ligada al movimiento original (doc 08): mismo importe pero
  /// en negativo (asi el motor la resta en vez de sumarla), misma
  /// categoria, `refundOfId` apuntando al original.
  Future<int> addRefund({
    required int originalTransactionId,
    required int amountCents,
    required DateTime date,
  }) async {
    final original = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(originalTransactionId)))
        .getSingle();

    final refundAmount = -amountCents.abs();
    final refundNote = original.note == null ? null : '${original.note} (Devolución)';

    // Si el gasto original se pago con una hucha, la devolucion tiene que
    // volver a esa misma hucha, no aparecer como dinero "nuevo" de la
    // cuenta principal — por eso no basta con `addTransaction` a secas
    // aqui, igual que pasa con `addExpenseFromPocket`.
    final pocketId = original.paidFromPocketId;
    if (pocketId != null) {
      late int refundId;
      await _db.transaction(() async {
        refundId = await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                date: date,
                amountCents: refundAmount,
                categoryId: original.categoryId,
                note: Value(refundNote),
                refundOfId: Value(originalTransactionId),
                paidFromPocketId: Value(pocketId),
              ),
            );
        await _db.into(_db.pocketMovements).insert(
              PocketMovementsCompanion.insert(
                pocketId: pocketId,
                // Positivo: el dinero vuelve a la hucha (lo contrario del
                // signo que tuvo la retirada original).
                amountCents: -refundAmount,
                date: date,
                note: Value(refundNote ?? 'Devolución'),
                relatedTransactionId: Value(refundId),
              ),
            );
      });
      return refundId;
    }

    return addTransaction(
      categoryId: original.categoryId,
      // Negativo: es justo lo que hace que el motor lo trate como
      // devolucion (doc 08) y no como otro gasto mas de la misma categoria.
      amountCents: refundAmount,
      date: date,
      note: refundNote,
      refundOfId: originalTransactionId,
    );
  }

  /// Igual que `addTransaction`, pero el dinero sale de una hucha ya
  /// existente en vez de la "cuenta principal": registra el gasto con su
  /// categoria de siempre (para que salga bien clasificado en
  /// Movimientos) y, en la misma transaccion de Drift, retira ese mismo
  /// importe de la hucha elegida. Con `paidFromPocketId` puesto,
  /// `monthResult` ignora este movimiento por completo (ver mas abajo):
  /// el dinero ya habia salido de tu ahorro general el dia que lo
  /// metiste en la hucha, asi que gastarlo ahora no debe volver a restar
  /// de este mes ni de la bolsa de caprichos.
  Future<int> addExpenseFromPocket({
    required int categoryId,
    required int amountCents,
    required DateTime date,
    required int pocketId,
    String? note,
  }) async {
    late int transactionId;
    await _db.transaction(() async {
      transactionId = await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              date: date,
              amountCents: amountCents,
              categoryId: categoryId,
              note: Value(note),
              paidFromPocketId: Value(pocketId),
            ),
          );
      await _db.into(_db.pocketMovements).insert(
            PocketMovementsCompanion.insert(
              pocketId: pocketId,
              amountCents: -amountCents,
              date: date,
              note: Value(note),
              relatedTransactionId: Value(transactionId),
            ),
          );
    });
    return transactionId;
  }

  /// Edita importe/categoria/nota de un movimiento normal (doc 08: "si
  /// apuntaste mal el importe o la categoria, no elimines, edita"). La
  /// fecha NO se toca aqui a proposito — es la fecha en la que ocurrio de
  /// verdad, y cambiarla de sitio moveria el gasto a otro mes sin que esa
  /// fuera la intencion. Nunca se llama sobre una devolucion ni sobre un
  /// movimiento ya devuelto (la UI lo impide, ver movements_screen.dart).
  Future<void> updateTransaction({
    required int transactionId,
    required int categoryId,
    required int amountCents,
    String? note,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.transactions)..where((t) => t.id.equals(transactionId))).write(
        TransactionsCompanion(
          categoryId: Value(categoryId),
          amountCents: Value(amountCents),
          note: Value(note),
        ),
      );
      // Si este gasto se pago con una hucha, el movimiento de retirada
      // enlazado (`relatedTransactionId`) tiene que reflejar el importe
      // corregido, o el saldo de la hucha quedaria descuadrado con lo
      // que dice el gasto de verdad. No pasa nada si no hay ninguno
      // enlazado (gasto normal): el `where` no encuentra filas y esto no
      // hace nada.
      await (_db.update(_db.pocketMovements)
            ..where((m) => m.relatedTransactionId.equals(transactionId)))
          .write(PocketMovementsCompanion(amountCents: Value(-amountCents)));
    });
  }

  /// Borrado suave (doc 08): `deletedAt` + motivo. Los calculos siempre
  /// filtran por `deletedAt IS NULL`, asi que a partir de aqui el
  /// movimiento deja de contar sin desaparecer de verdad.
  Future<void> softDelete(int transactionId, {required String reason}) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(transactionId))).write(
      TransactionsCompanion(
        deletedAt: Value(DateTime.now()),
        deleteReason: Value(reason),
      ),
    );
  }

  Future<void> restore(int transactionId) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(transactionId))).write(
      const TransactionsCompanion(
        deletedAt: Value(null),
        deleteReason: Value(null),
      ),
    );
  }

  /// Calcula el resultado de [yearMonth] ("2026-08") recorriendo en
  /// cascada todos los meses anteriores que tengan movimientos o
  /// configuracion propia en `Months`.
  Future<MonthResult> monthResult(String yearMonth) async {
    final settings = await getAppSettings();
    final monthStartDay = settings.monthStartDay ?? 1;
    final defaultRate = settings.defaultTreatRate ?? kDefaultTreatRate;

    // `paidFromPocketId.isNull()`: un gasto pagado con una hucha no debe
    // entrar aqui — ese dinero ya salio de tu ahorro general el dia que
    // lo metiste en la hucha (ver el comentario de la columna en
    // `tables.dart`), asi que contarlo tambien aqui lo restaria dos
    // veces. Si sigue apareciendo en Movimientos: `movementsFor` no
    // filtra por esto a proposito, porque para el historial SÍ es un
    // gasto real que Pol quiere ver.
    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.deletedAt.isNull() & t.paidFromPocketId.isNull()))
        .join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
    ]).get();

    final byMonth = <String, List<TxInput>>{};
    for (final row in rows) {
      final tx = row.readTable(_db.transactions);
      final cat = row.readTable(_db.categories);
      final ym = yearMonthOf(tx.date, monthStartDay);
      (byMonth[ym] ??= []).add(
        TxInput(kind: _toDomainKind(cat.kind), amountCents: tx.amountCents),
      );
    }

    final monthConfigs = {
      for (final m in await _db.select(_db.months).get()) m.yearMonth: m,
    };

    final chain = <String>{...byMonth.keys, ...monthConfigs.keys, yearMonth}
        .where((ym) => ym.compareTo(yearMonth) <= 0)
        .toList()
      ..sort();

    var balance = 0;
    var bag = 0;
    var result = calculateMonth(
      openingBalanceCents: 0,
      bagOpeningCents: 0,
      transactions: const [],
    );

    for (final ym in chain) {
      final config = monthConfigs[ym];
      if (config?.openingBalanceCents != null) {
        balance = config!.openingBalanceCents!;
      }
      final rate = config?.treatRate ?? defaultRate;

      result = calculateMonth(
        openingBalanceCents: balance,
        bagOpeningCents: bag,
        transactions: byMonth[ym] ?? const [],
        treatRate: rate,
      );
      balance = result.closingBalanceCents;
      bag = result.bagClosingCents;
    }

    return result;
  }

  /// El primer mes ("2026-08") con actividad real: algun movimiento o una
  /// fila de configuracion en `Months` (por ejemplo, el mes en que se puso
  /// el saldo inicial). Null si la app esta completamente vacia todavia.
  /// Lo usa la grafica de evolucion del ahorro para no dibujar meses
  /// "fantasma" anteriores a que existiera ningun dato, que saldrian
  /// todos a saldo 0 y no dirian nada real.
  Future<String?> earliestActivityYearMonth() async {
    final monthStartDay = (await getAppSettings()).monthStartDay ?? 1;
    final txRows = await _db.select(_db.transactions).get();
    final monthRows = await _db.select(_db.months).get();

    final yearMonths = <String>{
      for (final tx in txRows) yearMonthOf(tx.date, monthStartDay),
      for (final m in monthRows) m.yearMonth,
    };
    if (yearMonths.isEmpty) return null;
    return (yearMonths.toList()..sort()).first;
  }

  /// Movimientos de [yearMonth] ("2026-08"), mas recientes primero, cada
  /// uno con su categoria y su devolucion enlazada (en cualquier sentido)
  /// si la tiene, aunque esa devolucion caiga en otro mes.
  Future<List<MovementView>> movementsFor(String yearMonth) async {
    final monthStartDay = (await getAppSettings()).monthStartDay ?? 1;
    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.deletedAt.isNull()))
        .join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
    ]).get();

    final all = [
      for (final row in rows)
        (row.readTable(_db.transactions), row.readTable(_db.categories)),
    ];

    final txById = {for (final (tx, _) in all) tx.id: tx};
    final refundByOriginalId = {
      for (final (tx, _) in all)
        if (tx.refundOfId != null) tx.refundOfId!: tx,
    };

    final inMonth = all.where((e) => yearMonthOf(e.$1.date, monthStartDay) == yearMonth).toList()
      ..sort((a, b) => b.$1.date.compareTo(a.$1.date));

    return [
      for (final (tx, cat) in inMonth)
        MovementView(
          transaction: tx,
          category: cat,
          refundOf: tx.refundOfId != null ? txById[tx.refundOfId] : null,
          refundedBy: refundByOriginalId[tx.id],
        ),
    ];
  }

  /// [movementsFor] agrupado por categoria y sumado, de mayor a menor
  /// importe -- "de donde sale el ahorro y a donde se va el gasto", para
  /// la sección de resumen de Evolución del ahorro. Incluye TODAS las
  /// categorias con algun movimiento ese mes, ingresos incluidos -- es la
  /// pantalla quien separa ingresos de gastos mirando `category.kind`,
  /// no este metodo. Una categoria sin ningun movimiento este mes ni
  /// siquiera aparece (no tiene sentido enseñar "Viajes: 0,00€" si no se
  /// ha tocado).
  Future<List<CategoryTotal>> categoryTotalsFor(String yearMonth) async {
    final movements = await movementsFor(yearMonth);

    final totalsById = <int, int>{};
    final countsById = <int, int>{};
    final categoryById = <int, CategoryRow>{};

    for (final m in movements) {
      final id = m.category.id;
      totalsById[id] = (totalsById[id] ?? 0) + m.transaction.amountCents;
      countsById[id] = (countsById[id] ?? 0) + 1;
      categoryById[id] = m.category;
    }

    // Comparativa entre meses: mismo agrupado pero para el mes/ciclo
    // anterior, solo para tener con que restar (no hace falta count ni
    // CategoryRow de ese lado).
    final previousMovements = await movementsFor(_shiftYearMonth(yearMonth, -1));
    final previousTotalsById = <int, int>{};
    for (final m in previousMovements) {
      final id = m.category.id;
      previousTotalsById[id] = (previousTotalsById[id] ?? 0) + m.transaction.amountCents;
    }

    final result = [
      for (final id in totalsById.keys)
        CategoryTotal(
          category: categoryById[id]!,
          totalCents: totalsById[id]!,
          count: countsById[id]!,
          previousTotalCents: previousTotalsById[id],
        ),
    ]..sort((a, b) => b.totalCents.compareTo(a.totalCents));

    return result;
  }

  /// Movimientos borrados hace menos de 30 dias, mas recientes primero
  /// (Ajustes > Papelera, doc 08). Llamar a [purgeExpiredTrash] antes
  /// para que la lista no incluya nada que ya deberia haberse purgado.
  Future<List<MovementView>> trashed() async {
    final rows = await (_db.select(_db.transactions)..where((t) => t.deletedAt.isNotNull()))
        .join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
    ]).get();

    final entries = [
      for (final row in rows)
        (row.readTable(_db.transactions), row.readTable(_db.categories)),
    ]..sort((a, b) => b.$1.deletedAt!.compareTo(a.$1.deletedAt!));

    return [
      for (final (tx, cat) in entries) MovementView(transaction: tx, category: cat),
    ];
  }

  /// Purga de verdad (hard delete, doc 08: "pasados 30 dias se purga de
  /// verdad") lo que lleva en la papelera mas de 30 dias.
  ///
  /// Seguro de borrar sin romper enlaces: la UI nunca deja borrar una
  /// devolucion ni un movimiento que ya tiene una devolucion (ver
  /// movements_screen.dart), asi que lo que llega aqui nunca esta
  /// referenciado por el `refundOfId` de otro movimiento.
  Future<void> purgeExpiredTrash() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final rows = await (_db.select(_db.transactions)..where((t) => t.deletedAt.isNotNull())).get();
    final expiredIds = [
      for (final tx in rows)
        if (tx.deletedAt!.isBefore(cutoff)) tx.id,
    ];
    if (expiredIds.isEmpty) return;
    await (_db.delete(_db.transactions)..where((t) => t.id.isIn(expiredIds))).go();
  }

  /// Anade un acceso rapido nuevo, al final de la lista (Ajustes >
  /// Accesos rapidos, Fase 3.6). No toca movimientos ni la papelera: es
  /// solo una plantilla para apuntar mas rapido.
  Future<int> addQuickAction({
    required String label,
    required int amountCents,
    required int categoryId,
  }) async {
    final current = await quickActions;
    final nextSort = current.isEmpty
        ? 0
        : current.map((q) => q.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    return _db.into(_db.quickActions).insert(
          QuickActionsCompanion.insert(
            label: label,
            amountCents: amountCents,
            categoryId: categoryId,
            sortOrder: Value(nextSort),
          ),
        );
  }

  /// Borra un acceso rapido de verdad (no hay papelera para estos: no son
  /// movimientos de dinero, son solo plantillas).
  Future<void> deleteQuickAction(int id) {
    return (_db.delete(_db.quickActions)..where((q) => q.id.equals(id))).go();
  }

  Future<List<RecurringRow>> get recurringTemplates =>
      (_db.select(_db.recurringTemplates)
            ..orderBy([(r) => OrderingTerm(expression: r.dayOfMonth)]))
          .get();

  /// Da de alta un gasto/ingreso que se repite (doc 04: "que la nomina y
  /// las suscripciones se metan solas cada mes"). [anchorYearMonth] es el
  /// mes desde el que empieza a contar el ciclo de [everyNMonths] —
  /// normalmente el mes actual, para que empiece a generarse ya.
  Future<int> addRecurringTemplate({
    required String name,
    required int categoryId,
    required int amountCents,
    required int dayOfMonth,
    required int everyNMonths,
    required String anchorYearMonth,
  }) {
    return _db.into(_db.recurringTemplates).insert(
          RecurringTemplatesCompanion.insert(
            categoryId: categoryId,
            name: name,
            amountCents: amountCents,
            dayOfMonth: dayOfMonth,
            everyNMonths: Value(everyNMonths),
            anchorYearMonth: anchorYearMonth,
          ),
        );
  }

  /// Borrado real: una plantilla no es un movimiento de dinero, no hace
  /// falta papelera. Los movimientos que ya genero se quedan tal cual
  /// (guardan su propia copia del importe/categoria/nota), asi que borrar
  /// la plantilla no reescribe el historico.
  Future<void> deleteRecurringTemplate(int id) {
    return (_db.delete(_db.recurringTemplates)..where((r) => r.id.equals(id))).go();
  }

  /// Genera los movimientos de las plantillas activas que tocan
  /// [yearMonth], si todavia no se han generado. Mismo patron perezoso que
  /// `purgeExpiredTrash`: se llama cada vez que se pide el mes (ver
  /// `providers.dart`), no hay tarea en segundo plano ni cron.
  ///
  /// **Bug corregido el 01/09/2026**: antes esto generaba el mes entero
  /// de golpe la primera vez que se abria, sin mirar que dia era de
  /// verdad -- si la nomina esta puesta al dia 28 y hoy es 1, se creaba
  /// igual un movimiento fechado el 28, y "Ahorro total" en Inicio
  /// contaba ya ese dinero como tuyo, aunque en la vida real todavia no
  /// hubiera llegado (a Pol le llego a sobrar mas de 1.000 € de saldo
  /// que no tenia). Ahora nunca se adelanta un movimiento a un dia que
  /// todavia no ha llegado, y si ya habia alguno adelantado de antes de
  /// este arreglo, se retira solo la primera vez que se llama a esto —
  /// sin papelera, porque nunca fue un movimiento real — y se vuelve a
  /// generar solo, sin que nadie tenga que hacer nada, el dia que de
  /// verdad toque.
  Future<void> generateRecurringForMonth(String yearMonth) async {
    // Envuelto en una transaccion a proposito: Inicio y Movimientos
    // pueden pedir el mismo mes al mismo tiempo (dos providers distintos
    // observados a la vez), y sin esto los dos leerian "todavia no
    // generado" antes de que ninguno hubiera insertado nada, duplicando
    // el movimiento la primera vez que tocaba generarse. Una transaccion
    // de Drift pone en cola cualquier otra que llegue mientras tanto, asi
    // que la segunda llamada ya ve el movimiento que acaba de insertar la
    // primera.
    await _db.transaction(() async {
      final monthStartDay = (await getAppSettings()).monthStartDay ?? 1;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final generated = await (_db.select(_db.transactions)
            ..where((t) => t.recurringTemplateId.isNotNull()))
          .get();

      // Todas las plantillas (activas o no) hacen falta para poder saber
      // el `anchorYearMonth` de cualquier movimiento ya generado, aunque
      // su plantilla se haya desactivado despues -- ver el fantasma de
      // ciclo mas abajo.
      final allTemplates = await _db.select(_db.recurringTemplates).get();
      final anchorIndexById = {
        for (final t in allTemplates) t.id: _monthIndex(t.anchorYearMonth),
      };

      final prematureIds = <int>{
        for (final tx in generated)
          if (tx.date.isAfter(today)) tx.id,
      };

      // Autolimpieza de "fantasmas de ciclo" (bug encontrado el
      // 01/09/2026, ver `resumen-proyecto.md`): con `monthStartDay`
      // distinto de 1, el primer ciclo en que una plantilla toca puede
      // calcular su dia en un mes de calendario ANTERIOR al mes en que
      // Pol dijo que esa plantilla empezaba (`anchorYearMonth`) -- p. ej.
      // una nomina anclada en agosto con dia de cobro 28 igual al
      // `monthStartDay`: al mirar el ciclo "agosto" (ahora del 28 de
      // julio al 27 de agosto) el 28 de julio es una fecha valida dentro
      // de ese ciclo y ya ha pasado, asi que se generaria... aunque esa
      // nomina de julio nunca existio de verdad en la app (Pol empezo a
      // usarla en agosto). Cualquier movimiento generado fechado en un
      // mes de calendario anterior al ancla de su propia plantilla es
      // justo eso, un fantasma de este tipo -- se retira igual que un
      // adelantado, sin papelera (nunca fue un movimiento real).
      final ghostIds = <int>{
        for (final tx in generated)
          if (!prematureIds.contains(tx.id))
            if (anchorIndexById[tx.recurringTemplateId] != null &&
                tx.date.year * 12 + tx.date.month < anchorIndexById[tx.recurringTemplateId]!)
              tx.id,
      };

      final toRetract = {...prematureIds, ...ghostIds};
      if (toRetract.isNotEmpty) {
        await (_db.delete(_db.transactions)..where((t) => t.id.isIn(toRetract))).go();
      }

      final templates = allTemplates.where((t) => t.active).toList();
      if (templates.isEmpty) return;

      final generatedIds = {
        for (final tx in generated)
          if (!toRetract.contains(tx.id) && yearMonthOf(tx.date, monthStartDay) == yearMonth)
            tx.recurringTemplateId!,
      };

      // Con `monthStartDay` distinto de 1, este "mes" es un ciclo que
      // casi siempre pisa dos meses de calendario (ver comentario de
      // `_cycleRangeFor`) -- para cada plantilla probamos su dia en los
      // dos meses candidatos y nos quedamos con el que de verdad caiga
      // dentro del ciclo, sin aceptar nunca un candidato anterior al mes
      // ancla de la plantilla (el mismo limite que evita el fantasma de
      // ciclo de arriba, aplicado tambien antes de generar, no solo al
      // limpiar lo ya generado).
      final (cycleStart, cycleEnd) = _cycleRangeFor(yearMonth, monthStartDay);
      final cycleEndInclusive = cycleEnd.subtract(const Duration(days: 1));
      final candidateMonths = <(int, int)>{
        (cycleStart.year, cycleStart.month),
        (cycleEndInclusive.year, cycleEndInclusive.month),
      };

      for (final tpl in templates) {
        if (generatedIds.contains(tpl.id)) continue;
        if (!_isRecurringDue(tpl, yearMonth)) continue;

        final anchorIndex = anchorIndexById[tpl.id]!;
        DateTime? date;
        for (final (y, m) in candidateMonths) {
          if (y * 12 + m < anchorIndex) continue;
          final candidate = DateTime(y, m, tpl.dayOfMonth);
          if (!candidate.isBefore(cycleStart) && candidate.isBefore(cycleEnd)) {
            date = candidate;
            break;
          }
        }
        if (date == null) continue;
        if (date.isAfter(today)) continue;

        await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                date: date,
                amountCents: tpl.amountCents,
                categoryId: tpl.categoryId,
                note: Value(tpl.name),
                recurringTemplateId: Value(tpl.id),
              ),
            );
      }
    });
  }

  /// [tpl] toca en [yearMonth] si no es antes de su mes ancla y si ha
  /// pasado un numero entero de ciclos de [RecurringRow.everyNMonths]
  /// (ej. T-Jove: ancla agosto, cada 3 meses -> toca en agosto, noviembre...).
  bool _isRecurringDue(RecurringRow tpl, String yearMonth) {
    final diff = _monthIndex(yearMonth) - _monthIndex(tpl.anchorYearMonth);
    return diff >= 0 && diff % tpl.everyNMonths == 0;
  }

  /// "2026-08" -> un entero que crece de mes en mes (año*12+mes), para
  /// poder comparar/restar meses de calendario sin tener que parsear la
  /// cadena cada vez. Usado tanto para decidir si una plantilla toca
  /// ([_isRecurringDue] / [_isPocketRecurringDue]) como para el limite
  /// de "no generar antes del mes ancla" (ver el fantasma de ciclo en
  /// [generateRecurringForMonth] / [generatePocketRecurringForMonth]).
  static int _monthIndex(String yearMonth) {
    final p = yearMonth.split('-');
    return int.parse(p[0]) * 12 + int.parse(p[1]);
  }

  /// "2026-08" con deltaMonths=-1 -> "2026-07" (y cruza de año si hace
  /// falta). Mismo desplazamiento de etiqueta que usa
  /// `selectedYearMonthProvider`/`savingsHistoryProvider` en providers.dart
  /// (no se puede importar esa version porque es privada de esa libreria),
  /// usado aqui para saber cual es "el mes/ciclo anterior" al comparar
  /// categorias.
  static String _shiftYearMonth(String yearMonth, int deltaMonths) {
    final parts = yearMonth.split('-');
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

  /// Saldo inicial guardado para [yearMonth] (la semilla de la cadena de
  /// calculo, doc 03), o null si ese mes no tiene uno propio configurado.
  Future<int?> openingBalanceFor(String yearMonth) async {
    final row = await (_db.select(_db.months)
          ..where((m) => m.yearMonth.equals(yearMonth)))
        .getSingleOrNull();
    return row?.openingBalanceCents;
  }

  /// Fija (o corrige) el saldo inicial de [yearMonth] — normalmente el
  /// primer mes que se usa la app de verdad. `insertOnConflictUpdate`
  /// porque `yearMonth` es la clave primaria de `Months`: crea la fila si
  /// no existia, o solo actualiza el saldo si ya existia (por ejemplo, con
  /// un `treatRate` propio ya puesto).
  Future<void> setOpeningBalance({required String yearMonth, required int cents}) {
    return _db.into(_db.months).insertOnConflictUpdate(
          MonthsCompanion.insert(
            yearMonth: yearMonth,
            openingBalanceCents: Value(cents),
          ),
        );
  }

  // ---------------------------------------------------------------------
  // Huchas de ahorro (bolsas de ahorro con nombre y meta opcional).
  //
  // A proposito viven en su propio mundo, sin tocar `Transactions` ni el
  // motor de calculo: meter dinero en una hucha no es un gasto, el dinero
  // sigue siendo tuyo. Por eso `monthResult` no sabe nada de esto — las
  // huchas se leen y se suman aparte, tanto para su propia pantalla como
  // para el desglose de Inicio.
  // ---------------------------------------------------------------------

  Future<List<PocketRow>> get pockets => (_db.select(_db.savingsPockets)
        ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
      .get();

  /// Da de alta una hucha nueva. Sin borrado a proposito, igual que las
  /// categorias: puede tener movimientos historicos enlazados.
  Future<int> addPocket({required String name, int? targetCents}) async {
    final current = await pockets;
    final nextSort = current.isEmpty
        ? 0
        : current.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    return _db.into(_db.savingsPockets).insert(
          SavingsPocketsCompanion.insert(
            name: name,
            targetCents: Value(targetCents),
            sortOrder: Value(nextSort),
          ),
        );
  }

  /// Elimina una hucha entera: su historial de movimientos y sus
  /// aportaciones automaticas. El dinero NO se mueve a ningun sitio,
  /// porque nunca salio de verdad de `Transactions` / del ahorro real —
  /// las huchas son solo una etiqueta por encima (ver comentario de mas
  /// arriba). Al borrar la hucha, ese dinero simplemente deja de estar
  /// apartado; si "Ahorro total incluye huchas" estaba desactivado, ese
  /// importe pasa a contar de nuevo como disponible en Inicio.
  Future<void> deletePocket(int id) async {
    await (_db.delete(_db.pocketMovements)..where((m) => m.pocketId.equals(id))).go();
    await (_db.delete(_db.pocketRecurringTemplates)..where((r) => r.pocketId.equals(id))).go();
    await (_db.delete(_db.savingsPockets)..where((p) => p.id.equals(id))).go();
  }

  /// Un movimiento de hucha generado por pagar un gasto (`relatedTransactionId`
  /// puesto) deja de contar si ese gasto se ha borrado (`deletedAt`) —
  /// sin esto, borrar (con Deshacer) un gasto pagado con una hucha
  /// dejaria su saldo descuadrado para siempre. Un movimiento normal
  /// (meter/sacar a mano, aportacion automatica) no tiene
  /// `relatedTransactionId`, asi que este `LEFT JOIN` no le afecta.
  /// Movimientos de hucha "en bruto", con su gasto enlazado si lo tiene
  /// (`relatedTransactionId`) para poder saber si ese gasto se ha
  /// borrado. `pocketId` null = de todas las huchas (para `pocketBalances`).
  Future<List<(PocketMovementRow, TransactionRow?)>> _rawPocketMovements({int? pocketId}) async {
    final select = _db.select(_db.pocketMovements);
    if (pocketId != null) {
      select.where((m) => m.pocketId.equals(pocketId));
    }
    final rows = await select.join([
      leftOuterJoin(
        _db.transactions,
        _db.transactions.id.equalsExp(_db.pocketMovements.relatedTransactionId),
      ),
    ]).get();

    return [
      for (final row in rows)
        (row.readTable(_db.pocketMovements), row.readTableOrNull(_db.transactions)),
    ];
  }

  /// Un movimiento de hucha generado por pagar un gasto
  /// (`relatedTransactionId` puesto) deja de contar si ese gasto se ha
  /// borrado (`deletedAt`) — sin esto, borrar (con Deshacer) un gasto
  /// pagado con una hucha dejaria su saldo descuadrado para siempre. Un
  /// movimiento normal (meter/sacar a mano, aportacion automatica) no
  /// tiene `relatedTransactionId`, asi que esto no le afecta.
  bool _pocketMovementCounts(PocketMovementRow movement, TransactionRow? linkedTx) {
    if (movement.relatedTransactionId == null) return true;
    return linkedTx != null && linkedTx.deletedAt == null;
  }

  /// Saldo de cada hucha (suma de sus movimientos), indexado por
  /// `pocketId`. Una hucha sin movimientos todavia no sale en el mapa —
  /// tratarla como 0 en ese caso.
  Future<Map<int, int>> pocketBalances() async {
    final rows = await _rawPocketMovements();
    final totals = <int, int>{};
    for (final (movement, linkedTx) in rows) {
      if (!_pocketMovementCounts(movement, linkedTx)) continue;
      totals[movement.pocketId] = (totals[movement.pocketId] ?? 0) + movement.amountCents;
    }
    return totals;
  }

  /// Movimientos de una hucha, mas recientes primero (para su pantalla de
  /// detalle).
  Future<List<PocketMovementRow>> movementsForPocket(int pocketId) async {
    final rows = await _rawPocketMovements(pocketId: pocketId);
    final visible = [
      for (final (movement, linkedTx) in rows)
        if (_pocketMovementCounts(movement, linkedTx)) movement,
    ];
    return visible..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Mueve dinero a mano dentro de una hucha (Ajustar saldo de huchas):
  /// [amountCents] positivo = metes dinero, negativo = sacas.
  Future<int> addPocketMovement({
    required int pocketId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) {
    return _db.into(_db.pocketMovements).insert(
          PocketMovementsCompanion.insert(
            pocketId: pocketId,
            amountCents: amountCents,
            date: date,
            note: Value(note),
          ),
        );
  }

  /// Corrige un movimiento de hucha equivocado. Borrado real: no es un
  /// gasto de verdad, no hace falta papelera.
  Future<void> deletePocketMovement(int id) {
    return (_db.delete(_db.pocketMovements)..where((m) => m.id.equals(id))).go();
  }

  Future<List<PocketRecurringRow>> get pocketRecurringTemplates =>
      (_db.select(_db.pocketRecurringTemplates)
            ..orderBy([(r) => OrderingTerm(expression: r.dayOfMonth)]))
          .get();

  /// Aportacion automatica mensual a una hucha — mismo patron que
  /// `addRecurringTemplate`, pero sin categoria: el dinero no se gasta,
  /// se mueve de tu ahorro general a la hucha.
  Future<int> addPocketRecurringTemplate({
    required int pocketId,
    required String name,
    required int amountCents,
    required int dayOfMonth,
    required int everyNMonths,
    required String anchorYearMonth,
  }) {
    return _db.into(_db.pocketRecurringTemplates).insert(
          PocketRecurringTemplatesCompanion.insert(
            pocketId: pocketId,
            name: name,
            amountCents: amountCents,
            dayOfMonth: dayOfMonth,
            everyNMonths: Value(everyNMonths),
            anchorYearMonth: anchorYearMonth,
          ),
        );
  }

  Future<void> deletePocketRecurringTemplate(int id) {
    return (_db.delete(_db.pocketRecurringTemplates)..where((r) => r.id.equals(id))).go();
  }

  /// Genera los movimientos de hucha de las aportaciones automaticas que
  /// tocan [yearMonth], si todavia no se han generado. Copia exacta del
  /// patron perezoso de `generateRecurringForMonth`, pero escribiendo en
  /// `PocketMovements` en vez de en `Transactions` -- incluida la misma
  /// correccion del 01/09/2026: nunca se adelanta una aportacion a un dia
  /// que todavia no ha llegado, y cualquier adelanto de antes del arreglo
  /// se retira solo (sin papelera) para generarse de nuevo el dia que
  /// toque de verdad.
  Future<void> generatePocketRecurringForMonth(String yearMonth) async {
    // Misma transaccion protectora que `generateRecurringForMonth`, y por
    // el mismo motivo: `pocket_detail_screen.dart` observa a la vez
    // `pocketBalancesProvider` y `pocketMovementsProvider(pocketId)`, y
    // los dos llaman a esto para el mismo mes -- sin la transaccion,
    // ambas llamadas pueden leer "todavia no generado" antes de que
    // ninguna haya insertado nada, y la aportacion automatica se duplica
    // la primera vez que toca generarse ese mes.
    await _db.transaction(() async {
      final monthStartDay = (await getAppSettings()).monthStartDay ?? 1;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final generated = await (_db.select(_db.pocketMovements)
            ..where((m) => m.recurringPocketTemplateId.isNotNull()))
          .get();

      final allTemplates = await _db.select(_db.pocketRecurringTemplates).get();
      final anchorIndexById = {
        for (final t in allTemplates) t.id: _monthIndex(t.anchorYearMonth),
      };

      final prematureIds = <int>{
        for (final m in generated)
          if (m.date.isAfter(today)) m.id,
      };

      // Mismo fantasma de ciclo que `generateRecurringForMonth` (ver el
      // comentario detallado ahi) aplicado a aportaciones automaticas a
      // huchas: se retira cualquier movimiento generado fechado en un
      // mes de calendario anterior al ancla de su propia plantilla.
      final ghostIds = <int>{
        for (final m in generated)
          if (!prematureIds.contains(m.id))
            if (anchorIndexById[m.recurringPocketTemplateId] != null &&
                m.date.year * 12 + m.date.month <
                    anchorIndexById[m.recurringPocketTemplateId]!)
              m.id,
      };

      final toRetract = {...prematureIds, ...ghostIds};
      if (toRetract.isNotEmpty) {
        await (_db.delete(_db.pocketMovements)..where((m) => m.id.isIn(toRetract))).go();
      }

      final templates = allTemplates.where((t) => t.active).toList();
      if (templates.isEmpty) return;

      final generatedIds = {
        for (final m in generated)
          if (!toRetract.contains(m.id) && yearMonthOf(m.date, monthStartDay) == yearMonth)
            m.recurringPocketTemplateId!,
      };

      final (cycleStart, cycleEnd) = _cycleRangeFor(yearMonth, monthStartDay);
      final cycleEndInclusive = cycleEnd.subtract(const Duration(days: 1));
      final candidateMonths = <(int, int)>{
        (cycleStart.year, cycleStart.month),
        (cycleEndInclusive.year, cycleEndInclusive.month),
      };

      for (final tpl in templates) {
        if (generatedIds.contains(tpl.id)) continue;
        if (!_isPocketRecurringDue(tpl, yearMonth)) continue;

        final anchorIndex = anchorIndexById[tpl.id]!;
        DateTime? date;
        for (final (y, m) in candidateMonths) {
          if (y * 12 + m < anchorIndex) continue;
          final candidate = DateTime(y, m, tpl.dayOfMonth);
          if (!candidate.isBefore(cycleStart) && candidate.isBefore(cycleEnd)) {
            date = candidate;
            break;
          }
        }
        if (date == null) continue;
        if (date.isAfter(today)) continue;

        await _db.into(_db.pocketMovements).insert(
              PocketMovementsCompanion.insert(
                pocketId: tpl.pocketId,
                amountCents: tpl.amountCents,
                date: date,
                note: Value(tpl.name),
                recurringPocketTemplateId: Value(tpl.id),
              ),
            );
      }
    });
  }

  bool _isPocketRecurringDue(PocketRecurringRow tpl, String yearMonth) {
    final diff = _monthIndex(yearMonth) - _monthIndex(tpl.anchorYearMonth);
    return diff >= 0 && diff % tpl.everyNMonths == 0;
  }

  // ---------------------------------------------------------------------
  // Copia de seguridad.
  // ---------------------------------------------------------------------

  /// Vuelca una copia completa y consistente de la base de datos en
  /// [destinationPath], usando `VACUUM INTO` de sqlite3 — la forma segura
  /// de copiar una base de datos que sigue abierta (a diferencia de copiar
  /// el fichero .sqlite a pelo, esto nunca deja una copia a medio
  /// escribir). `destinationPath` no puede apuntar a un fichero que ya
  /// existe: sqlite3 lo rechaza a proposito para no sobrescribir nada por
  /// error.
  Future<void> backupDatabaseTo(String destinationPath) async {
    final escaped = destinationPath.replaceAll("'", "''");
    await _db.customStatement("VACUUM INTO '$escaped';");
  }

  // ---------------------------------------------------------------------
  // Ajustes globales (fila unica en `AppSettings`, id == 0).
  // ---------------------------------------------------------------------

  /// La fila de configuracion global. Siempre existe: la crea la
  /// migracion (v5) o el `onCreate` en instalaciones nuevas, pero por si
  /// acaso se defiende sembrandola aqui tambien.
  Future<AppSettingsRow> getAppSettings() async {
    final existing = await (_db.select(_db.appSettings)..where((s) => s.id.equals(0)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await _db.into(_db.appSettings).insert(AppSettingsCompanion.insert(id: Value(0)));
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(0))).getSingle();
  }

  /// Cambia el margen de caprichos por defecto (Ajustes > Margen de
  /// caprichos). `null` vuelve al 10 % de fabrica.
  Future<void> setDefaultTreatRate(double? rate) async {
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      AppSettingsCompanion(defaultTreatRate: Value(rate)),
    );
  }

  /// Si "Ahorro total" en Inicio incluye o no lo que llevas en huchas.
  Future<void> setShowPocketsInTotal(bool value) async {
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      AppSettingsCompanion(showPocketsInTotal: Value(value)),
    );
  }

  /// Tutorial guiado de Inicio (bolsa de caprichos + como apuntar un
  /// gasto). `true` tanto al terminarlo como al saltarlo; "Ajustes >
  /// Repetir tutorial" lo vuelve a poner en `false`.
  Future<void> setHasSeenTutorial(bool value) async {
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      AppSettingsCompanion(hasSeenTutorial: Value(value)),
    );
  }

  /// Día 1-28 en el que "empieza el mes" (Ajustes > Personalización >
  /// "Mes de nómina a nómina"). `null` vuelve al calendario normal (día
  /// 1). Este cambio se aplica retroactivamente a todo el historial de
  /// una vez -- no hay ningún "a partir de esta fecha" que recordar: es
  /// la misma cuenta de siempre (`yearMonthOf`/`monthResult`), solo que
  /// con el día de corte nuevo, así que un movimiento viejo puede pasar a
  /// agruparse en un mes distinto al que se vio la primera vez.
  Future<void> setMonthStartDay(int? day) async {
    assert(day == null || (day >= 1 && day <= 28));
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      AppSettingsCompanion(monthStartDay: Value(day)),
    );
  }

  /// Activa el bloqueo de la app con un PIN nuevo, o lo cambia si ya
  /// había uno (Ajustes > Bloqueo de la app, pedido por Pol el
  /// 21/09/2026). El PIN se guarda solo como hash + sal aleatoria, nunca
  /// en claro (ver `core/pin_hash.dart`).
  Future<void> setAppLockPin(String pin) async {
    await getAppSettings();
    final salt = generatePinSalt();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      AppSettingsCompanion(
        appLockEnabled: const Value(true),
        appLockPinHash: Value(hashPin(pin, salt)),
        appLockPinSalt: Value(salt),
      ),
    );
  }

  /// Desactiva el bloqueo y olvida el PIN guardado.
  Future<void> disableAppLock() async {
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      const AppSettingsCompanion(
        appLockEnabled: Value(false),
        appLockPinHash: Value(null),
        appLockPinSalt: Value(null),
      ),
    );
  }

  /// Comprueba un PIN introducido contra el hash guardado. `false` si el
  /// bloqueo no está activado o todavía no hay ningún PIN guardado.
  Future<bool> verifyAppLockPin(String pin) async {
    final settings = await getAppSettings();
    final hash = settings.appLockPinHash;
    final salt = settings.appLockPinSalt;
    if (hash == null || salt == null) return false;
    return hashPin(pin, salt) == hash;
  }

  // ---------------------------------------------------------------------
  // Sobrante de caprichos -> hucha (aviso al cambiar de mes, Inicio).
  // ---------------------------------------------------------------------

  /// La categoria "Capricho" (tipo `treat`) ya sembrada de fabrica, para
  /// registrar el movimiento de "mover el sobrante a una hucha" bajo el
  /// mismo cubo que cualquier otro capricho (asi resta de la bolsa
  /// exactamente igual que un capricho normal, sin tocar el motor).
  /// Si el usuario ha creado alguna categoria de tipo `treat` adicional
  /// desde Ajustes > Categorias, coge la primera -- solo hace falta
  /// alguna, no importa cual exactamente.
  Future<CategoryRow> treatCategory() async {
    final rows = await _db.select(_db.categories).get();
    return rows.firstWhere((c) => c.kind == CategoryKindDb.treat);
  }

  /// Mueve [amountCents] de la bolsa de caprichos a la hucha [pocketId]:
  /// un movimiento de capricho normal (para que reste de la bolsa, igual
  /// que gastarlo de verdad) mas un ingreso a la hucha por el mismo
  /// importe. Las dos escrituras van en una transaccion para que nunca
  /// quede a medias. Tambien marca el aviso como contestado este mes,
  /// para que Inicio no lo vuelva a preguntar.
  Future<void> sweepTreatBagToPocket({
    required int pocketId,
    required int amountCents,
    required String pocketName,
  }) async {
    await _db.transaction(() async {
      final category = await treatCategory();
      final now = DateTime.now();

      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              date: now,
              amountCents: amountCents,
              categoryId: category.id,
              note: Value('Trasladado a hucha: $pocketName'),
            ),
          );

      await _db.into(_db.pocketMovements).insert(
            PocketMovementsCompanion.insert(
              pocketId: pocketId,
              amountCents: amountCents,
              date: now,
              note: const Value('Sobrante de caprichos del mes anterior'),
            ),
          );

      final monthStartDay = (await getAppSettings()).monthStartDay ?? 1;
      await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
        AppSettingsCompanion(dismissedTreatSweepYearMonth: Value(yearMonthOf(now, monthStartDay))),
      );
    });
  }

  /// "No, gracias, que se siga acumulando este mes" -- solo marca el
  /// aviso como contestado, sin mover nada de dinero.
  Future<void> dismissTreatSweepPrompt(String yearMonth) async {
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      AppSettingsCompanion(dismissedTreatSweepYearMonth: Value(yearMonth)),
    );
  }

  /// Olvida que ya se contesto el aviso de sobrante, para que
  /// `pendingTreatSweepProvider` lo vuelva a ofrecer la proxima vez que
  /// haya algo que mover (Ajustes > Personalizacion). Hace falta este
  /// botón porque adelantar la fecha del telefono para probar el aviso
  /// (como se sugeria en las notas de esta misma funcion) lo deja
  /// "contestado" de verdad para ese mes, aunque solo fuera una prueba --
  /// sin esto, no habria forma de volver a verlo sin borrar datos.
  Future<void> resetTreatSweepPrompt() async {
    await getAppSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(0))).write(
      const AppSettingsCompanion(dismissedTreatSweepYearMonth: Value(null)),
    );
  }

  /// A que "mes" pertenece [date], segun [monthStartDay] (Ajustes >
  /// Personalización > "Mes de nómina a nómina", `AppSettings.monthStartDay`,
  /// 1 = calendario normal). El ciclo se etiqueta por el mes en el que
  /// termina: con `monthStartDay = 28`, el 28 de agosto ya es
  /// "2026-09" (empieza el ciclo que llamamos septiembre), y el 27 de
  /// septiembre todavia es "2026-09" (el ultimo dia de ese mismo ciclo).
  /// Con `monthStartDay = 1` (el de toda la vida) esto da exactamente el
  /// mes de calendario de siempre.
  ///
  /// Publico (sin `_`) a proposito: `providers.dart` necesita la misma
  /// cuenta para saber "que mes es hoy" fuera del repositorio (flechas de
  /// mes, aviso de sobrante...), y reimplementarla ahi aparte solo
  /// invitaria a que las dos copias acabaran diciendo cosas distintas.
  static String yearMonthOf(DateTime date, int monthStartDay) {
    final cycleStart = date.day >= monthStartDay
        ? DateTime(date.year, date.month, monthStartDay)
        : DateTime(date.year, date.month - 1, monthStartDay);
    // Un mes justo despues de empezar el ciclo, menos un dia, cae
    // siempre dentro del mes en el que el ciclo termina -- con
    // monthStartDay=1 eso es el propio mes de inicio (el "menos un dia"
    // no llega a salirse de el); con cualquier otro dia, es el mes
    // siguiente. `DateTime` normaliza solo meses/años que se salen de
    // rango, asi que no hace falta tratar diciembre/enero a mano.
    final labelDate = DateTime(cycleStart.year, cycleStart.month + 1, cycleStart.day)
        .subtract(const Duration(days: 1));
    return '${labelDate.year.toString().padLeft(4, '0')}-${labelDate.month.toString().padLeft(2, '0')}';
  }

  /// La operacion inversa de [yearMonthOf]: el rango de fechas real
  /// (inicio incluido, fin excluido) que corresponde al "mes" [yearMonth]
  /// segun [monthStartDay]. La usa `generateRecurringForMonth` /
  /// `generatePocketRecurringForMonth` para saber, dado un ciclo, en que
  /// mes o meses de calendario buscar el dia de cada plantilla (con
  /// `monthStartDay` distinto de 1, un ciclo casi siempre pisa dos meses
  /// de calendario a la vez -- ej. el ciclo "septiembre" con
  /// `monthStartDay=28` va del 28 de agosto al 27 de septiembre).
  static (DateTime, DateTime) _cycleRangeFor(String yearMonth, int monthStartDay) {
    final parts = yearMonth.split('-');
    final labelYear = int.parse(parts[0]);
    final labelMonth = int.parse(parts[1]);
    // Inversa de "un mes despues, menos un dia, cae en el mes en el que
    // el ciclo termina": con monthStartDay=1 el ciclo empieza en el
    // propio mes etiquetado; con cualquier otro dia, empieza el mes
    // anterior.
    final cycleStartMonth = monthStartDay == 1 ? labelMonth : labelMonth - 1;
    final cycleStart = DateTime(labelYear, cycleStartMonth, monthStartDay);
    final cycleEnd = DateTime(cycleStart.year, cycleStart.month + 1, cycleStart.day);
    return (cycleStart, cycleEnd);
  }

  static CategoryKind _toDomainKind(CategoryKindDb dbKind) => switch (dbKind) {
        CategoryKindDb.income => CategoryKind.income,
        CategoryKindDb.fixed => CategoryKind.fixed,
        CategoryKindDb.variable => CategoryKind.variable,
        CategoryKindDb.treat => CategoryKind.treat,
      };
}
