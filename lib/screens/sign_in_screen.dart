import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../reusables/auth_text_field.dart';
import '../reusables/auth_button.dart';
import '../routes/custom_transitions.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  final AppState appState;
  const SignInScreen({super.key, required this.appState});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  ButtonStatus _btnStatus = ButtonStatus.idle;
  int _shakeKey = 0;
  String? _emailError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.themeMode == ThemeMode.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 24 + bottom),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _buildLogo(isDark),
                const SizedBox(height: 12),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  slideDelayMs: 100,
                  errorText: _emailError,
                ),
                AuthTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  isPassword: true,
                  obscureText: true,
                  slideDelayMs: 200,
                  errorText: _passError,
                ),
                const SizedBox(height: 8),
                AuthButton(
                  label: 'Sign In',
                  status: _btnStatus,
                  shakeKey: _shakeKey,
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      fadeRoute(SignUpScreen(appState: widget.appState)),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: AppColors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.15),
          ),
          child: ClipOval(
            child: Image.asset('assets/logo.png',
                width: 56, height: 56, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'EchoSee',
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  void _handleSignIn() {
    setState(() {
      _emailError = null;
      _passError = null;
    });
    final email = _emailCtrl.text;
    final pass = _passCtrl.text;
    if (email.isEmpty) _emailError = 'Email is required';
    if (pass.isEmpty) _passError = 'Password is required';
    if (_emailError != null || _passError != null) {
      setState(() => _shakeKey++);
      return;
    }
    setState(() => _btnStatus = ButtonStatus.loading);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final err = widget.appState.signIn(email, pass);
      if (err != null) {
        setState(() {
          _btnStatus = ButtonStatus.idle;
          _shakeKey++;
          _emailError = err.contains('Email') || err.contains('email')
              ? err
              : null;
          _passError = err.contains('Password') ? err : null;
          if (_emailError == null && _passError == null) _emailError = err;
        });
      } else {
        setState(() => _btnStatus = ButtonStatus.success);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            fadeScaleRoute(HomeScreen(appState: widget.appState)),
          );
        });
      }
    });
  }
}
