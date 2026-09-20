/// Hoja de "que ha pasado" al eliminar un movimiento (doc 08). La
/// respuesta no es una etiqueta decorativa: decide si se crea una
/// devolucion o si se borra de verdad (en blando).
library;

import 'package:flutter/material.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/savings_repository.dart';

enum _ReasonChoice { refund, mistake, duplicate, other }

class DeleteOutcome {
  const DeleteOutcome.delete(this.reason)
      : isRefund = false,
        refundAmountCents = null,
        refundDate = null;

  const DeleteOutcome.refund({
    required this.refundAmountCents,
    required this.refundDate,
  })  : isRefund = true,
        reason = null;

  final bool isRefund;

  /// 'mistake' / 'duplicate' / 'other'. Solo cuando [isRefund] es false.
  final String? reason;

  final int? refundAmountCents;
  final DateTime? refundDate;
}

/// Muestra la hoja completa (motivo, y si toca, importe+fecha de la
/// devolucion). Devuelve `null` si el usuario cancela en cualquier punto.
Future<DeleteOutcome?> showDeleteMovementSheet(
  BuildContext context,
  MovementView movement,
) async {
  final choice = await showModalBottomSheet<_ReasonChoice>(
    context: context,
    backgroundColor: C.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
    ),
    builder: (_) => _ReasonOptionsSheet(movement: movement),
  );

  if (choice == null) return null;

  if (choice == _ReasonChoice.refund) {
    if (!context.mounted) return null;
    return showModalBottomSheet<DeleteOutcome>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => _RefundDetailsSheet(movement: movement),
    );
  }

  const reasonCodes = {
    _ReasonChoice.mistake: 'mistake',
    _ReasonChoice.duplicate: 'duplicate',
    _ReasonChoice.other: 'other',
  };
  return DeleteOutcome.delete(reasonCodes[choice]!);
}

class _ReasonOptionsSheet extends StatelessWidget {
  const _ReasonOptionsSheet({required this.movement});

  final MovementView movement;

  @override
  Widget build(BuildContext context) {
    final tx = movement.transaction;
    final title = (tx.note != null && tx.note!.trim().isNotEmpty)
        ? tx.note!.trim()
        : movement.category.name;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: T.amountLarge),
            Text(
              '${movement.category.name} · ${formatCents(tx.amountCents.abs())}',
              style: T.meta,
            ),
            const SizedBox(height: 16),
            const Text('¿QUÉ HA PASADO?', style: T.eyebrow),
            const SizedBox(height: 4),
            _OptionTile(
              icon: Icons.undo,
              title: 'Me lo han devuelto',
              subtitle: 'El dinero vuelve a tu bolsa',
              onTap: () => Navigator.of(context).pop(_ReasonChoice.refund),
            ),
            _OptionTile(
              icon: Icons.edit_outlined,
              title: 'Me equivoqué al apuntarlo',
              onTap: () => Navigator.of(context).pop(_ReasonChoice.mistake),
            ),
            _OptionTile(
              icon: Icons.content_copy_outlined,
              title: 'Está repetido',
              onTap: () => Navigator.of(context).pop(_ReasonChoice.duplicate),
            ),
            _OptionTile(
              icon: Icons.more_horiz,
              title: 'Otro motivo',
              onTap: () => Navigator.of(context).pop(_ReasonChoice.other),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: C.ink),
      title: Text(title, style: T.body),
      subtitle: subtitle == null ? null : Text(subtitle!, style: T.meta),
      onTap: onTap,
    );
  }
}

class _RefundDetailsSheet extends StatefulWidget {
  const _RefundDetailsSheet({required this.movement});

  final MovementView movement;

  @override
  State<_RefundDetailsSheet> createState() => _RefundDetailsSheetState();
}

class _RefundDetailsSheetState extends State<_RefundDetailsSheet> {
  late final TextEditingController _amountController;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: formatCentsPlain(widget.movement.transaction.amountCents.abs()),
    );
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.movement.transaction.date,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cents = _parseEuros(_amountController.text);
    final canConfirm = cents != null && cents > 0;

    // SafeArea (solo abajo) para que el boton no quede debajo de los
    // botones virtuales del telefono; se combina con el padding del
    // teclado, que SafeArea no cubre por si solo.
    return SafeArea(
      top: false,
      child: Padding(
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
            const Text('DEVOLUCIÓN', style: T.eyebrow),
            const SizedBox(height: 12),
            Text('Importe devuelto', style: T.meta),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: T.amountLarge,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(suffixText: '€'),
            ),
            const SizedBox(height: 16),
            Text('Fecha', style: T.meta),
            InkWell(
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: C.inkDim),
                    const SizedBox(width: 8),
                    Text(_formatDate(_date), style: T.body),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canConfirm
                    ? () => Navigator.of(context).pop(
                          DeleteOutcome.refund(refundAmountCents: cents, refundDate: _date),
                        )
                    : null,
                child: const Text('Confirmar devolución'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String _formatDate(DateTime d) {
  final today = DateTime.now();
  final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
  final label = '${d.day} ${_meses[d.month - 1]}';
  return isToday ? 'Hoy, $label' : label;
}
