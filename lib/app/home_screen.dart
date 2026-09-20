/// Pantalla de Inicio (doc 04 + doc 07): además de la bolsa de caprichos,
/// el panorama completo de dinero — ahorro total, lo ganado, patrimonio
/// total y en qué se ha ido el dinero fijo/variable, con flechas arriba
/// para mirar cualquier mes anterior (`selectedYearMonthProvider`,
/// compartido con Movimientos). El botón de "+" para apuntar un
/// movimiento solo aparece en el mes en curso — no tiene sentido apuntar
/// nada "en agosto" con la fecha de hoy si ya estamos en septiembre.
///
/// Los colores respetan la regla del documento de tokens: el verde es
/// solo de la bolsa de caprichos, el ahorro va en azul (C.calm), y solo se
/// tiñe de "gasto" (C.spend) lo que de verdad resta ahorro (un mes en
/// pérdidas).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../core/treat_widget_bridge.dart';
import '../data/database.dart';
import '../domain/models/models.dart';
import 'add_expense_screen.dart';
import 'movements_screen.dart';
import 'pockets_screen.dart';
import 'providers.dart';
import 'savings_chart_screen.dart';
import 'settings_screen.dart';

const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _formatYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final month = int.parse(parts[1]);
  return '${_monthNames[month - 1]} ${parts[0]}';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYearMonth = ref.watch(selectedYearMonthProvider);
    final appSettings = ref.watch(appSettingsProvider).value;
    final isCurrentMonth = selectedYearMonth ==
        currentYearMonth(monthStartDay: appSettings?.monthStartDay ?? 1);
    final monthResult = ref.watch(monthResultProvider(selectedYearMonth));
    // Widget de pantalla de inicio (bolsa de caprichos disponible): solo
    // se manda al lado nativo cuando se esta mirando el mes en curso (un
    // mes pasado no representa "lo que tienes disponible ahora"), y solo
    // cuando el dato cambia de verdad -- `ref.listen` no dispara en cada
    // rebuild, a diferencia de llamarlo a mano dentro del `.when(data: ...)`.
    ref.listen<AsyncValue<MonthResult>>(monthResultProvider(selectedYearMonth), (previous, next) {
      if (!isCurrentMonth) return;
      final result = next.value;
      if (result == null) return;
      TreatWidgetBridge.updateAmount(
        amountText: formatCents(result.bagClosingCents),
        overspent: result.bagClosingCents < 0,
        spentRatio: result.bagSpentRatio,
      );
    });
    final showPocketsInTotal = appSettings?.showPocketsInTotal ?? true;
    final totalPockets = ref.watch(totalPocketsCentsProvider).value ?? 0;
    final pendingSweep = ref.watch(pendingTreatSweepProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Huchas de ahorro',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PocketsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Evolución del ahorro',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavingsChartScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Movimientos',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MovementsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: monthResult.when(
          data: (r) {
            // Con huchas: el saldo de las huchas es SIEMPRE el de ahora
            // (no hay historico por mes), asi que mezclarlo con el cierre
            // de un mes pasado daria una cifra falsa. Se resta / se enseña
            // solo mirando el mes en curso; un mes anterior enseña siempre
            // su cierre real, sin ajustar.
            final totalAhorro = (isCurrentMonth && !showPocketsInTotal)
                ? r.closingBalanceCents - totalPockets
                : r.closingBalanceCents;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Mes anterior',
                        onPressed: () => ref.read(selectedYearMonthProvider.notifier).shift(-1),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_formatYearMonth(selectedYearMonth).toUpperCase(), style: T.eyebrow),
                          if (!isCurrentMonth)
                            GestureDetector(
                              onTap: () => ref.read(selectedYearMonthProvider.notifier).resetToCurrent(),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text('Volver al mes actual', style: T.meta),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Mes siguiente',
                        onPressed: isCurrentMonth
                            ? null
                            : () => ref.read(selectedYearMonthProvider.notifier).shift(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isCurrentMonth && pendingSweep != null) ...[
                    _TreatSweepBanner(
                      amountCents: pendingSweep.$1,
                      previousYearMonth: pendingSweep.$2,
                      hasPockets: pendingSweep.$3,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _TreatBagCard(result: r),
                  const SizedBox(height: 16),
                  Text('Patrimonio total: ${formatCents(r.netWorthCents)}', style: T.meta),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'AHORRO TOTAL',
                          value: formatCents(totalAhorro),
                          color: C.calm,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'GANADO',
                          value: formatCentsSigned(r.savedCents),
                          color: r.savedCents >= 0 ? C.calm : C.spend,
                        ),
                      ),
                    ],
                  ),
                  if (isCurrentMonth) ...[
                    const SizedBox(height: 8),
                    Text(
                      'En huchas: ${formatCents(totalPockets)}'
                      '${showPocketsInTotal ? '' : ' (aparte del ahorro total)'}',
                      style: T.meta,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _BreakdownCard(result: r),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $e', style: T.body),
          ),
        ),
      ),
      floatingActionButton: isCurrentMonth
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// La caja tintada de verde que mencionaba el documento de tokens ("la
/// unica superficie tenida de la pantalla de inicio") pero que hasta
/// ahora no se usaba. Muestra el importe grande de siempre más, debajo,
/// una barra de cuánto llevas gastado del presupuesto disponible.
class _TreatBagCard extends StatelessWidget {
  const _TreatBagCard({required this.result});

  final MonthResult result;

  @override
  Widget build(BuildContext context) {
    final ratio = result.bagSpentRatio.clamp(0.0, 1.0);
    final overspent = result.bagClosingCents < 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: C.goTint,
        border: Border.all(color: C.goEdge),
        borderRadius: BorderRadius.circular(R.container),
      ),
      child: Column(
        children: [
          const Text('A CAPRICHOS', style: T.eyebrow),
          const SizedBox(height: 4),
          Text(
            formatCents(result.bagClosingCents),
            key: const Key('bagAmount'),
            style: T.hero.copyWith(color: overspent ? C.spend : C.go),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: C.raised,
              color: overspent ? C.spend : C.go,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gastado ${formatCents(result.bagSpentCents)} de '
            '${formatCents(result.bagAvailableCents)} disponibles',
            style: T.meta,
          ),
        ],
      ),
    );
  }
}

/// Una cifra secundaria con su etiqueta, para el ahorro total y lo
/// ganado este mes. No es un `Card` con sombra a propósito — encaja
/// mejor con el resto de la app, que no usa elevación.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(R.container),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: T.eyebrow),
          const SizedBox(height: 6),
          Text(value, style: T.amountLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Desglose de gastos fijos y variables del mes — no tocan la bolsa de
/// caprichos, pero son la parte del Excel que más se mira para saber en
/// qué se ha ido el dinero.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.result});

  final MonthResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(R.container),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GASTOS DEL MES', style: T.eyebrow),
          const SizedBox(height: 12),
          _BreakdownRow(label: 'Ingresos', value: formatCentsSigned(result.incomeCents)),
          const SizedBox(height: 8),
          _BreakdownRow(label: 'Fijos', value: formatCentsSigned(-result.fixedCents)),
          const SizedBox(height: 8),
          _BreakdownRow(label: 'Variables', value: formatCentsSigned(-result.variableCents)),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: T.body),
        Text(value, style: T.amount),
      ],
    );
  }
}

/// Aviso de "cambio de mes" (ver `pendingTreatSweepProvider`): solo
/// aparece si el mes anterior cerro con algo sin gastar en la bolsa de
/// caprichos y todavia no se ha contestado este mes. Nunca mueve nada
/// sin que el usuario lo confirme aqui mismo.
///
/// **Bug corregido el 01/09/2026**: hasta ahora, sin ninguna hucha
/// creada todavia, este aviso no aparecia nunca (se suprimia entero) --
/// asi que si borrabas tu unica hucha, o todavia no habias creado
/// ninguna, no habia forma de enterarte de que tenias sobrante
/// esperando. Ahora, sin huchas, aparece igual pero invitando a crear
/// una primero en vez de ofrecer el selector.
class _TreatSweepBanner extends ConsumerWidget {
  const _TreatSweepBanner({
    required this.amountCents,
    required this.previousYearMonth,
    required this.hasPockets,
  });

  final int amountCents;
  final String previousYearMonth;
  final bool hasPockets;

  Future<void> _openPocketPicker(BuildContext context, WidgetRef ref) async {
    final pockets = await ref.read(pocketsProvider.future);
    if (!context.mounted) return;

    final chosen = await showModalBottomSheet<PocketRow>(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.container)),
      ),
      builder: (_) => _PocketPickerSheet(pockets: pockets, amountCents: amountCents),
    );
    if (chosen == null || !context.mounted) return;

    await ref.read(repositoryProvider).sweepTreatBagToPocket(
          pocketId: chosen.id,
          amountCents: amountCents,
          pocketName: chosen.name,
        );

    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);
    ref.invalidate(pocketBalancesProvider);
    ref.invalidate(pocketMovementsProvider(chosen.id));
    ref.invalidate(totalPocketsCentsProvider);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(pendingTreatSweepProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${formatCents(amountCents)} movidos a "${chosen.name}".')),
      );
    }
  }

  Future<void> _dismiss(WidgetRef ref) async {
    final monthStartDay = ref.read(appSettingsProvider).value?.monthStartDay ?? 1;
    await ref
        .read(repositoryProvider)
        .dismissTreatSweepPrompt(currentYearMonth(monthStartDay: monthStartDay));
    ref.invalidate(appSettingsProvider);
    ref.invalidate(pendingTreatSweepProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.calm.withValues(alpha: 0.10),
        border: Border.all(color: C.calm.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(R.container),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasPockets
                ? 'Te sobraron ${formatCents(amountCents)} de caprichos en '
                    '${_formatYearMonth(previousYearMonth)}. ¿Los movemos a una hucha, '
                    'o prefieres que se sigan acumulando este mes?'
                : 'Te sobraron ${formatCents(amountCents)} de caprichos en '
                    '${_formatYearMonth(previousYearMonth)}, pero todavía no tienes '
                    'ninguna hucha donde guardarlos. Puedes crear una, o dejar que se '
                    'sigan acumulando este mes.',
            style: T.body,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => _dismiss(ref),
                child: const Text('Seguir acumulando'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: hasPockets
                    ? () => _openPocketPicker(context, ref)
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PocketsScreen()),
                        ),
                child: Text(hasPockets ? 'Mover a una hucha' : 'Crear hucha'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Elegir a que hucha mandar el sobrante. Solo lista: no permite crear
/// una hucha nueva desde aqui a proposito, para no complicar un flujo que
/// deberia ser de un par de toques -- si Pol no tiene todavia la hucha
/// que quiere, la crea desde Ajustes y el aviso le sigue esperando
/// (no se marca como contestado hasta que elige algo o pulsa "Seguir
/// acumulando").
class _PocketPickerSheet extends ConsumerWidget {
  const _PocketPickerSheet({required this.pockets, required this.amountCents});

  final List<PocketRow> pockets;
  final int amountCents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(pocketBalancesProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mover ${formatCents(amountCents)} a...', style: T.amountLarge),
            const SizedBox(height: 8),
            for (final pocket in pockets)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.savings_outlined, color: C.calm),
                title: Text(pocket.name),
                subtitle: Text(formatCents(balancesAsync.value?[pocket.id] ?? 0)),
                onTap: () => Navigator.of(context).pop(pocket),
              ),
          ],
        ),
      ),
    );
  }
}
