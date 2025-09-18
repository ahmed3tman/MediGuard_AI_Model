import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediguard_ai_model/main.dart';

void main() {
  testWidgets('App starts and navigates to chat', (WidgetTester tester) async {
    await tester.pumpWidget(const MediguardApp());
    await tester.pumpAndSettle();

    // Patient form should be visible
    expect(find.text('Patient Information'), findsOneWidget);

    // Save button exists
    expect(find.byIcon(Icons.save), findsOneWidget);

    // Ensure 'Open Chat' is visible then tap
    final openChatFinder = find.text('Open Chat');
    await tester.ensureVisible(openChatFinder);
    await tester.tap(openChatFinder);
    await tester.pumpAndSettle();

    expect(find.text('Chat'), findsOneWidget);
    expect(find.byKey(const Key('sendButton')), findsOneWidget);
  });
}
