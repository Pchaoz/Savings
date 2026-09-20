/// Lista de movimientos del mes que este mirando Inicio
/// (`selectedYearMonthProvider`, mismas flechas), agrupados por dia,
/// siguiendo el diseno del mockup (doc de devoluciones). Deslizar a la
/// izquierda abre el flujo de "que ha pasado" (eliminar o devolver, doc
/// 08); deslizar a la derecha abre editar. Estas dos acciones funcionan
/// igual mirando un mes anterior: corregir un movimiento viejo no tiene
/// nada de especial, es la misma fila de siempre.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/savings_repository.dart';
import '../data/tables.dart';
import 'delete_movement_sheet.dart';
import 'edit_movement_screen.dart';
import 'providers.dart';

/// Evita depender de `package:collection` solo por un `.firstOrNull`
/// (mismo criterio que `adjustment_screen.dart`/`pocket_detail_screen.dart`).
PocketRow? _findPocket(List<PocketRow> pockets, int id) {
  for (final p in pockets) {
    if (p.id == id) return p;
  }
  return null;
}

/// Subtitulo de cada fila: normalmente solo el nombre de la categoria,
/// pero con un aviso si es una devolucion o si el gasto se pago con una
/// hucha en vez de la cuenta principal (ver `Transactions.paidFromPocketId`).
String _subtitleFor(WidgetRef ref, MovementView movement, CategoryRow cat) {
  if (movement.isRefund) return '${cat.name} · vuelve a tu bolsa';

  final pocketId = movement.transaction.paidFromPocketId;
  if (pocketId == null) return cat.name;

  final pocketName = ref.watch(pocketsProvider).maybeWhen(
        data: (pockets) => _findPocket(pockets, pocketId)?.name,
        orElse: () => null,
      );
  // Si la hucha se borro despues, no hay nombre que mostrar — se enseña
  // igual que un gasto normal antes que un mensaje confuso.
  return pocketName == null ? cat.name : '${cat.name} · pagado con $pocketName';
}

const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _formatYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final month = int.parse(parts[1]);
  return '${_monthNames[month - 1]} ${parts[0]}';
}

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYearMonth = ref.watch(selectedYearMonthProvider);
    final movementsAsync = ref.watch(monthMovementsProvider(selectedYearMonth));
    final hiddenIds = ref.watch(removedMovementIdsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Movimientos · ${_formatYearMonth(selectedYearMonth)}')),
      body: SafeArea(
        top: false,
        child: movementsAsync.when(
          data: (movements) {
            // Ver nota en removedMovementIdsProvider: esto oculta al
            // instante lo que acabamos de borrar, sin esperar a que este
            // FutureProvider se recalcule.
            final visible =
                movements.where((m) => !hiddenIds.contains(m.transaction.id)).toList();

            if (visible.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Todavía no hay movimientos en ${_formatYearMonth(selectedYearMonth)}.',
                    style: T.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: _rows(visible),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: T.body)),
        ),
      ),
    );
  }

  List<Widget> _rows(List<MovementView> movements) {
    final widgets = <Widget>[];
    DateTime? lastDay;

    for (final m in movements) {
      final d = m.transaction.date;
      final day = DateTime(d.year, d.month, d.day);
      if (lastDay == null || day != lastDay) {
        widgets.add(_DaySeparator(date: day));
        lastDay = day;
      }
      widgets.add(_MovementTile(movement: m));
    }
    return widgets;
  }
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 4),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: C.line)),
      ),
      child: Text(
        '${date.day} ${_meses[date.month - 1]}'.toUpperCase(),
        style: T.eyebrow,
      ),
    );
  }
}

class _MovementTile extends ConsumerWidget {
  const _MovementTile({required this.movement});

  final MovementView movement;

  /// Si este movimiento se pago con una hucha, invalida tambien sus
  /// providers — ademas de los del dashboard/movimientos de siempre. Se
  /// llama tras devolver, borrar o deshacer un gasto de este tipo (ver
  /// `Transactions.paidFromPocketId`), en todos los casos con el mismo
  /// id de hucha del movimiento original.
  void _invalidatePocketIfAny(WidgetRef ref) {
    final pocketId = movement.transaction.paidFromPocketId;
    if (pocketId == null) return;
    ref.invalidate(pocketBalancesProvider);
    ref.invalidate(pocketMovementsProvider(pocketId));
    ref.invalidate(totalPocketsCentsProvider);
  }

  Future<bool> _handleDismiss(
    BuildContext context,
    WidgetRef ref,
    void Function(String reason) onWillDelete,
  ) async {
    final outcome = await showDeleteMovementSheet(context, movement);
    if (outcome == null) return false;

    final repo = ref.read(repositoryProvider);

    if (outcome.isRefund) {
      // Devolucion: el movimiento se queda en la lista (ahora marcado
      // "DEVUELTO"), asi que no dejamos que Dismissible lo anime fuera.
      await repo.addRefund(
        originalTransactionId: movement.transaction.id,
        amountCents: outcome.refundAmountCents!,
        date: outcome.refundDate!,
      );
      ref.invalidate(monthResultProvider);
      ref.invalidate(monthMovementsProvider);
      _invalidatePocketIfAny(ref);
      return false;
    }

    // Borrado (en blando): dejamos que se anime fuera; el motivo real
    // (duplicado / me equivoque / otro) se guarda en onDismissed, un
    // instante despues, cuando termina la animacion.
    onWillDelete(outcome.reason ?? 'other');
    return true;
  }

  void _handleDismissed(BuildContext context, WidgetRef ref, String reason) {
    final repo = ref.read(repositoryProvider);
    final id = movement.transaction.id;

    // Ocultamos ya mismo, antes de nada async: es lo que evita el
    // "Dismissible widget is still part of the tree" (ver nota en
    // removedMovementIdsProvider).
    ref.read(removedMovementIdsProvider.notifier).hide(id);

    repo.softDelete(id, reason: reason);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);
    _invalidatePocketIfAny(ref);

    final messenger = ScaffoldMessenger.of(context);
    // Quita cualquier aviso anterior que siga en cola antes de mostrar
    // este: si se borran varios movimientos seguidos (deslizando uno
    // tras otro), sin esto los avisos se apilan en cola y da la
    // sensacion de que el mensaje "no se va nunca" — con esto siempre se
    // ve el ultimo, y siempre desaparece solo a los 4 segundos.
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Movimiento eliminado'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await repo.restore(id);
            ref.read(removedMovementIdsProvider.notifier).show(id);
            ref.invalidate(monthResultProvider);
            ref.invalidate(monthMovementsProvider);
            _invalidatePocketIfAny(ref);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = movement.transaction;
    final cat = movement.category;

    // Para ingresos, positivo en la base de datos = dinero que entra.
    // Para todo lo demas, positivo = gasto (se ve como negativo en la
    // lista) y negativo = devolucion (se ve como positivo).
    final displayCents = cat.kind == CategoryKindDb.income ? tx.amountCents : -tx.amountCents;

    final title = (tx.note != null && tx.note!.trim().isNotEmpty) ? tx.note!.trim() : cat.name;
    final wasRefunded = movement.hasBeenRefunded;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            _iconFor(cat.icon),
            size: 17,
            color: wasRefunded ? C.inkFaint : C.ink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: T.body.copyWith(color: wasRefunded ? C.inkDim : C.ink),
                    ),
                  ),
                  if (wasRefunded) ...[
                    const SizedBox(width: 6),
                    const _Tag(label: 'DEVUELTO'),
                  ],
                ],
              ),
              Text(_subtitleFor(ref, movement, cat), style: T.meta),
            ],
          ),
        ),
        Text(
          formatCentsSigned(displayCents),
          style: T.amount.copyWith(
            color: displayCents < 0 ? C.spend : C.ink,
            decoration: wasRefunded ? TextDecoration.lineThrough : null,
            decorationColor: C.inkFaint,
          ),
        ),
      ],
    );

    // Las devoluciones van sangradas, para leerse como colgadas de su
    // compra en vez de como un movimiento suelto (doc 08).
    final tile = Padding(
      padding: movement.isRefund
          ? const EdgeInsets.only(left: 30, top: 2, bottom: 10)
          : const EdgeInsets.symmetric(vertical: 8),
      child: row,
    );

    // Un movimiento que ya tiene su devolucion, o que ES una devolucion,
    // no se puede volver a eliminar/devolver desde aqui (doc 08).
    if (wasRefunded || movement.isRefund) {
      return tile;
    }

    // Compartida entre confirmDismiss y onDismissed: no hay ningun
    // rebuild entre medias para el camino de borrado, asi que sigue
    // viva hasta que onDismissed la lee.
    String? pendingDeleteReason;

    return Dismissible(
      key: ValueKey('tx-${tx.id}'),
      // Derecha = editar (doc 08), izquierda = eliminar/devolver.
      direction: DismissDirection.horizontal,
      // Editar: se abre la pantalla pero el movimiento nunca se anima
      // fuera (confirmDismiss siempre devuelve false para este lado).
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 18),
        color: C.raised,
        child: const Icon(Icons.edit_outlined, color: C.inkDim),
      ),
      // Neutro a proposito: en este punto todavia no sabemos si va a
      // terminar en devolucion o en borrado (eso se decide en la hoja de
      // "que ha pasado"), asi que evitamos el rojo/papelera que sugeriria
      // borrado antes de tiempo.
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        color: C.raised,
        child: const Icon(Icons.more_horiz, color: C.inkDim),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditMovementScreen(movement: movement)),
          );
          return false;
        }
        return _handleDismiss(
          context,
          ref,
          (reason) => pendingDeleteReason = reason,
        );
      },
      onDismissed: (_) => _handleDismissed(context, ref, pendingDeleteReason ?? 'other'),
      child: tile,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: C.line),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: C.inkFaint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

IconData _iconFor(String name) => switch (name) {
      'work' => Icons.work_outline,
      'add_card' => Icons.add_card,
      'payments' => Icons.payments_outlined,
      'home' => Icons.home_outlined,
      'bolt' => Icons.bolt,
      'water_drop' => Icons.water_drop_outlined,
      'local_fire_department' => Icons.local_fire_department_outlined,
      'wifi' => Icons.wifi,
      'subscriptions' => Icons.subscriptions_outlined,
      'shield' => Icons.shield_outlined,
      'directions_bus' => Icons.directions_bus_outlined,
      'shopping_cart' => Icons.shopping_cart_outlined,
      'restaurant' => Icons.restaurant_outlined,
      'checkroom' => Icons.checkroom_outlined,
      'directions_car' => Icons.directions_car_outlined,
      'category' => Icons.category_outlined,
      'celebration' => Icons.celebration_outlined,
      'flight' => Icons.flight_outlined,
      'balance' => Icons.balance,
      _ => Icons.receipt_outlined,
    };
