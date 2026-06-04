import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eecho_see/main.dart';

void main() {
  testWidgets('EchoSee home screen renders speech controls', (tester) async {
    await tester.pumpWidget(const EchoSeeApp());

    expect(find.text('EchoSee'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(
      find.text('Press the microphone and start speaking.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
  });
}
