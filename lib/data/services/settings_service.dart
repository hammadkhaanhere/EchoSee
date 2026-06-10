import 'dart:convert';

import 'package:eecho_see/core/app_settings.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends GetxService {
  static const _prefsKey = 'app_settings';

  final Rx<AppSettings> settings = const AppSettings().obs;
  late SharedPreferences _prefs;

  Future<SettingsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_prefsKey);
    if (raw != null) {
      settings.value = AppSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    return this;
  }

  Future<void> update(AppSettings value) async {
    settings.value = value;
    await _prefs.setString(_prefsKey, jsonEncode(value.toJson()));
  }

  Future<void> updatePartial(AppSettings Function(AppSettings current) updater) {
    return update(updater(settings.value));
  }
}
