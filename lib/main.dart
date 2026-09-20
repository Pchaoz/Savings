import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }
}
