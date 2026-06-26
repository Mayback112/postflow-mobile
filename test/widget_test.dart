import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:postflow/main.dart';
import 'package:postflow/routes/route.dart';
import 'package:postflow/screen/onboarding/onboarding1.dart';

void main() {
  testWidgets('shows the onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });

  testWidgets('onboarding content fits on compact screens', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: Onboarding1Page()));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('recognizes social connect deep link route names', () {
    expect(
      Routes.isSocialConnectRoute(
        '/?status=connected&state=connect-state-1&syncedAccounts=1&connected=instagram',
      ),
      isTrue,
    );
    expect(
      Routes.isSocialConnectRoute(
        '/?status=error&state=connect-state-1&syncedAccounts=0&error=oauth_denied',
      ),
      isTrue,
    );
    expect(Routes.isSocialConnectRoute('/zernio/callback'), isFalse);
  });
}
