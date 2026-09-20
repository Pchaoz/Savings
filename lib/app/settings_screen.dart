/// Ajustes: datos de partida (saldo inicial, recurrentes), gestión
/// (categorías, accesos rápidos, papelera, copia de seguridad) y
/// personalización (margen de caprichos, huchas de ahorro). Se irá
/// llenando en fases futuras (export a Excel...).
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../domain/engine/month_calculator.dart';
import 'about_screen.dart';
import 'adjustment_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_quick_actions_screen.dart';
import 'manage_recurring_screen.dart';
import 'pockets_screen.dart';
import 'providers.dart';
import 'trash_screen.dart';

String _backupTimestamp(DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${now.year}${two(now.month)}${two(now.day)}_'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}';
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openOpeningBalanceSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const _OpeningBalanceSheet(),
    );
  }

  /// Genera una copia de la base de datos entera (VACUUM INTO, ver
  /// `SavingsRepository.backupDatabaseTo`) y abre el panel nativo de
  /// compartir para que el usuario decida donde guardarla — Google
  /// Drive, un email a si mismo, WhatsApp... La copia se genera en la
  /// carpeta temporal de la app, solo para poder compartirla; no se
  /// queda guardada dentro de la app.
  /// Genera un `.sqlite` con `backupDatabaseTo` y lo comprime en un
  /// `.zip` junto a el (mismo directorio, mismo nombre base), borrando el
  /// `.sqlite` suelto al terminar. Se comparte/guarda SIEMPRE como `.zip`
  /// y nunca como `.sqlite` suelto: Android no reconoce esa extensión, y
  /// muchas apps (Drive, Archivos...) le cambian el nombre a algo con
  /// ".bin" sin avisar en cuanto sale de la app — pasaba tanto al
  /// compartir "Copia de seguridad" como, hasta este arreglo, en la copia
  /// de seguridad automática que se guarda antes de restaurar.
  Future<String> _zippedBackup(WidgetRef ref, String baseName) async {
    final tmpDir = await getTemporaryDirectory();
    final sqliteName = '$baseName.sqlite';
    final sqlitePath = p.join(tmpDir.path, sqliteName);
    final sqliteFile = File(sqlitePath);
    if (await sqliteFile.exists()) await sqliteFile.delete();

    await ref.read(repositoryProvider).backupDatabaseTo(sqlitePath);

    final zipPath = p.join(tmpDir.path, '$baseName.zip');
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(sqliteName, await sqliteFile.readAsBytes()));
    final zipBytes = ZipEncoder().encode(archive);
    await File(zipPath).writeAsBytes(zipBytes);
    await sqliteFile.delete();

    return zipPath;
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    try {
      final stamp = _backupTimestamp(DateTime.now());
      final zipPath = await _zippedBackup(ref, 'savings_backup_$stamp');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipPath)],
          subject: 'Copia de seguridad de Savings ($stamp)',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo hacer la copia: $e')),
        );
      }
    }
  }

  /// Sustituye la base de datos en vivo por un fichero de copia de
  /// seguridad elegido por el usuario. Es una operacion irreversible de
  /// verdad (borra TODOS los datos actuales), asi que antes de tocar nada:
  /// (1) pide confirmacion explicita con un dialogo en rojo, y (2) guarda
  /// automaticamente una copia de seguridad de los datos actuales (por si
  /// el usuario se equivoca de fichero o se arrepiente).
  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFiles(
      dialogTitle: 'Elige la copia de seguridad',
      type: FileType.any,
    );
    if (picked.isEmpty) return;
    final pickedPath = picked.first.path;
    if (pickedPath == null) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Restaurar esta copia de seguridad?'),
        content: const Text(
          'Esto borra TODOS los datos actuales de la app (movimientos, '
          'huchas, ajustes...) y los sustituye por los de la copia '
          'elegida. No se puede deshacer.\n\n'
          'Por seguridad se guarda antes, dentro de la app, una copia de '
          'como estaban los datos justo antes de restaurar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.spend),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final safetyStamp = _backupTimestamp(DateTime.now());
      final safetyZipPath = await _zippedBackup(ref, 'antes_de_restaurar_$safetyStamp');
      final safetyDir = await getApplicationDocumentsDirectory();
      final safetyName = 'antes_de_restaurar_$safetyStamp.zip';
      final safetyPath = p.join(safetyDir.path, safetyName);
      await File(safetyZipPath).copy(safetyPath);
      await File(safetyZipPath).delete();

      // Las copias nuevas se comparten como .zip (ver `_backup`); las
      // hechas antes de ese cambio pueden ser un .sqlite o incluso un
      // .bin (si Android le cambió la extensión al guardarlo) -- en
      // esos dos últimos casos el fichero elegido ya es la base de
      // datos tal cual, no hay que descomprimir nada.
      var sourcePath = pickedPath;
      if (pickedPath.toLowerCase().endsWith('.zip')) {
        final zipBytes = await File(pickedPath).readAsBytes();
        final archive = ZipDecoder().decodeBytes(zipBytes);
        ArchiveFile? sqliteEntry;
        for (final entry in archive) {
          if (entry.isFile) {
            sqliteEntry = entry;
            break;
          }
        }
        final extractedBytes = sqliteEntry?.readBytes();
        if (extractedBytes == null) {
          throw Exception('El .zip elegido no contiene ninguna copia de seguridad');
        }
        final tmpDir = await getTemporaryDirectory();
        sourcePath = p.join(tmpDir.path, 'restore_${_backupTimestamp(DateTime.now())}.sqlite');
        await File(sourcePath).writeAsBytes(extractedBytes);
      }

      final livePath = await databaseFilePath();
      await ref.read(databaseProvider).close();
      await deleteDatabaseSidecarFiles(livePath);
      await File(sourcePath).copy(livePath);

      ref.invalidate(databaseProvider);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Copia restaurada. Tus datos de antes quedaron guardados '
            'como $safetyName por si acaso.',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo restaurar: $e')),
      );
    }
  }

  Future<void> _openTreatRateSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const _TreatRateSheet(),
    );
  }

  Future<void> _openMonthStartDaySheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const _MonthStartDaySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('DATOS DE PARTIDA', style: T.eyebrow),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Saldo inicial'),
            subtitle: const Text('El ahorro que tenías antes de usar la app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openOpeningBalanceSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.autorenew),
            title: const Text('Ingresos y gastos recurrentes'),
            subtitle: const Text('Nómina, suscripciones... se apuntan solas cada mes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageRecurringScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.balance),
            title: const Text('Ajustar saldo'),
            subtitle: const Text('Corrige descuadres entre la app y tu saldo real'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdjustmentScreen()),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('GESTIÓN', style: T.eyebrow),
          ),
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: const Text('Huchas de ahorro'),
            subtitle: const Text('Bolsas con nombre propio dentro de tu ahorro, como "Ahorro Japón"'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PocketsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categorías'),
            subtitle: const Text('Añade categorías propias, como "Viajes"'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bolt_outlined),
            title: const Text('Accesos rápidos'),
            subtitle: const Text('Tus plantillas de un toque para apuntar rápido'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageQuickActionsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Papelera'),
            subtitle: const Text('Movimientos eliminados en los últimos 30 días'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrashScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Copia de seguridad'),
            subtitle: const Text('Guarda un archivo con todos tus datos, por si pierdes el móvil'),
            trailing: const Icon(Icons.ios_share),
            onTap: () => _backup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Restaurar copia de seguridad'),
            subtitle: const Text(
              'Sustituye TODOS los datos actuales por los de un archivo de copia',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _restore(context, ref),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('PERSONALIZACIÓN', style: T.eyebrow),
          ),
          settingsAsync.when(
            data: (settings) {
              final ratePercent = ((settings.defaultTreatRate ?? kDefaultTreatRate) * 100).round();
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: const Text('Margen de caprichos'),
                    subtitle: Text('Ahora mismo: $ratePercent % del ahorro del mes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openTreatRateSheet(context),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.account_balance_outlined),
                    title: const Text('Ahorro total incluye huchas'),
                    subtitle: const Text('Si lo apagas, "Ahorro total" no cuenta lo que llevas en huchas'),
                    value: settings.showPocketsInTotal,
                    onChanged: (value) async {
                      await ref.read(repositoryProvider).setShowPocketsInTotal(value);
                      ref.invalidate(appSettingsProvider);
                      ref.invalidate(monthResultProvider);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_repeat),
                    title: const Text('Mes de nómina a nómina'),
                    subtitle: Text(
                      settings.monthStartDay == null || settings.monthStartDay == 1
                          ? 'Ahora mismo: mes de calendario (del 1 al último día)'
                          : 'Ahora mismo: ciclo que empieza el día ${settings.monthStartDay} '
                              '(p. ej. el día de tu nómina)',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openMonthStartDaySheet(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Volver a preguntar por el sobrante de caprichos'),
                    subtitle: Text(
                      settings.dismissedTreatSweepYearMonth == null
                          ? 'No hay ningún aviso contestado todavía.'
                          : 'Contestado para ${settings.dismissedTreatSweepYearMonth}. '
                              'Tócalo para que Inicio lo vuelva a preguntar.',
                    ),
                    enabled: settings.dismissedTreatSweepYearMonth != null,
                    onTap: () async {
                      await ref.read(repositoryProvider).resetTreatSweepPrompt();
                      ref.invalidate(appSettingsProvider);
                      ref.invalidate(pendingTreatSweepProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Listo — si hay sobrante sin mover, Inicio volverá a preguntar.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e', style: T.body),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('ACERCA DE', style: T.eyebrow),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            subtitle: const Text('Versión instalada e historial de cambios'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningBalanceSheet extends ConsumerStatefulWidget {
  const _OpeningBalanceSheet();

  @override
  ConsumerState<_OpeningBalanceSheet> createState() => _OpeningBalanceSheetState();
}

class _OpeningBalanceSheetState extends ConsumerState<_OpeningBalanceSheet> {
  final _controller = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  Future<void> _save() async {
    final cents = _parseEuros(_controller.text);
    if (cents == null) return;

    setState(() => _saving = true);

    final monthStartDay = (await ref.read(appSettingsProvider.future)).monthStartDay ?? 1;
    await ref.read(repositoryProvider).setOpeningBalance(
          yearMonth: currentYearMonth(monthStartDay: monthStartDay),
          cents: cents,
        );
    ref.invalidate(currentOpeningBalanceProvider);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentAsync = ref.watch(currentOpeningBalanceProvider);
    final monthStartDay = ref.watch(appSettingsProvider).value?.monthStartDay ?? 1;
    currentAsync.whenData((cents) {
      if (!_prefilled) {
        _prefilled = true;
        if (cents != null) _controller.text = formatCentsPlain(cents);
      }
    });

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SALDO INICIAL', style: T.eyebrow),
            const SizedBox(height: 8),
            Text(
              'El dinero que ya tenías ahorrado justo antes de tu primer '
              'movimiento en la app (mes ${currentYearMonth(monthStartDay: monthStartDay)}). '
              'Se puede corregir más adelante si te equivocas.',
              style: T.meta,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: T.amountLarge,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(suffixText: '€'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_parseEuros(_controller.text) != null && !_saving) ? _save : null,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Editor del margen de caprichos: sustituye el 10 % fijo (`kDefaultTreatRate`)
/// por el valor que el usuario introduzca, guardado como fracción (0.10,
/// 0.15...) en `AppSettings.defaultTreatRate`. Dejarlo en blanco vuelve
/// a activar el 10 % por defecto.
class _TreatRateSheet extends ConsumerStatefulWidget {
  const _TreatRateSheet();

  @override
  ConsumerState<_TreatRateSheet> createState() => _TreatRateSheetState();
}

class _TreatRateSheetState extends ConsumerState<_TreatRateSheet> {
  final _controller = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parsePercent(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value < 0) return null;
    return value / 100;
  }

  Future<void> _save() async {
    final rate = _parsePercent(_controller.text);
    setState(() => _saving = true);

    await ref.read(repositoryProvider).setDefaultTreatRate(rate);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(monthResultProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    settingsAsync.whenData((settings) {
      if (!_prefilled) {
        _prefilled = true;
        final rate = settings.defaultTreatRate ?? kDefaultTreatRate;
        _controller.text = (rate * 100).round().toString();
      }
    });

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MARGEN DE CAPRICHOS', style: T.eyebrow),
            const SizedBox(height: 8),
            const Text(
              'Qué porcentaje de lo que ahorras cada mes va a la bolsa de '
              'caprichos. Por defecto es el 10 %; déjalo en blanco para '
              'volver a ese valor.',
              style: T.meta,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: T.amountLarge,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(suffixText: '%'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hoja para elegir "Mes de nómina a nómina" (`AppSettings.monthStartDay`,
/// doc del 01/09/2026): en que dia del mes "empieza" un mes para TODOS los
/// calculos de la app (Inicio, Movimientos, grafica de ahorro...). Por
/// defecto es el dia 1 (mes de calendario de toda la vida); puesto a otro
/// dia -- el de cobro de la nomina, p. ej. 28 -- un "mes" pasa a ser un
/// ciclo de nomina a nomina en vez de un mes de calendario, y se etiqueta
/// por el mes en el que TERMINA el ciclo (con el dia 28, el 28 de agosto
/// ya cuenta para "septiembre", ver `SavingsRepository.yearMonthOf`).
///
/// Cambiar este valor recalcula el historial entero -- no hay una fecha de
/// "a partir de ahora": movimientos que ya existen (como una nomina que
/// Pol ya cobro) pueden pasar a contar para otro mes del que contaban
/// antes. Es la opcion que Pol pidio expresamente el 01/09/2026, para que
/// el ciclo nuevo tenga margen de caprichos desde el primer dia en vez de
/// dejar un hueco de casi un mes sin margen.
class _MonthStartDaySheet extends ConsumerStatefulWidget {
  const _MonthStartDaySheet();

  @override
  ConsumerState<_MonthStartDaySheet> createState() => _MonthStartDaySheetState();
}

class _MonthStartDaySheetState extends ConsumerState<_MonthStartDaySheet> {
  final _controller = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _parseDay(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 1;
    final value = int.tryParse(trimmed);
    if (value == null || value < 1 || value > 28) return null;
    return value;
  }

  Future<void> _save() async {
    final day = _parseDay(_controller.text);
    if (day == null) return;
    setState(() => _saving = true);

    await ref.read(repositoryProvider).setMonthStartDay(day == 1 ? null : day);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(selectedYearMonthProvider);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);
    ref.invalidate(savingsHistoryProvider);
    ref.invalidate(currentOpeningBalanceProvider);
    ref.invalidate(pocketBalancesProvider);
    ref.invalidate(pocketMovementsProvider);
    ref.invalidate(pendingTreatSweepProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    settingsAsync.whenData((settings) {
      if (!_prefilled) {
        _prefilled = true;
        _controller.text = (settings.monthStartDay ?? 1).toString();
      }
    });

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MES DE NÓMINA A NÓMINA', style: T.eyebrow),
            const SizedBox(height: 8),
            const Text(
              'En qué día del mes "empieza" un mes para la app. Déjalo en 1 '
              'para el mes de calendario de toda la vida, o ponlo en el día '
              'que cobras la nómina (p. ej. 28) para que cada "mes" vaya de '
              'nómina a nómina en vez de de 1 a fin de mes.',
              style: T.meta,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ojo: esto recalcula el historial entero, no solo lo nuevo a '
              'partir de hoy. Movimientos que ya existen (como una nómina '
              'ya cobrada) pueden pasar a contar para otro mes del que '
              'contaban antes.',
              style: T.meta,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: T.amountLarge,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(suffixText: 'día del mes'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

