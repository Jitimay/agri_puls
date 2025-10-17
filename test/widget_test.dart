// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agripulse/main.dart';

void main() {
  testWidgets('AgriPulse app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgriPulseApp());

    // Verify that our app loads with the dashboard
    expect(find.text('AgriPulse Dashboard'), findsOneWidget);
    
    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify that we have the expected navigation items
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('3D Echo'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
  });
  
  testWidgets('Navigation between screens works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgriPulseApp());

    // Tap on the 3D Echo tab
    await tester.tap(find.text('3D Echo'));
    await tester.pump();

    // Verify that we navigated to the 3D visualization screen
    expect(find.text('AgriPulse Echo'), findsOneWidget);
    
    // Tap on the Alerts tab
    await tester.tap(find.text('Alerts'));
    await tester.pump();

    // Verify that we navigated to the alerts screen
    expect(find.text('Alerts'), findsOneWidget);
  });
}
