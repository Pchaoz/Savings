/// Papelera (Ajustes > Papelera, doc 08): movimientos eliminados en los
/// últimos 30 días, con opción de restaurar. Pasados los 30 días se
/// purgan de verdad (ver `purgeExpiredTrash` en `savings_repository.dart`,
/// que se llama justo antes de leer la lista).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/savings_repository.dart';
import '../data/tables.dart';
import 'providers.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashedAsync = ref.watch(trashedMovementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Papelera')),
      body: SafeArea(
        top: false,
        child: trashedAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'La papelera está vacía.',
                    style: T.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: C.line),
              itemBuilder: (context, i) => _TrashTile(movement: items[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: T.body)),
        ),
      ),
    );
  }
}

class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.movement});

  final MovementView movement;

  static const _reasonLabels = {
    'mistake': 'Error al apuntarlo',
    'duplicate': 'Estaba repetido',
    'other': 'Otro motivo',
  };

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final id = movement.transaction.id;
    final repo = ref.read(repositoryProvider);

    await repo.restore(id);
    // Por si se borró en esta misma sesión y sigue en el set de ocultos
    // de la lista de movimientos (ver removedMovementIdsProvider).
    ref.read(removedMovementIdsProvider.notifier).show(id);

    ref.invalidate(trashedMovementsProvider);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      // Mismo motivo que en Movimientos: si se restauran varios seguidos,
      // sin esto los avisos se apilan en cola en vez de desaparecer solos.
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Movimiento restaurado'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = movement.transaction;
    final cat = movement.category;

    final displayCents = cat.kind == CategoryKindDb.income ? tx.amountCents : -tx.amountCents;
    final title = (tx.note != null && tx.note!.trim().isNotEmpty) ? tx.note!.trim() : cat.name;
    final reasonLabel = _reasonLabels[tx.deleteReason] ?? 'Eliminado';
    final daysLeft = (30 - DateTime.now().difference(tx.deletedAt!).inDays).clamp(0, 30);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
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
            child: Icon(_iconFor(cat.icon), size: 17, color: C.inkFaint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: T.body.copyWith(color: C.inkDim),
                ),
                Text(
                  '$reasonLabel · quedan $daysLeft días',
                  style: T.meta,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCentsSigned(displayCents),
                style: T.amount.copyWith(color: C.inkDim),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _restore(context, ref),
                child: const Text('Restaurar'),
              ),
            ],
          ),
        ],
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
