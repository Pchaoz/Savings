/// Ajustes > Accesos rápidos (Fase 3.6): lista lo que ya existe (con
/// opción de borrar) y deja crear accesos nuevos desde una hoja abajo.
/// Solo hace falta nombre, importe y categoría — nada de fecha ni nota,
/// porque un acceso rápido es una plantilla, no un movimiento.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/tables.dart';
import 'providers.dart';

class ManageQuickActionsScreen extends ConsumerWidget {
  const ManageQuickActionsScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, int id) async {
    await ref.read(repositoryProvider).deleteQuickAction(id);
    ref.invalidate(quickActionsProvider);
  }

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const _AddQuickActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(quickActionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accesos rápidos')),
      body: actionsAsync.when(
        data: (actions) {
          if (actions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Todavía no tienes accesos rápidos.\nAñade uno con el botón +.',
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
                itemCount: actions.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: C.line),
                itemBuilder: (context, i) {
                  final a = actions[i];
                  final catName = catById[a.categoryId]?.name ?? '';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt, color: C.go),
                    title: Text(a.label, style: T.body),
                    subtitle: Text(catName, style: T.meta),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatCents(a.amountCents), style: T.body),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: C.inkFaint),
                          onPressed: () => _delete(context, ref, a.id),
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

class _AddQuickActionSheet extends ConsumerStatefulWidget {
  const _AddQuickActionSheet();

  @override
  ConsumerState<_AddQuickActionSheet> createState() => _AddQuickActionSheetState();
}

class _AddQuickActionSheetState extends ConsumerState<_AddQuickActionSheet> {
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();
  CategoryRow? _selectedCategory;
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  bool get _canSave =>
      _labelController.text.trim().isNotEmpty &&
      ((_parseEuros(_amountController.text) ?? 0) > 0) &&
      _selectedCategory != null &&
      !_saving;

  Future<void> _save() async {
    final cents = _parseEuros(_amountController.text);
    final category = _selectedCategory;
    if (!_canSave || cents == null || category == null) return;

    setState(() => _saving = true);

    await ref.read(repositoryProvider).addQuickAction(
          label: _labelController.text.trim(),
          amountCents: cents,
          categoryId: category.id,
        );
    ref.invalidate(quickActionsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(visibleCategoriesProvider);

    // SafeArea + padding de teclado, y todo dentro de un scroll: ya nos
    // hemos encontrado dos veces el mismo overflow (Nuevo gasto, Editar
    // movimiento) al abrirse el teclado del sistema sobre un layout fijo.
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
            const Text('NUEVO ACCESO RÁPIDO', style: T.eyebrow),
            const SizedBox(height: 16),
            Text('Nombre', style: T.meta),
            TextField(
              controller: _labelController,
              style: T.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Ej. Monster'),
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
              // Igual que "Nuevo gasto": esto es para plantillas de
              // gasto, los ingresos no tienen sentido como acceso rapido.
              data: (cats) {
                final options = cats.where((c) => c.kind != CategoryKindDb.income).toList();
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
