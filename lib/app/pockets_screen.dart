/// Ajustes > Huchas de ahorro: bolsas de ahorro con nombre propio (ej.
/// "Ahorro Japón", "Ahorro coche") para separar dinero dentro de tu
/// ahorro general sin que cuente como gasto. Lista lo que ya existe con
/// su saldo y, si tiene meta, una barra de progreso; el color es azul
/// (C.calm, "ahorro") y no verde — el verde del documento de diseño es
/// solo para la bolsa de caprichos.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import 'pocket_detail_screen.dart';
import 'providers.dart';

class PocketsScreen extends ConsumerWidget {
  const PocketsScreen({super.key});

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const PocketFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pocketsAsync = ref.watch(pocketsProvider);
    final balancesAsync = ref.watch(pocketBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Huchas de ahorro')),
      body: pocketsAsync.when(
        data: (pockets) {
          if (pockets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Todavía no tienes huchas.\n'
                  'Crea una con el botón + — por ejemplo "Ahorro Japón".',
                  style: T.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return balancesAsync.when(
            data: (balances) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: pockets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final pocket = pockets[i];
                final balance = balances[pocket.id] ?? 0;
                return _PocketCard(pocket: pocket, balanceCents: balance);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e', style: T.body)),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: T.body)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PocketCard extends StatelessWidget {
  const _PocketCard({required this.pocket, required this.balanceCents});

  final PocketRow pocket;
  final int balanceCents;

  @override
  Widget build(BuildContext context) {
    final target = pocket.targetCents;
    final reached = target != null && balanceCents >= target;
    final ratio = target == null || target <= 0 ? 0.0 : (balanceCents / target).clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(R.container),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PocketDetailScreen(pocketId: pocket.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(R.container),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(pocket.name, style: T.body)),
                if (reached) const Icon(Icons.emoji_events, color: C.calm, size: 18),
                if (reached) const SizedBox(width: 6),
                Text(formatCents(balanceCents), style: T.amountLarge.copyWith(color: C.calm)),
              ],
            ),
            if (target != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: C.raised,
                  color: C.calm,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reached
                    ? '¡Meta cumplida! Objetivo: ${formatCents(target)}'
                    : 'Objetivo: ${formatCents(target)}',
                style: T.meta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Formulario de alta Y edicion de una hucha -- mismo formulario en los
/// dos casos, precargado con nombre/meta de [existing] cuando se abre
/// para editar (pedido por Pol el 22/09/2026, roadmap punto 20). El
/// saldo nunca se toca aqui: eso solo cambia metiendo/sacando dinero de
/// verdad desde el detalle de la hucha. Publica (sin `_`) a proposito:
/// `pocket_detail_screen.dart` tambien la usa, para editar desde el
/// icono de lapiz en el detalle.
class PocketFormSheet extends ConsumerStatefulWidget {
  const PocketFormSheet({super.key, this.existing});

  final PocketRow? existing;

  @override
  ConsumerState<PocketFormSheet> createState() => _PocketFormSheetState();
}

class _PocketFormSheetState extends ConsumerState<PocketFormSheet> {
  late final _nameController = TextEditingController(text: widget.existing?.name ?? '');
  late final _targetController = TextEditingController(
    text: widget.existing?.targetCents == null
        ? ''
        : formatCentsPlain(widget.existing!.targetCents!),
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final existing = widget.existing;
    if (existing == null) {
      await ref.read(repositoryProvider).addPocket(
            name: _nameController.text.trim(),
            targetCents: _parseEuros(_targetController.text),
          );
    } else {
      await ref.read(repositoryProvider).updatePocket(
            id: existing.id,
            name: _nameController.text.trim(),
            targetCents: _parseEuros(_targetController.text),
          );
    }
    ref.invalidate(pocketsProvider);
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
            Text(widget.existing == null ? 'NUEVA HUCHA' : 'EDITAR HUCHA', style: T.eyebrow),
            const SizedBox(height: 16),
            Text('Nombre', style: T.meta),
            TextField(
              controller: _nameController,
              style: T.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Ej. Ahorro Japón'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Meta (opcional)', style: T.meta),
            TextField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: T.amountLarge,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(suffixText: '€', hintText: 'Déjalo en blanco si no quieres meta'),
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
