import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../models/transcript.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  FontSizeOption _fontSize = FontSizeOption.medium;
  Color _subtitleBgColor = Colors.white;
  SubtitlePosition _subtitlePosition = SubtitlePosition.bottom;
  List<Transcript> _transcripts = [];
  bool _isPremium = false;
  List<Map<String, String>> _users = [];
  Map<String, String>? _currentUser;
  String _language = 'English';

  // Getters
  ThemeMode get themeMode => _themeMode;
  FontSizeOption get fontSize => _fontSize;
  Color get subtitleBgColor => _subtitleBgColor;
  SubtitlePosition get subtitlePosition => _subtitlePosition;
  List<Transcript> get transcripts => List.unmodifiable(_transcripts);
  bool get isPremium => _isPremium;
  bool get isLoggedIn => _currentUser != null;
  Map<String, String>? get currentUser => _currentUser;
  String get language => _language;

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

  set language(String value) {
    _language = value;
    _save();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
  }

  // Auth
  String? signUp(String name, String email, String password) {
    if (name.trim().isEmpty) return 'Full name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim())) {
      return 'Invalid email format';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (_users.any((u) => u['email'] == email.trim())) {
      return 'Email already registered';
    }
    final user = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    };
    _users.add(user);
    _currentUser = user;
    _save();
    notifyListeners();
    return null;
  }

  String? signIn(String email, String password) {
    if (email.trim().isEmpty) return 'Email is required';
    if (password.isEmpty) return 'Password is required';
    final user = _users.cast<Map<String, String>?>().firstWhere(
          (u) => u?['email'] == email.trim() && u?['password'] == password,
          orElse: () => null,
        );
    if (user == null) return 'Invalid email or password';
    _currentUser = user;
    _save();
    notifyListeners();
    return null;
  }

  void signOut() {
    _currentUser = null;
    _save();
    notifyListeners();
  }

  void updateProfile(String name, String email, String lang) {
    if (_currentUser == null) return;
    _currentUser!['name'] = name.trim();
    _currentUser!['email'] = email.trim();
    _language = lang;
    final idx = _users.indexWhere(
        (u) => u['email'] == _currentUser!['email']);
    if (idx >= 0) _users[idx] = Map.from(_currentUser!);
    _save();
    notifyListeners();
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

  SharedPreferences? _prefs;

  // Persistence
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;
    _themeMode =
        _parseThemeMode(prefs.getString('themeMode') ?? 'system');
    _fontSize =
        _parseFontSize(prefs.getString('fontSize') ?? 'medium');
    _subtitleBgColor = Color(
      prefs.getInt('subtitleBgColor') ?? 0xFFFFFFFF,
    );
    _subtitlePosition = _parsePosition(
        prefs.getString('subtitlePosition') ?? 'bottom');
    _isPremium = prefs.getBool('isPremium') ?? false;
    _language = prefs.getString('language') ?? 'English';

    final transcriptsJson = prefs.getString('transcripts');
    if (transcriptsJson != null) {
      final list = jsonDecode(transcriptsJson) as List;
      _transcripts =
          list.map((e) => Transcript.fromJson(e)).toList();
    }

    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      _users = (jsonDecode(usersJson) as List)
          .map((e) => Map<String, String>.from(e))
          .toList();
    }

    final currentEmail = prefs.getString('currentUserEmail');
    if (currentEmail != null) {
      _currentUser = _users.cast<Map<String, String>?>().firstWhere(
            (u) => u?['email'] == currentEmail,
            orElse: () => null,
          );
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.name);
    await prefs.setString('fontSize', _fontSize.name);
    await prefs.setInt('subtitleBgColor', _subtitleBgColor.toARGB32());
    await prefs.setString(
        'subtitlePosition', _subtitlePosition.name);
    await prefs.setBool('isPremium', _isPremium);
    await prefs.setString('language', _language);
    final transcriptsJson =
        jsonEncode(_transcripts.map((t) => t.toJson()).toList());
    await prefs.setString('transcripts', transcriptsJson);
    final usersJson = jsonEncode(_users);
    await prefs.setString('users', usersJson);
    await prefs.setString(
        'currentUserEmail', _currentUser?['email'] ?? '');
  }

  // Parsers
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
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
