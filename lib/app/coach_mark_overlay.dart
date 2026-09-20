/// Tutorial guiado hecho a mano, sin ninguna libreria de terceros -- misma
/// filosofia que el widget de pantalla de inicio o la grafica de
/// evolucion: la app ya tuvo un problema real de compilacion en Windows
/// al añadir una dependencia con codigo nativo, asi que para algo tan
/// acotado (resaltar dos o tres widgets con un texto al lado) no merece
/// la pena arriesgar otra dependencia quede quien sabe que mas trae.
///
/// `showCoachMarks` resalta, uno detras de otro, cada widget de la lista
/// de `steps` (localizado por su `GlobalKey`): oscurece el resto de la
/// pantalla con un "agujero" alrededor del widget señalado y muestra una
/// tarjeta con un titulo, un texto y los botones "Saltar tutorial" /
/// "Siguiente" (o "Entendido" en el ultimo paso). `onDone` se llama tanto
/// si se completan todos los pasos como si se pulsa "Saltar" en
/// cualquiera de ellos -- las dos cosas cuentan como "tutorial visto".
library;

import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

/// Un paso del tutorial: que widget señalar (por su `GlobalKey`, ya
/// puesto en el widget real de la pantalla) y que texto mostrar junto a
/// el.
class CoachMarkStep {
  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.message,
  });

  final GlobalKey targetKey;
  final String title;
  final String message;
}

/// Inserta el tutorial guiado como un `OverlayEntry` por encima de todo
/// lo demas (incluida la AppBar), y lo retira solo cuando termina o se
/// salta. No hace nada si `steps` esta vacia.
void showCoachMarks({
  required BuildContext context,
  required List<CoachMarkStep> steps,
  required VoidCallback onDone,
}) {
  if (steps.isEmpty) {
    onDone();
    return;
  }
  final overlayState = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  var finished = false;

  void finish() {
    if (finished) return;
    finished = true;
    entry.remove();
    onDone();
  }

  entry = OverlayEntry(
    builder: (_) => _CoachMarkOverlay(steps: steps, onDone: finish),
  );
  overlayState.insert(entry);
}

class _CoachMarkOverlay extends StatefulWidget {
  const _CoachMarkOverlay({required this.steps, required this.onDone});

  final List<CoachMarkStep> steps;
  final VoidCallback onDone;

  @override
  State<_CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<_CoachMarkOverlay> {
  int _index = 0;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locateTarget());
  }

  Future<void> _locateTarget() async {
    final step = widget.steps[_index];
    final target = step.targetKey.currentContext;
    if (target == null) {
      // El widget señalado no esta en pantalla ahora mismo (por ejemplo,
      // el usuario ha navegado a otro sitio a mitad del tutorial). Mejor
      // cortarlo aqui sin avisar de ningun error que dejarlo colgado.
      widget.onDone();
      return;
    }
    if (Scrollable.maybeOf(target) != null) {
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 200),
        alignment: 0.2,
      );
    }
    if (!mounted) return;
    final box = target.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    setState(() => _targetRect = (origin & box.size).inflate(8));
  }

  void _next() {
    if (_index >= widget.steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() {
      _index++;
      _targetRect = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _locateTarget());
  }

  @override
  Widget build(BuildContext context) {
    final rect = _targetRect;
    if (rect == null) return const SizedBox.shrink();

    final step = widget.steps[_index];
    final screen = MediaQuery.of(context).size;
    final showCardBelow = rect.top < screen.height * 0.5;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            // Absorbe los toques fuera de la tarjeta -- el tutorial solo
            // avanza con "Siguiente"/"Saltar", no tocando por ahi.
            onTap: () {},
            child: CustomPaint(
              painter: _SpotlightPainter(rect),
              size: Size.infinite,
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: showCardBelow ? rect.bottom + 16 : null,
          bottom: showCardBelow ? null : screen.height - rect.top + 16,
          child: _CoachMarkCard(
            title: step.title,
            message: step.message,
            stepLabel: '${_index + 1}/${widget.steps.length}',
            isLast: _index == widget.steps.length - 1,
            onSkip: widget.onDone,
            onNext: _next,
          ),
        ),
      ],
    );
  }
}

/// Oscurece toda la pantalla salvo un rectangulo redondeado alrededor del
/// widget señalado, con un borde fino para que se note que ese es el
/// protagonista del paso.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(hole),
    );
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.72));
    canvas.drawRRect(
      hole,
      Paint()
        ..color = C.go
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => oldDelegate.rect != rect;
}

class _CoachMarkCard extends StatelessWidget {
  const _CoachMarkCard({
    required this.title,
    required this.message,
    required this.stepLabel,
    required this.isLast,
    required this.onSkip,
    required this.onNext,
  });

  final String title;
  final String message;
  final String stepLabel;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(R.container),
          border: Border.all(color: C.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: T.body.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(stepLabel, style: T.meta),
              ],
            ),
            const SizedBox(height: 8),
            Text(message, style: T.body),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: onSkip, child: const Text('Saltar tutorial')),
                FilledButton(onPressed: onNext, child: Text(isLast ? 'Entendido' : 'Siguiente')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
