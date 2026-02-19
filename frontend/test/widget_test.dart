// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:masika/main.dart';

void main() {
  testWidgets('Masika app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MasikaApp()));

    // Verify splash screen appears
    expect(find.text('MASIKA'), findsOneWidget);
  });
}
