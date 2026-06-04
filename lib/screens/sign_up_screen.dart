import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../reusables/auth_text_field.dart';
import '../reusables/auth_button.dart';
import 'home_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  final AppState appState;
  const SignUpScreen({super.key, required this.appState});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  ButtonStatus _btnStatus = ButtonStatus.idle;
  int _shakeKey = 0;
  String? _nameError;
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.themeMode == ThemeMode.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.navyBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 24 + bottom),
          child: Column(
            children: [
              _buildLogo(isDark),
              const SizedBox(height: 12),
              Text(
                'Create Account',
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                label: 'Full Name',
                controller: _nameCtrl,
                slideDelayMs: 100,
                errorText: _nameError,
              ),
              AuthTextField(
                label: 'Email',
                controller: _emailCtrl,
                slideDelayMs: 200,
                errorText: _emailError,
              ),
              AuthTextField(
                label: 'Password',
                controller: _passCtrl,
                isPassword: true,
                obscureText: true,
                slideDelayMs: 300,
                errorText: _passError,
              ),
              const SizedBox(height: 8),
              AuthButton(
                label: 'Sign Up',
                status: _btnStatus,
                shakeKey: _shakeKey,
                onPressed: _handleSignUp,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SignInScreen(appState: widget.appState),
                    transitionsBuilder:
                        (context, a, secondaryAnimation, child) =>
                            FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ),
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: AppColors.teal),
                ),
              ),
            ],
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
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  void _handleSignUp() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passError = null;
    });
    final name = _nameCtrl.text;
    final email = _emailCtrl.text;
    final pass = _passCtrl.text;
    if (name.isEmpty) _nameError = 'Full name is required';
    if (email.isEmpty) _emailError = 'Email is required';
    if (pass.isEmpty) _passError = 'Password is required';
    if (_nameError != null || _emailError != null || _passError != null) {
      setState(() => _shakeKey++);
      return;
    }
    setState(() => _btnStatus = ButtonStatus.loading);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final err = widget.appState.signUp(name, email, pass);
      if (err != null) {
        setState(() {
          _btnStatus = ButtonStatus.idle;
          _shakeKey++;
          if (err.contains('name') || err.contains('Name')) {
            _nameError = err;
          } else if (err.contains('Email') || err.contains('email')) {
            _emailError = err;
          } else if (err.contains('Password') || err.contains('password')) {
            _passError = err;
          } else {
            _emailError = err;
          }
        });
      } else {
        setState(() => _btnStatus = ButtonStatus.success);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeScreen(appState: widget.appState),
              transitionsBuilder: (context, a, secondaryAnimation, child) =>
                  FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        });
      }
    });
  }
}
