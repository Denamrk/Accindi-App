import 'package:flutter_test/flutter_test.dart';
import 'package:accindi/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AccindiApp());
    expect(find.text('accindi'), findsOneWidget);
    expect(find.text('Your Research ID & Wallet'), findsOneWidget);
  });
}
