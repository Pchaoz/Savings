/// Envuelve TODA la app (ver `main.dart`, `MaterialApp.builder`) para
/// poder tapar cualquier pantalla con `LockScreen` sin perder su estado
/// ni su pila de navegación -- si se bloqueara dentro de `home:` en vez
/// de en el `builder`, un bloqueo mientras Pol está en Ajustes habría
/// dejado la pantalla de bloqueo TAPADA por Ajustes (que está apilado
/// encima en el Navigator), en vez de al revés. Aquí, en cambio,
/// `LockScreen` se pinta en un `Stack` por encima de todo el Navigator,
/// así que siempre gana se mire donde se mire.
///
/// Vuelve a pedir el bloqueo (si está activo, `AppSettings.appLockEnabled`)
/// tanto al abrir la app desde cero como al volver de segundo plano de
/// verdad (`AppLifecycleState.paused`) -- pedido así por Pol el
/// 21/09/2026, no solo al arrancar en frío. Los propios selectores de
/// fichero nativos de la app (copia de seguridad / restaurar, ver
/// `settings_screen.dart`) también pausan la actividad de Android al
/// abrirse, pero no cuentan como "salir de la app" -- por eso avisan aquí
/// con `appLockSuspendedProvider` para que no salte un bloqueo de golpe
/// en mitad de elegir un fichero.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import 'lock_screen.dart';
import 'providers.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  bool? _locked;
  bool _pendingRelock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_locked == null) return; // todavía no se sabe si el bloqueo está activo
    if (state == AppLifecycleState.paused) {
      if (!ref.read(appLockSuspendedProvider)) {
        _pendingRelock = true;
      }
    } else if (state == AppLifecycleState.resumed && _pendingRelock) {
      _pendingRelock = false;
      final enabled = ref.read(appSettingsProvider).value?.appLockEnabled ?? false;
      if (enabled) setState(() => _locked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    // Mientras no se sepa si el bloqueo esta activo (la primera vez que
    // se abre la app, mientras se lee `AppSettings` de la base de datos)
    // se tapa igual con una pantalla neutra en vez de dejar ver Inicio ni
    // un instante -- mejor pecar de cauto ahi que arriesgarse a un
    // parpadeo con datos reales antes de saber si tocaba pedir el PIN.
    return settingsAsync.when(
      data: (settings) {
        _locked ??= settings.appLockEnabled;
        final locked = _locked!;
        return Stack(
          children: [
            IgnorePointer(ignoring: locked, child: widget.child),
            if (locked) LockScreen(onUnlocked: () => setState(() => _locked = false)),
          ],
        );
      },
      loading: () => const Scaffold(backgroundColor: C.bg),
      // Si ni siquiera se puede leer `AppSettings` la base de datos tiene
      // un problema mas gordo que este bloqueo -- se deja pasar en vez de
      // dejar la app inutilizable sin ninguna pista de por que.
      error: (_, _) => widget.child,
    );
  }
}
