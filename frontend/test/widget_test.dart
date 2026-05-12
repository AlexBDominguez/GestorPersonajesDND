import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_personajes_dnd/main.dart';
import 'package:gestor_personajes_dnd/viewmodels/locale_viewmodel.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    final localeVm = LocaleViewModel();
    await tester.pumpWidget(DndApp(localeVm: localeVm));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}