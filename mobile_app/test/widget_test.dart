import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}

