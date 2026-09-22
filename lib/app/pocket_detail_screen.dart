/// Detalle de una hucha: saldo y progreso hacia la meta (si tiene),
/// mover dinero a mano (meter/sacar), su historial de movimientos, y la
/// aportación automática mensual si la tiene configurada.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import 'pockets_screen.dart';
import 'providers.dart';

const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _periodLabel(int everyNMonths) => switch (everyNMonths) {
      1 => 'Cada mes',
      3 => 'Cada 3 meses',
      6 => 'Cada 6 meses',
      12 => 'Cada año',
      final n => 'Cada $n meses',
    };

/// Evita depender de `package:collection` solo por un `.firstOrNull`
/// (mismo criterio que `adjustment_screen.dart`).
PocketRow? _findPocket(List<PocketRow> pockets, int id) {
  for (final p in pockets) {
    if (p.id == id) return p;
  }
  return null;
}

class PocketDetailScreen extends ConsumerWidget {
  const PocketDetailScreen({super.key, required this.pocketId});

  final int pocketId;

  Future<void> _openMoveSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => _MovePocketMoneySheet(pocketId: pocketId),
    );
  }

  Future<void> _openAddRecurringSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => _AddPocketRecurringSheet(pocketId: pocketId),
    );
  }

  /// Editar nombre/meta (pedido por Pol el 22/09/2026, roadmap punto 20)
  /// -- mismo formulario de alta de `pockets_screen.dart`, precargado.
  Future<void> _openEditSheet(BuildContext context, PocketRow pocket) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => PocketFormSheet(existing: pocket),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, PocketRow pocket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.surface,
        title: const Text('¿Eliminar esta hucha?'),
        content: Text(
          'Se borrará "${pocket.name}" y su historial. El dinero no '
          'desaparece: sigue formando parte de tu ahorro, solo deja de '
          'estar apartado en esta hucha.',
          style: T.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: C.spend)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(repositoryProvider).deletePocket(pocket.id);
    ref.invalidate(pocketsProvider);
    ref.invalidate(pocketBalancesProvider);
    ref.invalidate(pocketRecurringTemplatesProvider);
    ref.invalidate(totalPocketsCentsProvider);

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pocketsAsync = ref.watch(pocketsProvider);
    final balancesAsync = ref.watch(pocketBalancesProvider);
    final movementsAsync = ref.watch(pocketMovementsProvider(pocketId));
    final recurringAsync = ref.watch(pocketRecurringTemplatesProvider);
    final hiddenPocketMovementIds = ref.watch(removedPocketMovementIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hucha'),
        actions: [
          pocketsAsync.maybeWhen(
            data: (pockets) {
              final pocket = _findPocket(pockets, pocketId);
              if (pocket == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar hucha',
                    onPressed: () => _openEditSheet(context, pocket),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Eliminar hucha',
                    onPressed: () => _confirmDelete(context, ref, pocket),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: pocketsAsync.when(
        data: (pockets) {
          final pocket = _findPocket(pockets, pocketId);
          if (pocket == null) {
            return const Center(child: Text('Esta hucha ya no existe.', style: T.body));
          }
          return balancesAsync.when(
            data: (balances) {
              final balance = balances[pocketId] ?? 0;
              final target = pocket.targetCents;
              final reached = target != null && balance >= target;
              final ratio =
                  target == null || target <= 0 ? 0.0 : (balance / target).clamp(0.0, 1.0);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Text(pocket.name, style: T.eyebrow),
                  const SizedBox(height: 4),
                  Text(formatCents(balance), style: T.hero.copyWith(color: C.calm)),
                  if (target != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: C.raised,
                        color: C.calm,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reached
                          ? '¡Meta cumplida! Objetivo: ${formatCents(target)}'
                          : 'Objetivo: ${formatCents(target)}',
                      style: T.meta,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openMoveSheet(context),
                      icon: const Icon(Icons.swap_vert),
                      label: const Text('Meter / sacar dinero'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('APORTACIÓN AUTOMÁTICA', style: T.eyebrow),
                      IconButton(
                        icon: const Icon(Icons.add, color: C.inkDim),
                        onPressed: () => _openAddRecurringSheet(context),
                      ),
                    ],
                  ),
                  recurringAsync.when(
                    data: (all) {
                      final mine = all.where((r) => r.pocketId == pocketId).toList();
                      if (mine.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'No tienes ninguna. Se puede apartar un importe fijo '
                            'cada mes automáticamente, igual que la nómina.',
                            style: T.meta,
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final tpl in mine)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.autorenew, color: C.calm),
                              title: Text(tpl.name, style: T.body),
                              subtitle: Text(
                                '${_periodLabel(tpl.everyNMonths)} · día ${tpl.dayOfMonth}',
                                style: T.meta,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(formatCents(tpl.amountCents), style: T.body),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: C.inkFaint),
                                    onPressed: () async {
                                      await ref
                                          .read(repositoryProvider)
                                          .deletePocketRecurringTemplate(tpl.id);
                                      ref.invalidate(pocketRecurringTemplatesProvider);
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error: $e', style: T.body),
                  ),
                  const SizedBox(height: 24),
                  const Text('MOVIMIENTOS', style: T.eyebrow),
                  const SizedBox(height: 8),
                  movementsAsync.when(
                    data: (movements) {
                      // Ver nota en removedPocketMovementIdsProvider: oculta al
                      // instante lo que se acaba de borrar, sin esperar a que
                      // este FutureProvider se recalcule.
                      final visible = movements
                          .where((m) => !hiddenPocketMovementIds.contains(m.id))
                          .toList();
                      if (visible.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Todavía no hay movimientos en esta hucha.', style: T.meta),
                        );
                      }
                      return Column(
                        children: [
                          for (final m in visible) _PocketMovementTile(pocketId: pocketId, movement: m),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e', style: T.body),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e', style: T.body)),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: T.body)),
      ),
    );
  }
}

/// Una fila del historial de una hucha. Si el movimiento lo genero pagar
/// un gasto con esta hucha (`relatedTransactionId` puesto, ver
/// `Transactions.paidFromPocketId`), NO se puede deslizar para borrarlo
/// aqui: borrarlo solo de este lado dejaria el gasto huerfano en
/// Movimientos (seguiria sin contar para el mes, pero ya sin restar de
/// ninguna hucha tampoco). Ese gasto se edita o se borra desde
/// Movimientos, que mantiene las dos partes sincronizadas.
class _PocketMovementTile extends ConsumerWidget {
  const _PocketMovementTile({required this.pocketId, required this.movement});

  final int pocketId;
  final PocketMovementRow movement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = movement;
    final linkedToExpense = m.relatedTransactionId != null;

    final tile = ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(m.note ?? (m.amountCents >= 0 ? 'Ingreso' : 'Retirada'), style: T.body),
      subtitle: Text(
        '${m.date.day.toString().padLeft(2, '0')}/'
        '${m.date.month.toString().padLeft(2, '0')}/${m.date.year}'
        '${linkedToExpense ? ' · gasto, se edita desde Movimientos' : ''}',
        style: T.meta,
      ),
      trailing: Text(
        formatCentsSigned(m.amountCents),
        style: T.amount.copyWith(color: m.amountCents < 0 ? C.spend : C.calm),
      ),
    );

    if (linkedToExpense) return tile;

    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: C.raised,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: C.inkFaint),
      ),
      onDismissed: (_) async {
        // Ocultamos ya mismo, antes de nada async: es lo que evita el
        // "Dismissible widget is still part of the tree".
        ref.read(removedPocketMovementIdsProvider.notifier).hide(m.id);
        await ref.read(repositoryProvider).deletePocketMovement(m.id);
        ref.invalidate(pocketMovementsProvider(pocketId));
        ref.invalidate(pocketBalancesProvider);
      },
      child: tile,
    );
  }
}

/// Meter o sacar dinero de una hucha a mano — mismo convenio que "Ajustar
/// saldo": dos chips deciden el signo, y aquí el signo va derecho a
/// `amountCents` sin necesidad de simular ningún gasto.
class _MovePocketMoneySheet extends ConsumerStatefulWidget {
  const _MovePocketMoneySheet({required this.pocketId});

  final int pocketId;

  @override
  ConsumerState<_MovePocketMoneySheet> createState() => _MovePocketMoneySheetState();
}

class _MovePocketMoneySheetState extends ConsumerState<_MovePocketMoneySheet> {
  final _input = CentsInput();
  final _noteController = TextEditingController();
  bool _isWithdrawal = false;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => !_input.isEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final note = _noteController.text.trim();
    final amountCents = _isWithdrawal ? -_input.cents : _input.cents;

    await ref.read(repositoryProvider).addPocketMovement(
          pocketId: widget.pocketId,
          amountCents: amountCents,
          date: DateTime.now(),
          note: note.isEmpty ? null : note,
        );
    ref.invalidate(pocketMovementsProvider(widget.pocketId));
    ref.invalidate(pocketBalancesProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('MOVER DINERO', style: T.eyebrow),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Meter dinero'),
                    selected: !_isWithdrawal,
                    onSelected: (_) => setState(() => _isWithdrawal = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Sacar dinero'),
                    selected: _isWithdrawal,
                    onSelected: (_) => setState(() => _isWithdrawal = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(_input.display, style: T.hero, textAlign: TextAlign.center),
            const Text('EUR', style: T.eyebrow, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              style: T.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Nota (opcional)'),
            ),
            const SizedBox(height: 12),
            _PocketKeypad(
              onDigit: (d) => setState(() => _input.pushDigit(d)),
              onDoubleZero: () => setState(() => _input.pushDoubleZero()),
              onBackspace: () => setState(() => _input.backspace()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
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

/// Alta de una aportación automática mensual para una hucha concreta —
/// mismos campos que un recurrente normal (día, cada cuántos meses, mes
/// de inicio) pero sin categoría: el dinero no se gasta.
class _AddPocketRecurringSheet extends ConsumerStatefulWidget {
  const _AddPocketRecurringSheet({required this.pocketId});

  final int pocketId;

  @override
  ConsumerState<_AddPocketRecurringSheet> createState() => _AddPocketRecurringSheetState();
}

class _AddPocketRecurringSheetState extends ConsumerState<_AddPocketRecurringSheet> {
  final _nameController = TextEditingController(text: 'Aportación mensual');
  final _amountController = TextEditingController();
  final _dayController = TextEditingController(text: '1');
  int _everyNMonths = 1;
  int _anchorYear = DateTime.now().year;
  int _anchorMonth = DateTime.now().month;
  bool _saving = false;

  void _shiftAnchor(int delta) {
    setState(() {
      final total = _anchorYear * 12 + (_anchorMonth - 1) + delta;
      if (total < 0) return;
      _anchorYear = total ~/ 12;
      _anchorMonth = (total % 12) + 1;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  int? _parseDay(String input) {
    final n = int.tryParse(input.trim());
    if (n == null) return null;
    return n.clamp(1, 28);
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      ((_parseEuros(_amountController.text) ?? 0) > 0) &&
      _parseDay(_dayController.text) != null &&
      !_saving;

  Future<void> _save() async {
    final cents = _parseEuros(_amountController.text);
    final day = _parseDay(_dayController.text);
    if (!_canSave || cents == null || day == null) return;

    setState(() => _saving = true);

    final anchor =
        '${_anchorYear.toString().padLeft(4, '0')}-${_anchorMonth.toString().padLeft(2, '0')}';

    await ref.read(repositoryProvider).addPocketRecurringTemplate(
          pocketId: widget.pocketId,
          name: _nameController.text.trim(),
          amountCents: cents,
          dayOfMonth: day,
          everyNMonths: _everyNMonths,
          anchorYearMonth: anchor,
        );
    ref.invalidate(pocketRecurringTemplatesProvider);
    ref.invalidate(pocketBalancesProvider);
    ref.invalidate(pocketMovementsProvider(widget.pocketId));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('APORTACIÓN AUTOMÁTICA', style: T.eyebrow),
            const SizedBox(height: 16),
            Text('Nombre', style: T.meta),
            TextField(
              controller: _nameController,
              style: T.body,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Importe', style: T.meta),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: T.amountLarge,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(suffixText: '€'),
            ),
            const SizedBox(height: 16),
            Text('Repetición', style: T.meta),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in [1, 3, 6, 12])
                  ChoiceChip(
                    label: Text(_periodLabel(n)),
                    selected: _everyNMonths == n,
                    onSelected: (_) => setState(() => _everyNMonths = n),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Empieza en', style: T.meta),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftAnchor(-1),
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[_anchorMonth - 1]} $_anchorYear',
                    textAlign: TextAlign.center,
                    style: T.body,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftAnchor(1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Día del mes (1-28)', style: T.meta),
            TextField(
              controller: _dayController,
              keyboardType: TextInputType.number,
              style: T.body,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
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

/// Identico a los demas teclados de la app; se duplica a proposito (ver
/// nota en `edit_movement_screen.dart`).
class _PocketKeypad extends StatelessWidget {
  const _PocketKeypad({
    required this.onDigit,
    required this.onDoubleZero,
    required this.onBackspace,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDoubleZero;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Center(child: Text(label, style: T.amountLarge)),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          key('1', () => onDigit(1)),
          key('2', () => onDigit(2)),
          key('3', () => onDigit(3)),
        ]),
        Row(children: [
          key('4', () => onDigit(4)),
          key('5', () => onDigit(5)),
          key('6', () => onDigit(6)),
        ]),
        Row(children: [
          key('7', () => onDigit(7)),
          key('8', () => onDigit(8)),
          key('9', () => onDigit(9)),
        ]),
        Row(children: [
          key('00', onDoubleZero),
          key('0', () => onDigit(0)),
          key('⌫', onBackspace),
        ]),
      ],
    );
  }
}
