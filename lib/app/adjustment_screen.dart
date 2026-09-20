/// Ajustes > Ajustar saldo: para corregir descuadres entre lo que
/// calcula la app y el saldo real (dinero olvidado, comisiones del
/// banco, un error al migrar los datos de partida...). No es un gasto ni
/// un ingreso normal — esos van en "Nuevo gasto" o se generan solos. Todo
/// lo que se guarda aquí usa siempre la categoría "Ajuste de cuadre"
/// (creada sola por la migración v4), así se distingue de un vistazo en
/// Movimientos, y luego se edita o se borra exactamente igual que
/// cualquier otro movimiento si más tarde encuentras la cifra correcta.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import 'providers.dart';

const _ajusteCategoryName = 'Ajuste de cuadre';

CategoryRow? _findAdjustmentCategory(List<CategoryRow> cats) {
  for (final c in cats) {
    if (c.name == _ajusteCategoryName) return c;
  }
  return null;
}

class AdjustmentScreen extends ConsumerStatefulWidget {
  const AdjustmentScreen({super.key});

  @override
  ConsumerState<AdjustmentScreen> createState() => _AdjustmentScreenState();
}

class _AdjustmentScreenState extends ConsumerState<AdjustmentScreen> {
  final _input = CentsInput();
  final _noteController = TextEditingController();

  /// false = me falta dinero (el saldo real es MENOR que el calculado,
  /// se comporta como un gasto). true = me sobra dinero (el saldo real
  /// es MAYOR, se comporta como una devolución: importe negativo, doc 08).
  bool _isSurplus = false;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => !_input.isEmpty && !_saving;

  Future<void> _save(int categoryId) async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final note = _noteController.text.trim();
    final amountCents = _isSurplus ? -_input.cents : _input.cents;

    await ref.read(repositoryProvider).addTransaction(
          categoryId: categoryId,
          amountCents: amountCents,
          date: DateTime.now(),
          note: note.isEmpty ? null : note,
        );
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustar saldo')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Solo para corregir descuadres entre lo que calcula la '
                  'app y tu saldo real — para gastos o ingresos normales '
                  'usa "Nuevo gasto".',
                  style: T.meta,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Me falta dinero'),
                        selected: !_isSurplus,
                        onSelected: (_) => setState(() => _isSurplus = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Me sobra dinero'),
                        selected: _isSurplus,
                        onSelected: (_) => setState(() => _isSurplus = true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(_input.display, style: T.hero, textAlign: TextAlign.center),
              const Text('EUR', style: T.eyebrow, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _noteController,
                  style: T.body,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Motivo (opcional, ej. "comisión del banco")',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _AdjustmentKeypad(
                onDigit: (d) => setState(() => _input.pushDigit(d)),
                onDoubleZero: () => setState(() => _input.pushDoubleZero()),
                onBackspace: () => setState(() => _input.backspace()),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: categoriesAsync.when(
                    data: (cats) {
                      final category = _findAdjustmentCategory(cats);
                      return FilledButton(
                        onPressed:
                            (_canSave && category != null) ? () => _save(category.id) : null,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(category == null ? 'Categoría no disponible' : 'Guardar'),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e', style: T.body),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Identico a los demas teclados de la app; se duplica a proposito (ver
/// nota en `edit_movement_screen.dart`).
class _AdjustmentKeypad extends StatelessWidget {
  const _AdjustmentKeypad({
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
