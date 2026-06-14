import 'package:app/screens/admin_panel_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin can set XP when creating an exercise', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminPanelScreen()));

    await tester.tap(find.text('Ejercicios'));
    await tester.pump();

    await tester.tap(find.text('AGREGAR EJERCICIO'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('XP del ejercicio'), findsOneWidget);
    expect(
      find.text('Puntos otorgados al completar este ejercicio (0 a 100).'),
      findsOneWidget,
    );
  });
}
