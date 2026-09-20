/// Pantalla para editar un movimiento ya existente (doc 08: "si
/// apuntaste mal el importe o la categoria, no elimines, edita"). Mismo
/// teclado y selector de categoria que "Nuevo gasto", pero pre-rellenado
/// y sin accesos rapidos (no tienen sentido al editar).
///
/// La fecha original no se puede tocar aqui a proposito: es la fecha en
/// la que ocurrio de verdad, y este flujo no es para mover un movimiento
/// de un mes a otro. Tampoco se llega nunca a esta pantalla desde una
/// devolucion ni desde un movimiento ya devuelto (movements_screen.dart
/// no lo permite deslizar).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/savings_repository.dart';
import 'providers.dart';

class EditMovementScreen extends ConsumerStatefulWidget {
  const EditMovementScreen({required this.movement, super.key});

  final MovementView movement;

  @override
  ConsumerState<EditMovementScreen> createState() => _EditMovementScreenState();
}

class _EditMovementScreenState extends ConsumerState<EditMovementScreen> {
  late final CentsInput _input;
  late final TextEditingController _noteController;
  CategoryRow? _selectedCategory;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.movement.transaction;
    _input = CentsInput(tx.amountCents.abs());
    _noteController = TextEditingController(text: tx.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => !_input.isEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final category = _selectedCategory ?? widget.movement.category;
    final note = _noteController.text.trim();

    await ref.read(repositoryProvider).updateTransaction(
          transactionId: widget.movement.transaction.id,
          categoryId: category.id,
          amountCents: _input.cents,
          note: note.isEmpty ? null : note,
        );

    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    // Si este gasto se pago con una hucha, `updateTransaction` tambien
    // corrigio el importe del movimiento de esa hucha (ver el repositorio)
    // — hay que invalidar sus providers tambien para que se note al
    // volver atras.
    final pocketId = widget.movement.transaction.paidFromPocketId;
    if (pocketId != null) {
      ref.invalidate(pocketBalancesProvider);
      ref.invalidate(pocketMovementsProvider(pocketId));
      ref.invalidate(totalPocketsCentsProvider);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(visibleCategoriesProvider);
    final tx = widget.movement.transaction;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar movimiento')),
      // SingleChildScrollView, no un Column a pantalla completa: al
      // enfocar "Descripcion" se abre el teclado del sistema y con todo
      // fijo no cabia (mismo "RenderFlex overflowed" que en "Nuevo
      // gasto"). Con esto la pantalla se desplaza en vez de desbordar.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(_formatDate(tx.date), style: T.meta),
              const SizedBox(height: 8),
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
                    hintText: 'Descripción (opcional)',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                // A diferencia de "Nuevo gasto", aqui SI se incluyen las
                // categorias de ingreso: puede que el movimiento a editar
                // sea uno (ej. corregir el importe de la nomina).
                data: (cats) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Si la categoria de este movimiento ya esta
                      // oculta (Ajustes > Categorias), la añadimos igual
                      // al final: si no, el chip seleccionado desaparece
                      // y parece que el movimiento se ha quedado sin
                      // categoria.
                      for (final cat in [
                        ...cats,
                        if (!cats.any((c) => c.id == widget.movement.category.id))
                          widget.movement.category,
                      ])
                        ChoiceChip(
                          label: Text(cat.name),
                          selected: (_selectedCategory?.id ?? widget.movement.category.id) ==
                              cat.id,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                    ],
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('Error: $e')),
                ),
              ),
              _EditKeypad(
                onDigit: (d) => setState(() => _input.pushDigit(d)),
                onDoubleZero: () => setState(() => _input.pushDoubleZero()),
                onBackspace: () => setState(() => _input.backspace()),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canSave ? _save : null,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cambios'),
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

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _formatDate(DateTime d) => '${d.day} de ${_meses[d.month - 1]}';

/// Identico al de "Nuevo gasto"; se duplica a proposito (es un widget
/// pequeño y privado) para no acoplar las dos pantallas entre si.
class _EditKeypad extends StatelessWidget {
  const _EditKeypad({
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
