import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
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

class EchoSeeApp extends StatelessWidget {
  const EchoSeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoSee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navyBlue,
          primary: AppColors.navyBlue,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.navyBlue,
      ),
      home: const SplashScreen(),
    );
  }
}
