// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Login screen shows prefilled credentials and sign in button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Wait for providers to initialize
    await tester.pumpAndSettle();

    // Should find prefilled email field
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.text('admin@gmail.com'), findsOneWidget);

    // Should find password field and sign in button
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
