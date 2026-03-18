import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_personajes_dnd/main.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const DndApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}