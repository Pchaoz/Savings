/// Pantalla para apuntar un movimiento puntual: accesos rapidos de un
/// toque arriba (tabla QuickActions, solo para gastos), y teclado +
/// categoria + nota debajo para todo lo demas. Un interruptor
/// Gasto/Ingreso decide que categorias se ofrecen — esto es para
/// ingresos puntuales que NO deben repetirse cada mes (una venta de
/// Wallapop, un reembolso suelto...); si de verdad se repite todos los
/// meses, va en Ajustes > Ingresos y gastos recurrentes en su lugar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/tables.dart';
import 'providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _input = CentsInput();
  final _noteController = TextEditingController();
  CategoryRow? _selectedCategory;
  bool _isIncome = false;
  bool _saving = false;

  /// Null = pagar con la "cuenta principal" (de siempre). Puesto = de
  /// donde sale el dinero de verdad (p. ej. gastar de "Ahorro Japón" los
  /// vuelos, en vez de que cuente como un gasto normal de este mes).
  int? _payFromPocketId;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => !_input.isEmpty && _selectedCategory != null && !_saving;

  Future<void> _save() async {
    final category = _selectedCategory;
    if (!_canSave || category == null) return;

    setState(() => _saving = true);

    final note = _noteController.text.trim();
    final pocketId = _payFromPocketId;
    if (pocketId != null) {
      await ref.read(repositoryProvider).addExpenseFromPocket(
            categoryId: category.id,
            amountCents: _input.cents,
            date: DateTime.now(),
            pocketId: pocketId,
            note: note.isEmpty ? null : note,
          );
      // Ademas del dashboard/movimientos de siempre, este gasto tambien
      // cambia el saldo de la hucha elegida.
      ref.invalidate(pocketBalancesProvider);
      ref.invalidate(pocketMovementsProvider(pocketId));
      ref.invalidate(totalPocketsCentsProvider);
    } else {
      await ref.read(repositoryProvider).addTransaction(
            categoryId: category.id,
            amountCents: _input.cents,
            date: DateTime.now(),
            note: note.isEmpty ? null : note,
          );
    }

    // El dashboard y la lista de movimientos escuchan estos providers: al
    // invalidarlos, en cuanto volvamos atras se recalculan solos con el
    // nuevo movimiento incluido.
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  /// Guarda un acceso rapido al instante: sin pasar por el teclado ni por
  /// el selector de categoria. Esto es lo que hace que apuntar un gasto
  /// frecuente sean de verdad 2 toques (el "+" de la pantalla anterior y
  /// este).
  Future<void> _saveQuickAction(QuickActionRow action) async {
    if (_saving) return;
    setState(() => _saving = true);

    // Respeta "Pagar con" si ya se habia elegido una hucha antes de tocar
    // el acceso rapido — si no, seria facil elegir la hucha y que un
    // toque en un acceso rapido la ignore en silencio.
    final pocketId = _payFromPocketId;
    if (pocketId != null) {
      await ref.read(repositoryProvider).addExpenseFromPocket(
            categoryId: action.categoryId,
            amountCents: action.amountCents,
            date: DateTime.now(),
            pocketId: pocketId,
            note: action.label,
          );
      ref.invalidate(pocketBalancesProvider);
      ref.invalidate(pocketMovementsProvider(pocketId));
      ref.invalidate(totalPocketsCentsProvider);
    } else {
      await ref.read(repositoryProvider).addTransaction(
            categoryId: action.categoryId,
            amountCents: action.amountCents,
            date: DateTime.now(),
            note: action.label,
          );
    }
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(visibleCategoriesProvider);
    final quickActionsAsync = ref.watch(quickActionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isIncome ? 'Nuevo ingreso' : 'Nuevo gasto')),
      // SingleChildScrollView en vez de un Column a pantalla completa: al
      // enfocar "Descripcion" se abre el teclado del sistema (no el
      // calculadora de mas abajo), y con todo fijo en una Column no cabia
      // ("RenderFlex overflowed"). Con esto la pantalla simplemente se
      // desplaza para que el campo enfocado quede visible.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Gasto')),
                  ButtonSegment(value: true, label: Text('Ingreso')),
                ],
                selected: {_isIncome},
                onSelectionChanged: (selection) => setState(() {
                  _isIncome = selection.first;
                  _selectedCategory = null;
                  _payFromPocketId = null;
                }),
              ),
            ),
            if (!_isIncome)
            quickActionsAsync.when(
              data: (actions) => actions.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: actions.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final a = actions[i];
                            return ActionChip(
                              avatar: const Icon(Icons.bolt, size: 16, color: C.go),
                              label: Text('${a.label} · ${formatCents(a.amountCents)}'),
                              onPressed: _saving ? null : () => _saveQuickAction(a),
                            );
                          },
                        ),
                      ),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
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
                  hintText: 'Descripción (opcional)',
                ),
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (cats) {
                // El interruptor de arriba decide que categorias tienen
                // sentido: un ingreso puntual va a una categoria de
                // ingreso (Otros ingresos, Ingresos extra...), un gasto a
                // cualquier otra.
                final options = cats
                    .where((c) => _isIncome
                        ? c.kind == CategoryKindDb.income
                        : c.kind != CategoryKindDb.income)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final cat in options)
                        ChoiceChip(
                          label: Text(cat.name),
                          selected: _selectedCategory?.id == cat.id,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error: $e')),
              ),
            ),
            // Solo para gastos: un ingreso puntual siempre entra en la
            // cuenta principal, no tiene sentido "cobrar de una hucha".
            if (!_isIncome)
              ref.watch(pocketsProvider).maybeWhen(
                    data: (pockets) => pockets.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PAGAR CON', style: T.eyebrow),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Cuenta principal'),
                                      selected: _payFromPocketId == null,
                                      onSelected: (_) =>
                                          setState(() => _payFromPocketId = null),
                                    ),
                                    for (final p in pockets)
                                      ChoiceChip(
                                        avatar: const Icon(Icons.savings_outlined, size: 16),
                                        label: Text(p.name),
                                        selected: _payFromPocketId == p.id,
                                        onSelected: (_) =>
                                            setState(() => _payFromPocketId = p.id),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
            _Keypad(
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
                      : const Text('Guardar'),
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

/// Teclado tipo calculadora de caja: los digitos entran por la derecha
/// (ver `CentsInput` en core/money.dart).
class _Keypad extends StatelessWidget {
  const _Keypad({
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
