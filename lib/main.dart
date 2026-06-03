import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const EchoSeeApp());
  });
}

class EchoSeeApp extends StatefulWidget {
  const EchoSeeApp({super.key});

  @override
  State<EchoSeeApp> createState() => _EchoSeeAppState();
}

class _EchoSeeAppState extends State<EchoSeeApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.load();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'EchoSee',
          debugShowCheckedModeBanner: false,
          theme: AppColors.lightTheme,
          darkTheme: AppColors.darkTheme,
          themeMode: _appState.themeMode,
          home: SplashScreen(appState: _appState),
        );
      },
    );
  }
}
