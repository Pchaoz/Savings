/// Evolución del ahorro (Fase 5, doc 04): una única línea con el saldo de
/// cierre de cada mes, a propósito "simple" y no una gráfica elaborada
/// (fuera de alcance por diseño, ver doc 04) — sin ejes con números, sin
/// zoom, sin tooltips por punto. Solo sirve para ver de un vistazo si la
/// tendencia de los últimos meses sube o baja.
///
/// Usa `savingsHistoryProvider` (`app/providers.dart`), que ya se encarga
/// de no remontarse a antes del primer mes con datos reales y de no
/// enseñar más de los últimos 12 meses. El valor que se dibuja es
/// `closingBalanceCents` tal cual, igual que un mes anterior en Inicio —
/// sin el ajuste de huchas, porque esa es una foto de HOY, no algo que
/// tenga sentido "recalcular" para meses ya cerrados.
///
/// **01/09/2026**: debajo de la línea, un resumen de ingresos y gastos
/// por categoría del mes que se este mirando (`selectedYearMonthProvider`,
/// el mismo de Inicio/Movimientos) -- pedido por Pol para tener en un
/// solo sitio "de donde sale tanto el ahorro como el gasto". Vive aquí en
/// vez de en una pantalla aparte a propósito: esto ya es "el apartado de
/// ver de dónde sale el dinero", no hacía falta uno nuevo.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/savings_repository.dart';
import '../data/tables.dart';
import 'providers.dart';

const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _formatYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final month = int.parse(parts[1]);
  return '${_monthNames[month - 1]} ${parts[0]}';
}

class SavingsChartScreen extends ConsumerWidget {
  const SavingsChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(savingsHistoryProvider);
    final selectedYearMonth = ref.watch(selectedYearMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Evolución del ahorro')),
      body: SafeArea(
        top: false,
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudo cargar: $e', style: T.body),
          ),
          data: (points) {
            final hasEnoughHistory = points.length >= 2;

            List<int> balances = [];
            int change = 0;
            int minBal = 0, maxBal = 0;
            if (hasEnoughHistory) {
              balances = [for (final (_, r) in points) r.closingBalanceCents];
              change = balances.last - balances.first;
              minBal = balances.reduce((a, b) => a < b ? a : b);
              maxBal = balances.reduce((a, b) => a > b ? a : b);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!hasEnoughHistory)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Todavía no hay suficiente historial para dibujar una '
                      'evolución. Vuelve cuando lleves un par de meses usando '
                      'la app.',
                      textAlign: TextAlign.center,
                      style: T.body.copyWith(color: C.inkDim),
                    ),
                  )
                else ...[
                  Text('AHORRO DE CIERRE · ÚLTIMOS ${points.length} MESES', style: T.eyebrow),
                  const SizedBox(height: 10),
                  Text(formatCents(balances.last), style: T.hero.copyWith(color: C.calm)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    child: Text(
                      '${formatCentsSigned(change)} desde ${_formatYearMonth(points.first.$1)}',
                      style: T.body.copyWith(color: change >= 0 ? C.calm : C.spend),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(R.container),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _EvolutionPainter(balances),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatYearMonth(points.first.$1), style: T.meta),
                              Text(_formatYearMonth(points.last.$1), style: T.meta),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _StatTile(label: 'MÍNIMO', value: minBal)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatTile(label: 'MÁXIMO', value: maxBal)),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'DE DÓNDE SALE Y A DÓNDE VA · ${_formatYearMonth(selectedYearMonth)}',
                  style: T.eyebrow,
                ),
                const SizedBox(height: 10),
                _CategorySummarySection(yearMonth: selectedYearMonth),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

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
          Text(formatCents(value), style: T.amountLarge.copyWith(color: C.calm)),
        ],
      ),
    );
  }
}

/// Ingresos y gastos de [yearMonth], por categoría -- pedido por Pol el
/// 01/09/2026 ("de donde salen tanto los ahorros como los gastos, de
/// forma resumida"). Dos tarjetas separadas (ingresos / gastos) en vez de
/// una lista mezclada, cada una con su propio total y su propia
/// proporción -- mezclar los dos en una sola barra de proporciones habría
/// hecho que un ingreso grande "empequeñeciera" visualmente todos los
/// gastos sin que eso signifique nada real.
class _CategorySummarySection extends ConsumerWidget {
  const _CategorySummarySection({required this.yearMonth});

  final String yearMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(categoryTotalsProvider(yearMonth));

    return totalsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('No se pudo cargar: $e', style: T.body),
      data: (totals) {
        if (totals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Todavía no hay movimientos en ${_formatYearMonth(yearMonth)}.',
              style: T.body.copyWith(color: C.inkDim),
            ),
          );
        }

        final incomes =
            totals.where((t) => t.category.kind == CategoryKindDb.income).toList();
        final expenses =
            totals.where((t) => t.category.kind != CategoryKindDb.income).toList();

        return Column(
          children: [
            if (incomes.isNotEmpty) _CategoryGroupCard(title: 'INGRESOS', totals: incomes),
            if (incomes.isNotEmpty && expenses.isNotEmpty) const SizedBox(height: 16),
            if (expenses.isNotEmpty) _CategoryGroupCard(title: 'GASTOS', totals: expenses),
          ],
        );
      },
    );
  }
}

class _CategoryGroupCard extends StatelessWidget {
  const _CategoryGroupCard({required this.title, required this.totals});

  final String title;
  final List<CategoryTotal> totals;

  @override
  Widget build(BuildContext context) {
    // Suma de lo positivo del grupo: si algo neto sale negativo (una
    // devolucion sin compra en el mismo mes, caso raro pero posible), no
    // tiene sentido que reste del total contra el que se dibujan las
    // barras de proporcion.
    final groupTotal = totals.fold<int>(
      0,
      (a, t) => a + (t.totalCents > 0 ? t.totalCents : 0),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(R.container),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: T.eyebrow),
              Text(formatCents(groupTotal), style: T.amount),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < totals.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: C.line),
            _CategoryTotalRow(total: totals[i], groupTotal: groupTotal),
          ],
        ],
      ),
    );
  }
}

class _CategoryTotalRow extends StatelessWidget {
  const _CategoryTotalRow({required this.total, required this.groupTotal});

  final CategoryTotal total;
  final int groupTotal;

  /// "↑ 12,50 € vs mes anterior" / "↓ 5,00 € vs mes anterior" / "sin
  /// cambios vs mes anterior" / null si esa categoria no tuvo movimientos
  /// el mes anterior (no hay con que comparar). Deliberadamente sin
  /// color: `C.spend`/`C.go` estan reservados para caprichos/ahorro, no
  /// para "subio" o "bajo" en una categoria cualquiera (doc de diseño).
  String? _comparisonLabel(CategoryTotal total) {
    final previous = total.previousTotalCents;
    if (previous == null) return null;
    final diff = total.totalCents - previous;
    if (diff == 0) return 'sin cambios vs mes anterior';
    final arrow = diff > 0 ? '↑' : '↓';
    return '$arrow ${formatCents(diff.abs())} vs mes anterior';
  }

  @override
  Widget build(BuildContext context) {
    final proportion = groupTotal > 0 && total.totalCents > 0
        ? (total.totalCents / groupTotal).clamp(0.0, 1.0)
        : 0.0;
    final movimientos = total.count == 1 ? '1 movimiento' : '${total.count} movimientos';
    final comparacion = _comparisonLabel(total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(total.category.name, style: T.body),
                  Text(movimientos, style: T.meta),
                  if (comparacion != null) Text(comparacion, style: T.meta),
                ],
              ),
            ),
            Text(
              total.totalCents >= 0
                  ? formatCents(total.totalCents)
                  : formatCentsSigned(total.totalCents),
              style: T.amount,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: proportion,
            minHeight: 4,
            backgroundColor: C.line,
            valueColor: const AlwaysStoppedAnimation(C.calm),
          ),
        ),
      ],
    );
  }
}

/// Dibuja la línea de evolución a mano (sin librería de gráficas: doc 04
/// solo pide "una línea de evolución", nada más). Autoescala al rango de
/// valores recibido, con un poco de aire arriba/abajo para que los puntos
/// de los extremos no queden pegados al borde.
class _EvolutionPainter extends CustomPainter {
  _EvolutionPainter(this.values);

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;

    const verticalPadding = 14.0;
    final minV = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final flat = (maxV - minV).abs() < 1;
    final effectiveMin = flat ? minV - 100 : minV;
    final range = flat ? 200.0 : (maxV - minV);

    double xAt(int i) => i / (values.length - 1) * size.width;
    double yAt(int i) {
      final t = (values[i] - effectiveMin) / range;
      return verticalPadding + (1 - t) * (size.height - verticalPadding * 2);
    }

    final linePath = ui.Path()..moveTo(xAt(0), yAt(0));
    for (var i = 1; i < values.length; i++) {
      linePath.lineTo(xAt(i), yAt(i));
    }

    final fillPath = ui.Path.from(linePath)
      ..lineTo(xAt(values.length - 1), size.height)
      ..lineTo(xAt(0), size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [C.calm.withValues(alpha: 0.22), C.calm.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = C.calm
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < values.length; i++) {
      final isLast = i == values.length - 1;
      final center = Offset(xAt(i), yAt(i));
      final radius = isLast ? 5.0 : 3.0;
      canvas.drawCircle(center, radius, Paint()..color = C.surface);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = C.calm
          ..style = PaintingStyle.stroke
          ..strokeWidth = isLast ? 2.5 : 1.8,
      );
      if (isLast) {
        canvas.drawCircle(center, 2, Paint()..color = C.calm);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EvolutionPainter oldDelegate) => true;
}
