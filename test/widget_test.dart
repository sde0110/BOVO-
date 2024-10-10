import 'package:flutter_test/flutter_test.dart';

import 'package:bovo/main.dart';

void main() {
  testWidgets('App should start with main screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the main screen is displayed
    expect(find.text('BOVO'), findsOneWidget);
    expect(find.text('오늘단어'), findsOneWidget);

    // You can add more specific tests here based on your app's functionality
  });
}
