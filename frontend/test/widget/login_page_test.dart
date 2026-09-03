import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('renders all essential login elements', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Email or Mobile Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In to Dashboard'), findsOneWidget);
    });

    testWidgets('submitting empty form triggers validation message', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      await tester.pump();

      // Clear default text
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.enterText(find.byType(TextFormField).last, '');
      await tester.pump();

      // Tap submit
      await tester.tap(find.text('Sign In to Dashboard'));
      await tester.pump();

      expect(find.text('Please enter your email or mobile number'), findsOneWidget);
    });
  });
}
