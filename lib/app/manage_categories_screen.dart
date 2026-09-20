/// Ajustes > Categorías: lista lo que ya existe agrupado por tipo, deja
/// crear categorías nuevas (nombre + tipo) desde una hoja abajo, y
/// ocultar/mostrar las que ya no se usan con el icono del ojo. También
/// deja borrarlas de verdad con el icono de la papelera, pero SOLO si
/// nunca se han llegado a usar (sin movimientos, accesos rápidos ni
/// recurrentes enlazados, y sin ser la última categoría de su tipo) —
/// ver `categoryDeleteBlockReason` en el repositorio. Si ya se ha usado,
/// ocultarla (columna `archived`) es la opción segura: el histórico que
/// ya la usa sigue mostrándose igual, solo deja de ofrecerse para algo
/// nuevo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/tables.dart';
import 'providers.dart';

String _kindLabel(CategoryKindDb kind) => switch (kind) {
      CategoryKindDb.income => 'Ingresos',
      CategoryKindDb.fixed => 'Gastos fijos',
      CategoryKindDb.variable => 'Gastos variables',
      CategoryKindDb.treat => 'Caprichos',
    };

/// Una frase que explica qué hace cada tipo con el dinero, para elegir
/// bien al crear una categoría nueva (ej. un viaje es "variable", no
/// "capricho": no debe salir de la bolsa de caprichos).
String _kindHint(CategoryKindDb kind) => switch (kind) {
      CategoryKindDb.income => 'Suma al dinero que entra este mes (como la nómina).',
      CategoryKindDb.fixed => 'Resta cada mes, un importe parecido (como el alquiler).',
      CategoryKindDb.variable =>
        'Resta este mes, pero no toca la bolsa de caprichos — bien para '
            'gastos grandes y puntuales, como un viaje.',
      CategoryKindDb.treat => 'Sale de la bolsa de caprichos, no del ahorro general.',
    };

/// Duplicado a propósito de `movements_screen.dart` (mismo criterio que
/// el resto de pantallas del proyecto: no acoplar ficheros por un mapa
/// pequeño y privado).
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

const _kindOrder = [
  CategoryKindDb.income,
  CategoryKindDb.fixed,
  CategoryKindDb.variable,
  CategoryKindDb.treat,
];

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => const _AddCategorySheet(),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, CategoryRow cat) async {
    final repo = ref.read(repositoryProvider);
    final blockReason = await repo.categoryDeleteBlockReason(cat.id);

    if (!context.mounted) return;

    if (blockReason != null) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No se puede borrar'),
          content: Text(blockReason),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¿Borrar "${cat.name}"?'),
        content: const Text(
          'No tiene nada enlazado todavía, así que se puede borrar sin '
          'perder ningún histórico. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: C.spend),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await repo.deleteCategory(cat.id);
    ref.invalidate(categoriesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: categoriesAsync.when(
        data: (cats) {
          final byKind = <CategoryKindDb, List<CategoryRow>>{};
          for (final cat in cats) {
            (byKind[cat.kind] ??= []).add(cat);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final kind in _kindOrder)
                if (byKind[kind]?.isNotEmpty ?? false) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                    child: Text(_kindLabel(kind).toUpperCase(), style: T.eyebrow),
                  ),
                  for (final cat in byKind[kind]!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _iconFor(cat.icon),
                        color: cat.archived ? C.inkFaint : C.inkDim,
                      ),
                      title: Text(
                        cat.name,
                        style: T.body.copyWith(color: cat.archived ? C.inkFaint : null),
                      ),
                      subtitle: cat.archived ? const Text('Oculta', style: T.meta) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              cat.archived
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: C.inkFaint,
                            ),
                            tooltip: cat.archived ? 'Mostrar de nuevo' : 'Ocultar',
                            onPressed: () async {
                              await ref
                                  .read(repositoryProvider)
                                  .setCategoryArchived(cat.id, !cat.archived);
                              ref.invalidate(categoriesProvider);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: C.inkFaint),
                            tooltip: 'Borrar',
                            onPressed: () => _handleDelete(context, ref, cat),
                          ),
                        ],
                      ),
                    ),
                ],
            ],
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

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final _nameController = TextEditingController();
  CategoryKindDb _kind = CategoryKindDb.variable;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    await ref.read(repositoryProvider).addCategory(
          name: _nameController.text.trim(),
          kind: _kind,
        );
    ref.invalidate(categoriesProvider);

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
            const Text('NUEVA CATEGORÍA', style: T.eyebrow),
            const SizedBox(height: 16),
            Text('Nombre', style: T.meta),
            TextField(
              controller: _nameController,
              style: T.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Ej. Viajes'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Tipo', style: T.meta),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in CategoryKindDb.values)
                  ChoiceChip(
                    label: Text(_kindLabel(kind)),
                    selected: _kind == kind,
                    onSelected: (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_kindHint(_kind), style: T.meta),
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
