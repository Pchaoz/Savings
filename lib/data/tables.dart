/// Esquema de la base de datos, segun el documento 02.
///
/// Regla de oro: aqui solo se guardan **movimientos**. Ningun total
/// (neta, generado, saldo, bolsa) se almacena nunca. Guardar un total es
/// exactamente el problema del Excel: en cuanto lo guardas, puede
/// desincronizarse de sus partes.
library;

import 'package:drift/drift.dart';

/// Espejo de [CategoryKind] del dominio.
enum CategoryKindDb { income, fixed, variable, treat }

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// El campo que decide en que cubo entra el dinero.
  TextColumn get kind => textEnum<CategoryKindDb>()();

  TextColumn get icon => text().withDefault(const Constant('receipt'))();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Ocultar sin perder el historico. El dia que te mudes,
  /// "Alquiler" sigue ahi esperando.
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Determina a que mes pertenece el movimiento.
  DateTimeColumn get date => dateTime()();

  /// Normalmente positivo. **Negativo = devolucion** (doc 08).
  IntColumn get amountCents => integer()();

  IntColumn get categoryId => integer().references(Categories, #id)();

  /// "Monster", "Xiaomi Band 8 Pro". En caprichos es lo importante.
  TextColumn get note => text().nullable()();

  /// Apunta al movimiento devuelto. Permite enlazar las dos filas en la
  /// lista y saltar de una a otra, incluso entre meses distintos.
  IntColumn get refundOfId => integer().nullable().references(Transactions, #id)();

  /// Borrado suave. Los calculos filtran siempre por `deletedAt IS NULL`.
  /// Se purga de verdad a los 30 dias.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// `mistake` / `duplicate` / `other`. Solo se rellena al borrar.
  /// Las devoluciones NO se borran: generan un movimiento nuevo.
  TextColumn get deleteReason => text().nullable()();

  /// Si este movimiento lo genero un automatismo (doc 04: "la nomina y
  /// las suscripciones se meten solas"), el id de la plantilla que lo
  /// genero. A proposito NO es una `.references()`: si el usuario borra
  /// la plantilla mas adelante, los movimientos ya generados deben
  /// quedarse tal cual, como historico, sin que una FK lo impida.
  IntColumn get recurringTemplateId => integer().nullable()();

  /// Si este gasto se pago con dinero ya apartado en una hucha (en vez de
  /// la "cuenta principal"), el id de esa hucha. A proposito NO es una
  /// `.references()`, mismo motivo que `recurringTemplateId` de arriba: si
  /// se borra la hucha mas adelante, el historico de este gasto debe
  /// quedarse tal cual. Cuando esta puesto, `monthResult` IGNORA este
  /// movimiento del todo (no cuenta como ingreso/fijo/variable/capricho de
  /// este mes) — el dinero ya habia salido de tu ahorro general el dia
  /// que lo metiste en la hucha, asi que gastarlo ahora no debe volver a
  /// restar de este mes.
  IntColumn get paidFromPocketId => integer().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Los gastos que se repiten se generan solos. Es la mejora principal
/// sobre el Excel, donde reescribias "Suscripciones 63,70" cada mes.
@DataClassName('RecurringRow')
class RecurringTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();

  /// 1-28, para no pelearse con febrero ni con los meses de 30 dias.
  IntColumn get dayOfMonth => integer()();

  /// 1 = mensual. **3 = el T-Jove.**
  IntColumn get everyNMonths => integer().withDefault(const Constant(1))();

  /// "2026-08". Desde que mes cuenta el ciclo de [everyNMonths].
  TextColumn get anchorYearMonth => text().withLength(min: 7, max: 7)();

  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Solo guarda lo que no se puede deducir de los movimientos.
@DataClassName('MonthRow')
class Months extends Table {
  /// "2026-08"
  TextColumn get yearMonth => text().withLength(min: 7, max: 7)();

  /// Por defecto el global (10 %). Se puede sobrescribir un mes concreto.
  RealColumn get treatRate => real().nullable()();

  /// La semilla. **Solo el primer mes lo tiene**: 556082 (5.560,82 €).
  /// El resto de meses lo heredan calculado en cascada.
  IntColumn get openingBalanceCents => integer().nullable()();

  @override
  Set<Column> get primaryKey => {yearMonth};
}

/// Un toque = gasto apuntado. Esto es lo que hace que la app se use
/// de verdad en la cola del supermercado.
@DataClassName('QuickActionRow')
class QuickActions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// "Monster"
  TextColumn get label => text().withLength(min: 1, max: 30)();

  /// 180
  IntColumn get amountCents => integer()();

  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Una hucha de ahorro con nombre propio, tipo "Ahorro Japón" o "Ahorro
/// coche" — dinero que sigue siendo tuyo, solo que apartado y con
/// etiqueta. No toca ingresos/fijos/variables/capricho: es un sistema en
/// paralelo (ver `PocketMovements`).
@DataClassName('PocketRow')
class SavingsPockets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Meta opcional. Si esta puesta, la pantalla muestra una barra de
  /// progreso y un aviso al llegar al 100 % — nada mas pasa solo, la
  /// hucha sigue funcionando igual despues de cumplirla.
  IntColumn get targetCents => integer().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// Un movimiento dentro de una hucha. Positivo = metes dinero, negativo =
/// sacas. A proposito NO pasa por `Transactions`: mover dinero a una
/// hucha no es un gasto (el dinero sigue siendo tuyo), asi que no debe
/// restar de la ganancia neta del mes ni encoger la bolsa de caprichos.
@DataClassName('PocketMovementRow')
class PocketMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pocketId => integer().references(SavingsPockets, #id)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  /// Igual que `Transactions.recurringTemplateId`: si esto lo genero una
  /// aportacion automatica, el id de esa plantilla, sin `.references()`
  /// para que borrar la plantilla no afecte al historico ya generado.
  IntColumn get recurringPocketTemplateId => integer().nullable()();

  /// Si este movimiento lo genero pagar un gasto con esta hucha (en vez
  /// de con la "cuenta principal"), el id de ese gasto en `Transactions`.
  /// Sirve para mantener el importe sincronizado si se edita el gasto, y
  /// para dejar de contar este movimiento si el gasto se borra (ver
  /// `pocketBalances`/`movementsForPocket`) — sin duplicar el concepto de
  /// "borrado" aqui: el estado real vive en `Transactions.deletedAt`.
  /// Null en el resto de movimientos (meter/sacar a mano, aportacion
  /// automatica).
  IntColumn get relatedTransactionId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Aportacion automatica mensual a una hucha concreta — mismo mecanismo
/// que `RecurringTemplates`, pero apuntando a una hucha en vez de a una
/// categoria, para que mover dinero a una hucha nunca cuente como gasto.
@DataClassName('PocketRecurringRow')
class PocketRecurringTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pocketId => integer().references(SavingsPockets, #id)();
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();
  IntColumn get dayOfMonth => integer()();
  IntColumn get everyNMonths => integer().withDefault(const Constant(1))();
  TextColumn get anchorYearMonth => text().withLength(min: 7, max: 7)();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Ajustes globales de la app. Una unica fila (siempre `id == 0`): no es
/// un movimiento ni una plantilla, es configuracion pura.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer()();

  /// Sustituye a `kDefaultTreatRate` (10 %) como margen de caprichos por
  /// defecto para los meses que no tengan su propio `Months.treatRate`.
  /// Null = se sigue usando el 10 % de fabrica.
  RealColumn get defaultTreatRate => real().nullable()();

  /// Que muestra "Ahorro total" en Inicio: true = el ahorro real
  /// (incluye lo que llevas metido en huchas), false = solo lo disponible
  /// sin apartar (ahorro real - huchas).
  BoolColumn get showPocketsInTotal => boolean().withDefault(const Constant(true))();

  /// "2026-09": el mes en el que Inicio ya preguntó (o el usuario ya
  /// contestó) que hacer con el sobrante de caprichos del mes anterior.
  /// Evita repetir el aviso en cada apertura de la app durante el mismo
  /// mes, tanto si se movió a una hucha como si se eligió seguir
  /// acumulandolo. Null = todavia no se ha preguntado nunca.
  TextColumn get dismissedTreatSweepYearMonth => text().withLength(min: 7, max: 7).nullable()();

  /// Día 1-28 en el que "empieza el mes" para todos los cálculos
  /// (`SavingsRepository.yearMonthOf`). Null = 1, el calendario de toda
  /// la vida. Puesto a otro día (p. ej. 28, el día de cobro de Pol), un
  /// "mes" pasa a ser un ciclo de nómina a nómina en vez de un mes de
  /// calendario — el día 28 de agosto ya cuenta para "septiembre", no
  /// para "agosto" (se etiqueta por el mes en el que termina el ciclo).
  /// Igual que `dayOfMonth` en `RecurringTemplates`, limitado a 1-28 para
  /// no pelearse con febrero.
  IntColumn get monthStartDay => integer().nullable()();

  /// Si ya se le enseño el tutorial guiado (bolsa de caprichos + como
  /// apuntar un gasto) al menos una vez -- por defecto false, asi que a
  /// una instalacion nueva se le ofrece automaticamente en Inicio. Se
  /// pone a true tanto al terminar el tutorial entero como al pulsar
  /// "Saltar tutorial" (las dos cuentan como "ya visto", para no volver a
  /// insistir). "Ajustes > Repetir tutorial" lo pone de nuevo a false.
  BoolColumn get hasSeenTutorial => boolean().withDefault(const Constant(false))();

  /// Bloqueo opcional de la app con PIN (con huella/cara como atajo si el
  /// móvil lo soporta) -- Ajustes > Bloqueo de la app, pedido por Pol el
  /// 21/09/2026. Por defecto desactivado. El PIN nunca se guarda en
  /// claro: solo su hash (`appLockPinHash`) junto con la sal aleatoria
  /// usada para calcularlo (`appLockPinSalt`), ver `core/pin_hash.dart`.
  BoolColumn get appLockEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get appLockPinHash => text().nullable()();
  TextColumn get appLockPinSalt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
