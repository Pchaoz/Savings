/// Cableado de Riverpod: une la base de datos real con el motor.
///
/// De aqui para "arriba" (pantallas) nadie sabe que existe SQLite ni el
/// motor puro por separado — solo se ve `SavingsRepository` y
/// `MonthResult`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/savings_repository.dart';
import '../domain/models/models.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close().catchError((_) {});
  });
  return db;
});

final repositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository(ref.watch(databaseProvider));
});

/// "2026-08" para el mes (o ciclo, ver `AppSettings.monthStartDay`) en
/// curso. [monthStartDay] es obligatorio a proposito -- lo trae siempre
/// quien llama, leido de `appSettingsProvider`, para no arriesgarse a
/// que algun sitio se quede calculando por calendario sin enterarse de
/// que Pol cambio el dia de inicio de mes.
String currentYearMonth({required int monthStartDay}) {
  return SavingsRepository.yearMonthOf(DateTime.now(), monthStartDay);
}

/// El resultado de [yearMonth] ("2026-08"), recalculado desde la base de
/// datos real. Antes de calcular nada, se asegura de que las plantillas
/// recurrentes que tocan ese mes (doc 04: nomina, suscripciones...) ya se
/// han generado como movimientos de verdad — mismo patron perezoso que la
/// purga de la papelera. Sirve tanto para el mes en curso como para uno
/// anterior que se este mirando desde Inicio (flechas de mes): si ese mes
/// ya paso sin abrir la app, esto genera sus recurrentes con retraso, en
/// vez de dejarlos sin generar para siempre.
final monthResultProvider = FutureProvider.family<MonthResult, String>((ref, yearMonth) async {
  final repo = ref.watch(repositoryProvider);
  await repo.generateRecurringForMonth(yearMonth);
  return repo.monthResult(yearMonth);
});

/// Movimientos de [yearMonth], con sus devoluciones enlazadas.
final monthMovementsProvider =
    FutureProvider.family<List<MovementView>, String>((ref, yearMonth) async {
  final repo = ref.watch(repositoryProvider);
  await repo.generateRecurringForMonth(yearMonth);
  return repo.movementsFor(yearMonth);
});

/// Texto de busqueda actual en Movimientos (icono de lupa en la AppBar,
/// pedido por Pol el 22/09/2026). Vive aparte de `selectedYearMonthProvider`
/// porque buscar no cambia de mes: mientras hay texto de busqueda,
/// Movimientos deja de mostrar el mes seleccionado y enseña resultados de
/// TODO el historial agrupados por mes (ver `movementSearchResultsProvider`).
class MovementSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;

  void clear() => state = '';
}

final movementSearchQueryProvider = NotifierProvider<MovementSearchQuery, String>(
  MovementSearchQuery.new,
);

/// Resultados de `movementSearchQueryProvider`, por texto de la nota en
/// todo el historial (no solo el mes seleccionado -- ver
/// `SavingsRepository.searchMovements`). Vacio mientras no haya texto de
/// busqueda, sin tocar la base de datos para nada (mismo `searchMovements`
/// que ya corta antes de consultar si `query` esta en blanco).
final movementSearchResultsProvider = FutureProvider<List<MovementView>>((ref) {
  final query = ref.watch(movementSearchQueryProvider);
  return ref.watch(repositoryProvider).searchMovements(query);
});

/// Resumen por categoria de [yearMonth] (ingresos y gastos, dentro de
/// Evolución del ahorro), mismo patron perezoso que
/// `monthMovementsProvider`: genera antes los recurrentes de ese mes (y los
/// del mes/ciclo anterior, para que la comparativa entre meses tambien
/// vea nominas/suscripciones recien tocadas) para que todo salga ya
/// materializado en el resumen.
final categoryTotalsProvider =
    FutureProvider.family<List<CategoryTotal>, String>((ref, yearMonth) async {
  final repo = ref.watch(repositoryProvider);
  await repo.generateRecurringForMonth(_shiftYearMonth(yearMonth, -1));
  await repo.generateRecurringForMonth(yearMonth);
  return repo.categoryTotalsFor(yearMonth);
});

/// Categorias disponibles (ya sembradas al crear la base de datos).
final categoriesProvider = FutureProvider<List<CategoryRow>>((ref) {
  return ref.watch(repositoryProvider).categories;
});

/// Igual que `categoriesProvider`, pero sin las ocultas (Ajustes >
/// Categorias > tocar el ojo). Para elegir categoria en algo NUEVO
/// (Nuevo gasto, Accesos rapidos, Recurrentes) — nunca para pintar el
/// historico ya existente, que sigue usando `categoriesProvider` sin
/// filtrar para poder mostrar bien una categoria ya oculta.
final visibleCategoriesProvider = FutureProvider<List<CategoryRow>>((ref) async {
  final all = await ref.watch(categoriesProvider.future);
  return all.where((c) => !c.archived).toList();
});

/// Accesos rapidos de un toque (ej. "Monster" 1,80 EUR).
final quickActionsProvider = FutureProvider<List<QuickActionRow>>((ref) {
  return ref.watch(repositoryProvider).quickActions;
});

// ---------------------------------------------------------------------
// Mes que se esta mirando en Inicio y en Movimientos (flechas < mes >).
// ---------------------------------------------------------------------

/// A que mes ("2026-08") apuntan las flechas de Inicio ahora mismo.
/// Nunca deja pasar al mes de verdad siguiente al de hoy — no tiene
/// sentido "adelantar" el calendario, y generaria recurrentes de un mes
/// que todavia no ha llegado.
class SelectedYearMonth extends Notifier<String> {
  @override
  String build() {
    final monthStartDay =
        ref.watch(appSettingsProvider.select((s) => s.value?.monthStartDay)) ?? 1;
    return currentYearMonth(monthStartDay: monthStartDay);
  }

  void shift(int deltaMonths) {
    final proposed = _shiftYearMonth(state, deltaMonths);
    final monthStartDay = ref.read(appSettingsProvider).value?.monthStartDay ?? 1;
    final today = currentYearMonth(monthStartDay: monthStartDay);
    state = proposed.compareTo(today) > 0 ? today : proposed;
  }

  void resetToCurrent() {
    final monthStartDay = ref.read(appSettingsProvider).value?.monthStartDay ?? 1;
    state = currentYearMonth(monthStartDay: monthStartDay);
  }
}

final selectedYearMonthProvider = NotifierProvider<SelectedYearMonth, String>(
  SelectedYearMonth.new,
);

/// "2026-08" + deltaMonths meses (puede ser negativo) -> "2026-07", etc.
String _shiftYearMonth(String yearMonth, int deltaMonths) {
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

// ---------------------------------------------------------------------
// Grafica de evolucion del ahorro (Ajustes > Fase 5).
// ---------------------------------------------------------------------

/// Historial mensual (saldo de cierre real, sin ajuste de huchas — igual
/// que un mes anterior en Inicio) para dibujar la evolucion del ahorro.
/// Nunca se remonta a antes del primer mes con actividad real
/// (`earliestActivityYearMonth`), para no enseñar meses "fantasma" a 0
/// antes de que Pol empezara a usar la app, y como mucho enseña los
/// ultimos 12 meses aunque haya mas historial detras.
final savingsHistoryProvider = FutureProvider<List<(String, MonthResult)>>((ref) async {
  final repo = ref.watch(repositoryProvider);
  final monthStartDay = (await ref.watch(appSettingsProvider.future)).monthStartDay ?? 1;
  final today = currentYearMonth(monthStartDay: monthStartDay);

  final earliest = await repo.earliestActivityYearMonth() ?? today;
  final maxBack = _shiftYearMonth(today, -11);
  final start = earliest.compareTo(maxBack) < 0 ? maxBack : earliest;

  final months = <String>[];
  var cursor = start;
  while (cursor.compareTo(today) <= 0) {
    months.add(cursor);
    cursor = _shiftYearMonth(cursor, 1);
  }

  final points = <(String, MonthResult)>[];
  for (final ym in months) {
    await repo.generateRecurringForMonth(ym);
    points.add((ym, await repo.monthResult(ym)));
  }
  return points;
});

/// Plantillas de gasto/ingreso recurrente (Ajustes > Recurrentes, doc 04).
final recurringTemplatesProvider = FutureProvider<List<RecurringRow>>((ref) {
  return ref.watch(repositoryProvider).recurringTemplates;
});

/// El saldo inicial ya guardado para el mes en curso, para precargar el
/// formulario de Ajustes > Saldo inicial. Null si todavia no se ha
/// configurado nunca.
final currentOpeningBalanceProvider = FutureProvider<int?>((ref) async {
  final monthStartDay = (await ref.watch(appSettingsProvider.future)).monthStartDay ?? 1;
  return ref
      .watch(repositoryProvider)
      .openingBalanceFor(currentYearMonth(monthStartDay: monthStartDay));
});

/// Ids que acabamos de borrar desde la lista, ocultos al instante.
///
/// `monthMovementsProvider` es async: invalidarlo no actualiza la
/// lista en el mismo frame, asi que sin esto un `Dismissible` ya
/// descartado seguiria technically en el arbol un instante (Flutter lo
/// detecta y lanza "A dismissed Dismissible widget is still part of the
/// tree"). `hide` se llama al borrar, `show` al deshacer.
class RemovedMovementIds extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{};

  void hide(int id) => state = {...state, id};

  void show(int id) => state = {...state}..remove(id);
}

final removedMovementIdsProvider = NotifierProvider<RemovedMovementIds, Set<int>>(
  RemovedMovementIds.new,
);

/// Mismo patron que `removedMovementIdsProvider` (ver nota ahi arriba),
/// pero para los movimientos de una hucha (`pocket_detail_screen.dart`):
/// evita el mismo "A dismissed Dismissible widget is still part of the
/// tree" al deslizar para borrar un movimiento de una hucha.
class RemovedPocketMovementIds extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{};

  void hide(int id) => state = {...state, id};
}

final removedPocketMovementIdsProvider =
    NotifierProvider<RemovedPocketMovementIds, Set<int>>(
  RemovedPocketMovementIds.new,
);

/// Pide a Inicio que vuelva a mostrar el tutorial guiado ya mismo,
/// aunque `AppSettings.hasSeenTutorial` ya sea `true` -- lo dispara el
/// boton "Repetir tutorial" de Ajustes. `consume()` lo deja otra vez en
/// `false` en cuanto Inicio ha arrancado el tutorial, para no repetirlo
/// solo por reconstruirse.
class ForceShowTutorial extends Notifier<bool> {
  @override
  bool build() => false;

  void trigger() => state = true;

  void consume() => state = false;
}

final forceShowTutorialProvider = NotifierProvider<ForceShowTutorial, bool>(
  ForceShowTutorial.new,
);

/// Avisa a `AppLockGate` (main.dart) de que la app se va a pausar por
/// algo que ELLA MISMA ha abierto (el selector nativo de guardar/elegir
/// fichero de la copia de seguridad, `settings_screen.dart`), no porque
/// Pol haya salido de verdad a otra app. Sin esto, elegir dónde guardar
/// la copia de seguridad habría vuelto a pedir el PIN nada más volver del
/// selector, en mitad de esa misma acción -- molesto y sin sentido, ese
/// selector es parte del propio flujo de la app. `suspend()` antes de
/// abrir el selector, `resume()` en un `finally` al volver de él.
class AppLockSuspend extends Notifier<bool> {
  @override
  bool build() => false;

  void suspend() => state = true;

  void resume() => state = false;
}

final appLockSuspendedProvider = NotifierProvider<AppLockSuspend, bool>(
  AppLockSuspend.new,
);

/// Papelera (Ajustes > Papelera, doc 08): purga primero lo que lleva mas
/// de 30 dias, y devuelve lo que queda.
final trashedMovementsProvider = FutureProvider<List<MovementView>>((ref) async {
  final repo = ref.watch(repositoryProvider);
  await repo.purgeExpiredTrash();
  return repo.trashed();
});

// ---------------------------------------------------------------------
// Huchas de ahorro.
// ---------------------------------------------------------------------

/// Huchas dadas de alta (Ajustes > Huchas de ahorro).
final pocketsProvider = FutureProvider<List<PocketRow>>((ref) {
  return ref.watch(repositoryProvider).pockets;
});

/// Saldo de cada hucha, indexado por su id. Antes de leerlo, genera las
/// aportaciones automaticas del mes en curso — mismo patron perezoso que
/// `monthResultProvider` con los recurrentes normales.
final pocketBalancesProvider = FutureProvider<Map<int, int>>((ref) async {
  final repo = ref.watch(repositoryProvider);
  final monthStartDay = (await ref.watch(appSettingsProvider.future)).monthStartDay ?? 1;
  await repo.generatePocketRecurringForMonth(currentYearMonth(monthStartDay: monthStartDay));
  return repo.pocketBalances();
});

/// Suma de todas las huchas — lo que Inicio necesita para el desglose y
/// para el ajuste de "ahorro real vs disponible".
final totalPocketsCentsProvider = FutureProvider<int>((ref) async {
  final balances = await ref.watch(pocketBalancesProvider.future);
  return balances.values.fold<int>(0, (a, b) => a + b);
});

/// Movimientos de una hucha concreta (pantalla de detalle).
final pocketMovementsProvider =
    FutureProvider.family<List<PocketMovementRow>, int>((ref, pocketId) async {
  final repo = ref.watch(repositoryProvider);
  final monthStartDay = (await ref.watch(appSettingsProvider.future)).monthStartDay ?? 1;
  await repo.generatePocketRecurringForMonth(currentYearMonth(monthStartDay: monthStartDay));
  return repo.movementsForPocket(pocketId);
});

/// Aportaciones automaticas a huchas (todas; la pantalla de detalle
/// filtra las de su propia hucha).
final pocketRecurringTemplatesProvider = FutureProvider<List<PocketRecurringRow>>((ref) {
  return ref.watch(repositoryProvider).pocketRecurringTemplates;
});

// ---------------------------------------------------------------------
// Sobrante de caprichos -> hucha (aviso al cambiar de mes, Inicio).
// ---------------------------------------------------------------------

/// Cuanto se puede mover ahora mismo del mes anterior a una hucha, y si
/// hay ya alguna hucha donde mandarlo -- null si no hay nada que
/// ofrecer: ya se contesto este mes, o no hubo sobrante de verdad.
///
/// **Bug corregido el 01/09/2026**: antes, si todavia no tenias ninguna
/// hucha creada, esto devolvia null y el aviso no aparecia nunca --
/// contradiciendo el propio comentario de `_PocketPickerSheet` ("si Pol
/// no tiene todavia la hucha que quiere, la crea desde Ajustes y el
/// aviso le sigue esperando"), que daba por hecho que el aviso SI
/// aparecia sin hucha. Ahora "no hay ninguna hucha todavia" ya no apaga
/// el aviso: lo cambia por uno que invita a crear una primero (ver
/// `_TreatSweepBanner`), y sigue sin marcarse como contestado hasta que
/// Pol elige algo.
///
/// El importe es `min(bagOpeningCents, bagClosingCents)` del mes en
/// curso -- `bagOpeningCents` es exactamente lo que trajo el mes
/// anterior (ver `MonthResult`), y el `min` con `bagClosingCents` evita
/// ofrecer mas de lo que de verdad sigue sin gastar ahora mismo, por si
/// ya se ha apuntado algun capricho este mes antes de contestar al
/// aviso.
final pendingTreatSweepProvider = FutureProvider<(int, String, bool)?>((ref) async {
  final settings = await ref.watch(appSettingsProvider.future);
  final today = currentYearMonth(monthStartDay: settings.monthStartDay ?? 1);
  if (settings.dismissedTreatSweepYearMonth == today) return null;

  final result = await ref.watch(monthResultProvider(today).future);
  final available = result.bagOpeningCents < result.bagClosingCents
      ? result.bagOpeningCents
      : result.bagClosingCents;
  if (available <= 0) return null;

  final pockets = await ref.watch(pocketsProvider.future);
  return (available, _shiftYearMonth(today, -1), pockets.isNotEmpty);
});

/// Cuanto de la bolsa de caprichos del mes en curso esta en realidad ya
/// comprometido por gastos fijos recurrentes que todavia no han llegado
/// a su dia (pedido por Pol el 22/09/2026, ver "Reservar gastos fijos
/// pendientes" en el resumen del proyecto): una suscripcion del dia 22
/// vista desde el dia 15 es un gasto practicamente seguro, aunque
/// `generateRecurringForMonth` todavia no la haya generado como
/// `Transactions` real. Inicio resta esto de la bolsa MOSTRADA (no del
/// calculo real del motor, que sigue viendo solo dinero que ya paso de
/// verdad) para no dar por libre un margen que en la practica ya esta
/// comprometido. Solo tiene sentido para el mes en curso -- Inicio solo
/// lo aplica mirando ese mes.
final pendingFixedExpensesProvider = FutureProvider<int>((ref) async {
  final settings = await ref.watch(appSettingsProvider.future);
  final today = currentYearMonth(monthStartDay: settings.monthStartDay ?? 1);
  return ref.watch(repositoryProvider).pendingFixedExpensesCents(today);
});

// ---------------------------------------------------------------------
// Ajustes globales.
// ---------------------------------------------------------------------

/// Margen de caprichos personalizado y si "Ahorro total" en Inicio
/// incluye o no lo que llevas en huchas (Ajustes).
final appSettingsProvider = FutureProvider<AppSettingsRow>((ref) {
  return ref.watch(repositoryProvider).getAppSettings();
});
