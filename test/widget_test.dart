import 'package:flutter_test/flutter_test.dart';
import 'package:echosee/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EchoSeeApp());
    expect(find.text('EchoSee'), findsOneWidget);
  });
}
