import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biothrix/app/app.dart';

void main() {
  testWidgets('Biothrix app inflates and renders initial branding', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BiothrixApp());

    // Verify splash branding appears
    expect(find.text('Biothrix'), findsOneWidget);
    expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
  });
}
