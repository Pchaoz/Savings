/// Asistente de bienvenida (se lanza desde Inicio la primera vez, antes
/// del coachmark de `coach_mark_overlay.dart`): configura la app de
/// verdad con los datos de quien la abre por primera vez, en vez de
/// limitarse a señalar botones. Pol lo pidió expresamente el 20/09/2026:
/// "debería enseñar como poner el sueldo base, el margen de caprichos, lo
/// importante e destacable de la app".
///
/// Cinco páginas en un `PageView` sin scroll lateral manual (solo se
/// avanza con los botones): bienvenida, saldo inicial, nómina, margen de
/// caprichos, y un repaso de tres cosas destacadas -- huchas de ahorro,
/// evolución del ahorro y los recurrentes (ingresos y gastos que se
/// repiten cada mes/trimestre/año) -- las dos primeras elegidas por Pol
/// expresamente. Cada página de datos se puede saltar con "Ahora no" sin
/// cortar el resto del asistente -- solo "Saltar tutorial" arriba a la
/// derecha corta todo de golpe, incluido el coachmark que viene después
/// (mismo texto y mismo significado que en `coach_mark_overlay.dart`:
/// cuenta como "tutorial visto").
///
/// La página de nómina comprueba antes si ya existe algún recurrente de
/// ingresos: si "Ajustes > Repetir tutorial" se usa después de que ya se
/// haya configurado una nómina, no vuelve a pedirla (evita crear un
/// segundo recurrente que duplicaría el ingreso cada mes) -- solo enseña
/// la que ya hay, de forma informativa.
///
/// Devuelve `true` si se completó el asistente entero (llegando a la
/// última página, aunque se hayan saltado pasos de datos sueltos con
/// "Ahora no"), o `false` si se pulsó "Saltar tutorial".
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/theme/tokens.dart';
import '../data/database.dart';
import '../data/tables.dart';
import '../domain/engine/month_calculator.dart';
import 'providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _totalPages = 5;

  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _totalPages - 1) {
      Navigator.of(context).pop(true);
      return;
    }
    _pageController.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _skipAll() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    // `canPop: false`: el asistente no se cierra con el gesto/botón de
    // volver del sistema por accidente -- solo con "Saltar tutorial" o
    // completándolo, igual que el coachmark solo se corta con sus propios
    // botones.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: C.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_page + 1}/$_totalPages', style: T.meta),
                    TextButton(
                      onPressed: _skipAll,
                      child: const Text('Saltar tutorial'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _WelcomePage(onNext: _next),
                    _OpeningBalancePage(onNext: _next),
                    _SalaryPage(onNext: _next),
                    _TreatMarginPage(onNext: _next),
                    _HighlightsPage(onFinish: _next),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(Icons.savings, size: 64, color: C.go),
          const SizedBox(height: 24),
          const Text(
            '¡Bienvenido a Savings!',
            style: T.hero,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Cada mes, con lo que de verdad te sobra tras pagar gastos '
            'fijos y variables, la app aparta automáticamente un margen a '
            'tu "bolsa de caprichos" -- dinero que puedes gastar sin '
            'sentir que descuadras nada. El resto es tu ahorro real.\n\n'
            'Vamos a configurar un par de cosas para que la app empiece a '
            'funcionar con tus datos de verdad. Tarda un minuto, y todo '
            'se puede cambiar después desde Ajustes.',
            style: T.body,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onNext, child: const Text('Empezar')),
          ),
        ],
      ),
    );
  }
}

class _OpeningBalancePage extends ConsumerStatefulWidget {
  const _OpeningBalancePage({required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<_OpeningBalancePage> createState() => _OpeningBalancePageState();
}

class _OpeningBalancePageState extends ConsumerState<_OpeningBalancePage> {
  final _controller = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  Future<void> _save() async {
    final cents = _parseEuros(_controller.text);
    if (cents == null) return;

    setState(() => _saving = true);

    final monthStartDay = (await ref.read(appSettingsProvider.future)).monthStartDay ?? 1;
    await ref.read(repositoryProvider).setOpeningBalance(
          yearMonth: currentYearMonth(monthStartDay: monthStartDay),
          cents: cents,
        );
    ref.invalidate(currentOpeningBalanceProvider);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (!mounted) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final currentAsync = ref.watch(currentOpeningBalanceProvider);
    currentAsync.whenData((cents) {
      if (!_prefilled) {
        _prefilled = true;
        if (cents != null) _controller.text = formatCentsPlain(cents);
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('¿Cuánto tienes ahorrado ya?', style: T.hero),
          const SizedBox(height: 12),
          const Text(
            'El dinero que ya tenías ahorrado justo antes de empezar a '
            'usar la app. Se puede corregir más adelante desde Ajustes > '
            'Saldo inicial.',
            style: T.body,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: T.amountLarge,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(suffixText: '€', hintText: '0'),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _saving ? null : widget.onNext,
                  child: const Text('Ahora no'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: (_parseEuros(_controller.text) != null && !_saving) ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalaryPage extends ConsumerStatefulWidget {
  const _SalaryPage({required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<_SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends ConsumerState<_SalaryPage> {
  final _nameController = TextEditingController(text: 'Nómina');
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  int? _parseEuros(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }

  int? _parseDay(String input) {
    final n = int.tryParse(input.trim());
    if (n == null) return null;
    return n.clamp(1, 28);
  }

  bool get _canSave =>
      !_saving &&
      _nameController.text.trim().isNotEmpty &&
      _parseEuros(_amountController.text) != null &&
      _parseDay(_dayController.text) != null;

  Future<void> _save(List<CategoryRow> categories) async {
    final cents = _parseEuros(_amountController.text);
    final day = _parseDay(_dayController.text);
    final name = _nameController.text.trim();
    if (!_canSave || cents == null || day == null) return;

    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);

    // Reutiliza una categoría de ingresos ya existente (las categorías de
    // fábrica ya traen "Nómina") en vez de crear una duplicada -- solo se
    // crea una nueva si de verdad no hay ninguna todavía.
    final existingIncomeCats =
        categories.where((c) => c.kind == CategoryKindDb.income).toList();
    late final CategoryRow incomeCategory;
    if (existingIncomeCats.isNotEmpty) {
      incomeCategory = existingIncomeCats.first;
    } else {
      final newId = await repo.addCategory(name: name, kind: CategoryKindDb.income);
      final refreshed = await repo.categories;
      incomeCategory = refreshed.firstWhere((c) => c.id == newId);
      ref.invalidate(categoriesProvider);
    }

    final monthStartDay = (await ref.read(appSettingsProvider.future)).monthStartDay ?? 1;
    await repo.addRecurringTemplate(
      name: name,
      categoryId: incomeCategory.id,
      amountCents: cents,
      dayOfMonth: day,
      everyNMonths: 1,
      anchorYearMonth: currentYearMonth(monthStartDay: monthStartDay),
    );
    ref.invalidate(recurringTemplatesProvider);
    ref.invalidate(monthResultProvider);
    ref.invalidate(monthMovementsProvider);

    if (!mounted) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(recurringTemplatesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: categoriesAsync.when(
        data: (categories) => templatesAsync.when(
          data: (templates) => _build(categories, templates),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e', style: T.body),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e', style: T.body),
      ),
    );
  }

  Widget _build(List<CategoryRow> categories, List<RecurringRow> templates) {
    final incomeCategoryIds =
        categories.where((c) => c.kind == CategoryKindDb.income).map((c) => c.id).toSet();
    final existingMatches =
        templates.where((t) => incomeCategoryIds.contains(t.categoryId)).toList();

    if (existingMatches.isNotEmpty) {
      // Ya hay una nómina configurada -- pasa esto al repetir el
      // tutorial desde Ajustes: no tiene sentido volver a pedirla, y
      // menos crear una segunda que duplicaría el ingreso cada mes.
      final existing = existingMatches.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tu nómina', style: T.hero),
          const SizedBox(height: 12),
          Text(
            'Ya tienes configurado "${existing.name}" '
            '(${formatCents(existing.amountCents)}, día ${existing.dayOfMonth} de cada '
            'mes). Se puede cambiar cuando quieras desde Ajustes > Ingresos y '
            'gastos recurrentes.',
            style: T.body,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: widget.onNext, child: const Text('Continuar')),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Tu sueldo', style: T.hero),
        const SizedBox(height: 12),
        const Text(
          'Si cobras una nómina, apúntala aquí para que se genere sola '
          'cada mes en vez de tener que apuntarla a mano.',
          style: T.body,
        ),
        const SizedBox(height: 20),
        Text('Nombre', style: T.meta),
        TextField(
          controller: _nameController,
          style: T.body,
          textCapitalization: TextCapitalization.sentences,
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
        Text('Día de cobro (1-28)', style: T.meta),
        TextField(
          controller: _dayController,
          keyboardType: TextInputType.number,
          style: T.body,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: 'Ej. 1'),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _saving ? null : widget.onNext,
                child: const Text('Ahora no'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _canSave ? () => _save(categories) : null,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar y continuar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TreatMarginPage extends ConsumerStatefulWidget {
  const _TreatMarginPage({required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<_TreatMarginPage> createState() => _TreatMarginPageState();
}

class _TreatMarginPageState extends ConsumerState<_TreatMarginPage> {
  final _controller = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parsePercent(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value < 0) return null;
    return value / 100;
  }

  Future<void> _save() async {
    final rate = _parsePercent(_controller.text);
    if (rate == null) return;

    setState(() => _saving = true);
    await ref.read(repositoryProvider).setDefaultTreatRate(rate);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(monthResultProvider);

    if (!mounted) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    settingsAsync.whenData((settings) {
      if (!_prefilled) {
        _prefilled = true;
        final rate = settings.defaultTreatRate ?? kDefaultTreatRate;
        _controller.text = (rate * 100).round().toString();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tu margen de caprichos', style: T.hero),
          const SizedBox(height: 12),
          const Text(
            'Qué porcentaje de lo que ahorras cada mes va a la bolsa de '
            'caprichos. Por defecto es el 10 %, y se puede cambiar cuando '
            'quieras desde Ajustes.',
            style: T.body,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: T.amountLarge,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(suffixText: '%'),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _saving ? null : widget.onNext,
                  child: const Text('Ahora no'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: !_saving ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar y continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightsPage extends StatelessWidget {
  const _HighlightsPage({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Un par de cosas más', style: T.hero),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _HighlightCard(
                    icon: Icons.savings_outlined,
                    title: 'Huchas de ahorro',
                    description: 'Aparta dinero para una meta concreta (un '
                        'viaje, un capricho grande...) sin que cuente como '
                        'gastado ni reduzca tu ahorro calculado. Se '
                        'gestionan desde el icono de la hucha, arriba en '
                        'Inicio.',
                  ),
                  SizedBox(height: 12),
                  _HighlightCard(
                    icon: Icons.show_chart,
                    title: 'Evolución del ahorro',
                    description: 'Una gráfica con cómo ha ido tu ahorro mes '
                        'a mes, para ver el progreso de un vistazo. Se abre '
                        'desde el icono de la gráfica, arriba en Inicio.',
                  ),
                  SizedBox(height: 12),
                  _HighlightCard(
                    icon: Icons.autorenew,
                    title: 'Ingresos y gastos recurrentes',
                    description: 'Además de la nómina, puedes dejar puestos '
                        'de una vez otros gastos e ingresos que se repiten '
                        '-- alquiler, suscripciones, una paga extra '
                        'trimestral... -- para que se apunten solos cada '
                        'mes, cada trimestre o cada año, sin tener que '
                        'acordarte. Se gestionan desde Ajustes > Ingresos y '
                        'gastos recurrentes.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onFinish,
              child: const Text('Empezar a usar la app'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.raised,
        borderRadius: BorderRadius.circular(R.container),
        border: Border.all(color: C.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: C.calm),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(description, style: T.meta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
