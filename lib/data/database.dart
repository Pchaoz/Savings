/// La base de datos real. Un unico fichero SQLite en el telefono.
///
/// `database.g.dart` no existe todavia: lo genera `build_runner` a partir
/// de las anotaciones de este fichero y de `tables.dart`. Sin ese paso el
/// proyecto no compila.
///
/// La apertura de la conexion usa `drift_flutter`, que es la forma actual
/// recomendada (sustituye al patron antiguo de `sqlite3_flutter_libs` +
/// `LazyDatabase` + `path_provider` manual, que quedo obsoleto cuando
/// `package:sqlite3` paso a la version 3.x y empezo a traer sus propios
/// binarios nativos).
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    RecurringTemplates,
    Months,
    QuickActions,
    SavingsPockets,
    PocketMovements,
    PocketRecurringTemplates,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor para tests: se le pasa un executor en memoria
  /// (por ejemplo `NativeDatabase.memory()`), sin tocar disco.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          final categoryIds = await _seedDefaultCategories();
          await _seedDefaultQuickActions(categoryIds);
          await _seedAppSettingsIfMissing();
        },
        onUpgrade: (m, from, to) async {
          // v2: doc 04, automatismos — enlaza cada movimiento generado
          // solo con la plantilla recurrente que lo creo.
          if (from < 2) {
            await m.addColumn(transactions, transactions.recurringTemplateId);
          }
          // v3: categoria "Viajes" (gasto variable, no capricho — un
          // vuelo/hotel no debe salir de la bolsa de caprichos, pero
          // tampoco es un gasto fijo de cada mes). Comprobamos por nombre
          // para no duplicarla si alguien ya la creo a mano desde Ajustes
          // antes de actualizar.
          if (from < 3) {
            await _insertCategoryIfMissing(
              name: 'Viajes',
              kind: CategoryKindDb.variable,
              icon: 'flight',
            );
          }
          // v4: categoria "Ajuste de cuadre" para Ajustes > Ajustar saldo
          // — corregir descuadres entre lo calculado y el saldo real sin
          // que se confundan con gastos o ingresos normales.
          if (from < 4) {
            await _insertCategoryIfMissing(
              name: 'Ajuste de cuadre',
              kind: CategoryKindDb.variable,
              icon: 'balance',
            );
          }
          // v5: huchas de ahorro (Ajustes > Huchas de ahorro) y ajustes
          // globales (margen de caprichos personalizable, y si "Ahorro
          // total" en Inicio incluye o no lo que llevas en huchas).
          // Tablas nuevas, nada que migrar de datos existentes salvo
          // sembrar la fila unica de AppSettings.
          if (from < 5) {
            await m.createTable(savingsPockets);
            await m.createTable(pocketMovements);
            await m.createTable(pocketRecurringTemplates);
            await m.createTable(appSettings);
            await _seedAppSettingsIfMissing();
          }
          // v6: columna para recordar hasta que mes ya se pregunto (o se
          // contesto) que hacer con el sobrante de la bolsa de caprichos
          // del mes anterior (Inicio, aviso al cambiar de mes). Ninguna
          // fila existente pierde nada: por defecto queda null, que es
          // exactamente "todavia no se ha preguntado nunca".
          if (from < 6) {
            await m.addColumn(appSettings, appSettings.dismissedTreatSweepYearMonth);
          }
          // v7: pagar un gasto directamente con el dinero de una hucha
          // (en vez de la "cuenta principal"). Dos columnas nuevas, las
          // dos nullable así que las filas existentes no pierden nada:
          // `Transactions.paidFromPocketId` (que hucha lo pago, si
          // alguna) y `PocketMovements.relatedTransactionId` (que gasto
          // genero ese movimiento de hucha, para mantenerlos
          // sincronizados si se edita o se borra el gasto).
          if (from < 7) {
            await m.addColumn(transactions, transactions.paidFromPocketId);
            await m.addColumn(pocketMovements, pocketMovements.relatedTransactionId);
          }
          // v8: "mes de nómina a nómina" (Ajustes > Personalización) --
          // en qué día del mes se considera que empieza un "mes" para
          // todos los cálculos, en vez de siempre el día 1. Nullable, sin
          // dato que migrar: las filas existentes quedan en null, que es
          // exactamente "sigue siendo el día 1 de siempre".
          if (from < 8) {
            await m.addColumn(appSettings, appSettings.monthStartDay);
          }
          // v9: tutorial guiado (bolsa de caprichos + como apuntar un
          // gasto) en Inicio para quien abre la app por primera vez.
          // Nullable no hace falta -- por defecto false, asi que quien ya
          // tenia la app instalada (y ya sabe usarla) no lo pierde de
          // vista: simplemente se le ofrecera una vez en su proxima
          // apertura, y puede saltarlo con un toque.
          if (from < 9) {
            await m.addColumn(appSettings, appSettings.hasSeenTutorial);
          }
        },
      );

  /// Comprueba por nombre para no duplicar si el usuario ya la creo a
  /// mano desde Ajustes > Categorias antes de actualizar.
  Future<void> _insertCategoryIfMissing({
    required String name,
    required CategoryKindDb kind,
    required String icon,
  }) async {
    final rows = await select(categories).get();
    if (rows.any((c) => c.name == name)) return;

    final nextSort = rows.isEmpty
        ? 0
        : rows.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        kind: kind,
        icon: Value(icon),
        sortOrder: Value(nextSort),
      ),
    );
  }

  /// Crea la fila unica de configuracion global (id == 0) si no existe
  /// todavia — tanto en instalaciones nuevas como al actualizar desde una
  /// version anterior a la v5.
  Future<void> _seedAppSettingsIfMissing() async {
    final existing = await select(appSettings).getSingleOrNull();
    if (existing != null) return;
    await into(appSettings).insert(
      AppSettingsCompanion.insert(id: Value(0)),
    );
  }

  /// Las categorias fijas del Excel, ya clasificadas por grupo.
  /// El usuario podra archivar/anadir mas adelante; esto es solo el punto
  /// de partida para que la app no arranque vacia.
  /// Devuelve el id de cada categoria por nombre, para poder enlazar los
  /// accesos rapidos de partida sin tener que volver a consultarlas.
  Future<Map<String, int>> _seedDefaultCategories() async {
    const defaults = <(String, CategoryKindDb, String)>[
      ('Nómina', CategoryKindDb.income, 'work'),
      ('Ingresos extra', CategoryKindDb.income, 'add_card'),
      ('Otros ingresos', CategoryKindDb.income, 'payments'),
      ('Alquiler / Hipoteca', CategoryKindDb.fixed, 'home'),
      ('Luz', CategoryKindDb.fixed, 'bolt'),
      ('Agua', CategoryKindDb.fixed, 'water_drop'),
      ('Gas', CategoryKindDb.fixed, 'local_fire_department'),
      ('Internet / Teléfono', CategoryKindDb.fixed, 'wifi'),
      ('Suscripciones', CategoryKindDb.fixed, 'subscriptions'),
      ('Seguro', CategoryKindDb.fixed, 'shield'),
      ('Transporte', CategoryKindDb.fixed, 'directions_bus'),
      ('Comida / Supermercado', CategoryKindDb.variable, 'shopping_cart'),
      ('Restaurantes / Ocio', CategoryKindDb.variable, 'restaurant'),
      ('Ropa', CategoryKindDb.variable, 'checkroom'),
      ('Transporte extra', CategoryKindDb.variable, 'directions_car'),
      ('Otros', CategoryKindDb.variable, 'category'),
      ('Viajes', CategoryKindDb.variable, 'flight'),
      ('Ajuste de cuadre', CategoryKindDb.variable, 'balance'),
      ('Capricho', CategoryKindDb.treat, 'celebration'),
    ];

    final ids = <String, int>{};
    for (var i = 0; i < defaults.length; i++) {
      final (name, kind, icon) = defaults[i];
      final id = await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          kind: kind,
          icon: Value(icon),
          sortOrder: Value(i),
        ),
      );
      ids[name] = id;
    }
    return ids;
  }

  /// Un acceso rapido de ejemplo, para que la idea se entienda al abrir la
  /// app por primera vez. El usuario podra crear los suyos mas adelante.
  Future<void> _seedDefaultQuickActions(Map<String, int> categoryIds) async {
    final comidaId = categoryIds['Comida / Supermercado'];
    if (comidaId == null) return;

    await into(quickActions).insert(
      QuickActionsCompanion.insert(
        label: 'Monster',
        amountCents: 180,
        categoryId: comidaId,
        sortOrder: const Value(0),
      ),
    );
  }
}

/// `drift_flutter` elige la carpeta correcta segun la plataforma (en
/// Android, el directorio de documentos de la app) y bundlea el motor
/// nativo de sqlite3 sin que tengamos que tocar nada mas.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'savings');
}

/// Nombre del fichero SQLite, sin extension -- debe coincidir con el que
/// se le pasa a `driftDatabase(name: ...)` arriba: la restauracion de
/// copias de seguridad necesita saber exactamente que fichero sobrescribir.
const _dbName = 'savings';

/// Ruta absoluta del fichero de base de datos en uso ahora mismo, en el
/// mismo sitio donde `drift_flutter` lo abre (documentos de la app en
/// Android). La usan Ajustes > Copia de seguridad y Ajustes > Restaurar
/// para saber sobre que fichero operar.
Future<String> databaseFilePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, '$_dbName.sqlite');
}

/// Borra los ficheros auxiliares de SQLite (`-wal`, `-shm`, `-journal`)
/// junto al fichero de base de datos indicado, si existen. Imprescindible
/// antes de sustituir el `.sqlite` en vivo por una copia de seguridad: si
/// se dejan, SQLite puede "reproducir" el WAL viejo sobre el fichero
/// nuevo y mezclar datos de las dos bases de datos.
Future<void> deleteDatabaseSidecarFiles(String dbPath) async {
  for (final suffix in ['-wal', '-shm', '-journal']) {
    final f = File('$dbPath$suffix');
    if (await f.exists()) await f.delete();
  }
}

