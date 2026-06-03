import 'package:flutter_test/flutter_test.dart';
import 'package:echosee/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EchoSeeApp());
    await tester.pump();
    expect(find.text('EchoSee'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
