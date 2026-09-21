import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_lock_gate.dart';
import 'app/home_screen.dart';
import 'core/theme/tokens.dart';

void main() {
  runApp(const ProviderScope(child: SavingsApp()));
}

class SavingsApp extends StatelessWidget {
  const SavingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savings',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: const HomeScreen(),
      // `AppLockGate` envuelve TODA la navegación (no solo `home`) para
      // poder tapar cualquier pantalla con el PIN sin perder su estado ni
      // su pila de rutas -- ver `app/app_lock_gate.dart`.
      builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
