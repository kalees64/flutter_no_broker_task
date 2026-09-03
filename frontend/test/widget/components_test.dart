import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/app_button.dart';
import 'package:frontend/shared/widgets/app_card.dart';
import 'package:frontend/shared/widgets/user_avatar.dart';
import 'package:frontend/features/auth/presentation/widgets/error_banner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('Standardized Shared Components Widget Tests', () {
    testWidgets('AppButton renders text and triggers callback on press', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Sign In',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AppButton displays loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Sign In',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('AppCard renders child and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('UserAvatar renders user initials when image is absent', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'Amit Sharma'),
          ),
        ),
      );

      expect(find.text('AS'), findsOneWidget);
    });

    testWidgets('ErrorBanner renders title, message, and responds to dismiss', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              title: 'Auth Error',
              message: 'Invalid password',
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Auth Error'), findsOneWidget);
      expect(find.text('Invalid password'), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pump();
      expect(dismissed, isTrue);
    });
  });
}
