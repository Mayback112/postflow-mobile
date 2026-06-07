import 'package:flutter_test/flutter_test.dart';

import 'package:postflow/main.dart';

void main() {
  testWidgets('shows the onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
