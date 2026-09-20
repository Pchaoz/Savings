/// Ajustes > Ingresos y gastos recurrentes (doc 04: "que la nómina y las
/// suscripciones se metan solas cada mes"). Lista lo que ya existe (con
/// borrado) y deja crear plantillas nuevas desde una hoja abajo: nombre,
/// importe, categoría, periodicidad, día del mes y desde qué mes empieza
/// a tocar (importante para algo trimestral como la T-Jove: si hoy no le
/// toca, hay que poder decir "a partir de octubre" en vez de que el
/// programa la de por debida ya este mes).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/tables.dart';
import 'providers.dart';

/// "Cada mes", "Cada 3 meses"... Se usa tanto en la lista como en la hoja
/// de alta, así que vive en un sitio compartido del fichero.
String _periodLabel(int everyNMonths) => switch (everyNMonths) {
      1 => 'Cada mes',
      3 => 'Cada 3 meses',
      6 => 'Cada 6 meses',
      12 => 'Cada año',
      final n => 'Cada $n meses',
    };

const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// "2026-10" -> "octubre 2026", para que la lista deje ver de un vistazo
/// desde cuando empieza a tocar cada plantilla (doc 04: la T-Jove no
/// empieza el mismo mes en que se da de alta).
String _formatYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final month = int.parse(parts[1]);
  return '${_monthNames[month - 1]} ${parts[0]}';
}

class ManageRecurringScreen extends ConsumerWidget {
  const ManageRecurringScreen({super.key});

  Future<void> _delete(WidgetRef ref, int id) async {
    await ref.read(repositoryProvider).deleteRecurringTemplate(id);
    ref.invalidate(recurringTemplatesProvider);
  }

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const _AddRecurringSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(recurringTemplatesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos y gastos recurrentes')),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Todavía no tienes nada recurrente.\n'
                  'Añade tu nómina o tus suscripciones con el botón +\n'
                  'para que se apunten solas cada mes.',
                  style: T.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return categoriesAsync.when(
            data: (cats) {
              final catById = {for (final c in cats) c.id: c};
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: templates.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: C.line),
                itemBuilder: (context, i) {
                  final tpl = templates[i];
                  final catName = catById[tpl.categoryId]?.name ?? '';
                  final isIncome = catById[tpl.categoryId]?.kind == CategoryKindDb.income;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.autorenew, color: C.calm),
                    title: Text(tpl.name, style: T.body),
                    subtitle: Text(
                      '$catName · ${_periodLabel(tpl.everyNMonths)} · día ${tpl.dayOfMonth} · '
                      'desde ${_formatYearMonth(tpl.anchorYearMonth)}',
                      style: T.meta,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isIncome
                              ? formatCentsSigned(tpl.amountCents)
                              : formatCents(tpl.amountCents),
                          style: T.body,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: C.inkFaint),
                          onPressed: () => _delete(ref, tpl.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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

class _AddRecurringSheet extends ConsumerStatefulWidget {
  const _AddRecurringSheet();

  @override
  ConsumerState<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends ConsumerState<_AddRecurringSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController(text: '1');
  CategoryRow? _selectedCategory;
  int _everyNMonths = 1;
  // Mes desde el que empieza a tocar (doc 04: la T-Jove no se cobra
  // todos los meses, asi que no basta con "el mes en que se crea la
  // plantilla" — Pol tiene que poder decir "a partir de octubre").
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
      _selectedCategory != null &&
      !_saving;

  Future<void> _save() async {
    final cents = _parseEuros(_amountController.text);
    final day = _parseDay(_dayController.text);
    final category = _selectedCategory;
    if (!_canSave || cents == null || day == null || category == null) return;

    setState(() => _saving = true);

    final anchor =
        '${_anchorYear.toString().padLeft(4, '0')}-${_anchorMonth.toString().padLeft(2, '0')}';

    await ref.read(repositoryProvider).addRecurringTemplate(
          name: _nameController.text.trim(),
          categoryId: category.id,
          amountCents: cents,
          dayOfMonth: day,
          everyNMonths: _everyNMonths,
          anchorYearMonth: anchor,
        );
    ref.invalidate(recurringTemplatesProvider);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(visibleCategoriesProvider);

    // Mismo patron que "Nuevo acceso rápido": todo en un scroll para que
    // el teclado del sistema (en Nombre/Importe/Día) nunca desborde el
    // layout, aunque aquí no haya un teclado calculadora fijo de por medio.
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
            const Text('NUEVO RECURRENTE', style: T.eyebrow),
            const SizedBox(height: 16),
            Text('Nombre', style: T.meta),
            TextField(
              controller: _nameController,
              style: T.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Ej. Nómina'),
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
            Text('Categoría', style: T.meta),
            const SizedBox(height: 8),
            categoriesAsync.when(
              // Un capricho es por definición algo puntual: no tiene
              // sentido como plantilla recurrente.
              data: (cats) {
                final options = cats.where((c) => c.kind != CategoryKindDb.treat).toList();
                return Wrap(
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
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: T.body),
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
            Text('Empieza a cobrarse en', style: T.meta),
            const SizedBox(height: 4),
            Text(
              'Por ejemplo, si la T-Jove no toca hasta octubre, muévelo '
              'hasta ahí — si no, el programa la daría por debida ya este mes.',
              style: T.meta,
            ),
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
