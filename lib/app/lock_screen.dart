/// Pantalla de bloqueo de la app (PIN + huella/cara como atajo).
///
/// Pedida por Pol el 21/09/2026 ("bloqueo opcional") junto con el
/// buscador de movimientos, como siguiente paso tras el cambio de la
/// copia de seguridad. `AppLockGate` (`app_lock_gate.dart`) la muestra
/// tapando toda la app tanto al abrir desde cero como al volver de
/// segundo plano, si `AppSettings.appLockEnabled` está activo.
///
/// El PIN es de 4 dígitos, con un teclado numérico hecho a mano (mismo
/// estilo que el resto de la app -- ver `_Keypad` en
/// `add_expense_screen.dart`, sin librerías de terceros). Si el móvil
/// soporta huella/reconocimiento facial (comprobado con `local_auth`), se
/// intenta automáticamente al abrir esta pantalla como atajo más rápido,
/// pero el PIN sigue funcionando siempre -- por ejemplo si la biometría
/// falla, no está configurada, o Pol prefiere teclearlo directamente.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../core/theme/tokens.dart';
import 'providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  static const _pinLength = 4;

  final _localAuth = LocalAuthentication();
  String _entered = '';
  bool _checking = false;
  bool _error = false;
  bool _biometricTried = false;

  @override
  void initState() {
    super.initState();
    // Se intenta la huella/cara sola, una vez, nada más abrir esta
    // pantalla -- si el usuario la cancela o falla, se queda esperando el
    // PIN sin insistir más (evita el bucle molesto de repetirla sola).
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    if (_biometricTried) return;
    _biometricTried = true;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!canCheck || !supported) return;
      final ok = await _localAuth.authenticate(
        localizedReason: 'Desbloquea Savings',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (ok && mounted) widget.onUnlocked();
    } catch (_) {
      // Sin biometría disponible, cancelada, o cualquier otro fallo: se
      // sigue con el PIN sin más, no es un error que haya que mostrar.
    }
  }

  Future<void> _onDigit(int d) async {
    if (_checking || _entered.length >= _pinLength) return;
    setState(() {
      _entered += d.toString();
      _error = false;
    });
    if (_entered.length == _pinLength) {
      setState(() => _checking = true);
      final ok = await ref.read(repositoryProvider).verifyAppLockPin(_entered);
      if (!mounted) return;
      if (ok) {
        widget.onUnlocked();
      } else {
        setState(() {
          _entered = '';
          _checking = false;
          _error = true;
        });
      }
    }
  }

  void _backspace() {
    if (_checking || _entered.isEmpty) return;
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.lock_outline, size: 40, color: C.inkDim),
              const SizedBox(height: 16),
              Text(
                _error ? 'PIN incorrecto, prueba otra vez' : 'Introduce tu PIN',
                style: _error ? T.body.copyWith(color: C.spend) : T.body,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? C.ink : Colors.transparent,
                      border: Border.all(color: _error ? C.spend : C.line, width: 1.5),
                    ),
                  );
                }),
              ),
              const Spacer(),
              _PinKeypad(onDigit: _onDigit, onBackspace: _backspace),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mismo estilo que `_Keypad` en `add_expense_screen.dart` (y sus otras
/// copias en `adjustment_screen.dart`, `edit_movement_screen.dart`,
/// `pocket_detail_screen.dart`) pero solo dígitos 0-9 y borrar, sin "00"
/// -- un PIN no necesita meter dos ceros de golpe.
class _PinKeypad extends StatelessWidget {
  const _PinKeypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, VoidCallback? onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Center(child: Text(label, style: T.amountLarge)),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [key('1', () => onDigit(1)), key('2', () => onDigit(2)), key('3', () => onDigit(3))]),
        Row(children: [key('4', () => onDigit(4)), key('5', () => onDigit(5)), key('6', () => onDigit(6))]),
        Row(children: [key('7', () => onDigit(7)), key('8', () => onDigit(8)), key('9', () => onDigit(9))]),
        Row(children: [
          const Expanded(child: SizedBox()),
          key('0', () => onDigit(0)),
          key('⌫', onBackspace),
        ]),
      ],
    );
  }
}
