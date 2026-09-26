import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/app/app.dart';

void main() {
  testWidgets('Wellnest app inflates and renders initial branding', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WellnestApp());

    // Verify splash branding appears
    expect(find.text('Wellnest'), findsOneWidget);
    expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
  });
}
