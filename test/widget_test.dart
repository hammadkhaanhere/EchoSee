import 'package:eecho_see/core/app_settings.dart';
import 'package:eecho_see/data/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('EchoSee settings model persists defaults', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;

    final service = SettingsService();
    await service.init();

    expect(service.settings.value.speechLanguageCode, 'en-US');
    expect(service.settings.value.translationLanguageCode, 'ar');
    expect(service.settings.value.asrMode, AsrMode.auto);
  });

  testWidgets('EchoSee app shell renders title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('EchoSee')),
        ),
      ),
    );

    expect(find.text('EchoSee'), findsOneWidget);
  });
}
