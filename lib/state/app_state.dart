import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../models/transcript.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  FontSizeOption _fontSize = FontSizeOption.medium;
  Color _subtitleBgColor = Colors.white;
  SubtitlePosition _subtitlePosition = SubtitlePosition.bottom;
  List<Transcript> _transcripts = [];
  bool _isPremium = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  FontSizeOption get fontSize => _fontSize;
  Color get subtitleBgColor => _subtitleBgColor;
  SubtitlePosition get subtitlePosition => _subtitlePosition;
  List<Transcript> get transcripts => List.unmodifiable(_transcripts);
  bool get isPremium => _isPremium;
  double get textScaleFactor {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 0.85;
      case FontSizeOption.medium:
        return 1.0;
      case FontSizeOption.large:
        return 1.15;
    }
  }

  // Setters
  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _save();
    notifyListeners();
  }

  set fontSize(FontSizeOption size) {
    _fontSize = size;
    _save();
    notifyListeners();
  }

  set subtitleBgColor(Color color) {
    _subtitleBgColor = color;
    _save();
    notifyListeners();
  }

  set subtitlePosition(SubtitlePosition position) {
    _subtitlePosition = position;
    _save();
    notifyListeners();
  }

  set isPremium(bool value) {
    _isPremium = value;
    _save();
    notifyListeners();
  }

  void toggleTheme() {
    themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  // Transcript management
  void addTranscript(Transcript t) {
    _transcripts.insert(0, t);
    if (!_isPremium && _transcripts.length > 5) {
      _transcripts = _transcripts.sublist(0, 5);
    }
    _save();
    notifyListeners();
  }

  void deleteTranscript(String id) {
    _transcripts.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  // Persistence
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        _parseThemeMode(prefs.getString('themeMode') ?? 'dark');
    _fontSize =
        _parseFontSize(prefs.getString('fontSize') ?? 'medium');
    _subtitleBgColor = Color(
      prefs.getInt('subtitleBgColor') ?? 0xFFFFFFFF,
    );
    _subtitlePosition = _parsePosition(
        prefs.getString('subtitlePosition') ?? 'bottom');
    _isPremium = prefs.getBool('isPremium') ?? false;

    final transcriptsJson = prefs.getString('transcripts');
    if (transcriptsJson != null) {
      final list = jsonDecode(transcriptsJson) as List;
      _transcripts =
          list.map((e) => Transcript.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.name);
    await prefs.setString('fontSize', _fontSize.name);
    await prefs.setInt('subtitleBgColor', _subtitleBgColor.toARGB32());
    await prefs.setString(
        'subtitlePosition', _subtitlePosition.name);
    await prefs.setBool('isPremium', _isPremium);
    final transcriptsJson =
        jsonEncode(_transcripts.map((t) => t.toJson()).toList());
    await prefs.setString('transcripts', transcriptsJson);
  }

  // Parsers
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  FontSizeOption _parseFontSize(String value) {
    switch (value) {
      case 'small':
        return FontSizeOption.small;
      case 'medium':
        return FontSizeOption.medium;
      case 'large':
        return FontSizeOption.large;
      default:
        return FontSizeOption.medium;
    }
  }

  SubtitlePosition _parsePosition(String value) {
    switch (value) {
      case 'top':
        return SubtitlePosition.top;
      case 'center':
        return SubtitlePosition.center;
      case 'bottom':
        return SubtitlePosition.bottom;
      default:
        return SubtitlePosition.bottom;
    }
  }
}
