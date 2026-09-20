/// Prueba de humo de toda la cadena: base de datos en memoria -> repositorio
/// -> motor -> pantalla real. Sin tocar disco ni depender de un emulador.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savings/app/home_screen.dart';
import 'package:savings/app/providers.dart';
import 'package:savings/core/money.dart';
import 'package:savings/data/database.dart';

void main() {
  testWidgets('la pantalla de inicio arranca y muestra la bolsa a cero', (tester) async {
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(testDb.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(testDb)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // El resultado del mes llega por un FutureProvider: hay que dejar
    // que se resuelva antes de mirar la pantalla.
    await tester.pumpAndSettle();

    // Comparamos contra formatCents(0) en vez de un literal "0,00 €": asi
    // el test no depende de que carácter de espacio use exactamente el
    // formato de moneda es_ES (normal o de no separacion).
    final bagText = tester.widget<Text>(find.byKey(const Key('bagAmount')));
    expect(bagText.data, formatCents(0));
  });
}
