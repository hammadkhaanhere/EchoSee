import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import 'subscription_screen.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String _selectedLang = 'English';

  @override
  void initState() {
    super.initState();
    final user = widget.appState.currentUser;
    _nameCtrl = TextEditingController(text: user?['name'] ?? '');
    _emailCtrl = TextEditingController(text: user?['email'] ?? '');
    _selectedLang = widget.appState.language;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.navyBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.2),
                  ),
                  child: Icon(Icons.person,
                      size: 48,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 28),
              _fieldLabel('Full Name', isDark),
              const SizedBox(height: 6),
              _buildField(_nameCtrl, isDark),
              const SizedBox(height: 20),
              _fieldLabel('Email', isDark),
              const SizedBox(height: 6),
              _buildField(_emailCtrl, isDark),
              const SizedBox(height: 20),
              _fieldLabel('Preferred Language', isDark),
              const SizedBox(height: 6),
              _buildLanguageDropdown(isDark),
              const SizedBox(height: 32),
              _buildSaveButton(isDark),
              const SizedBox(height: 16),
              if (widget.appState.isPremium) _buildPremiumBadge(isDark),
              _buildSubscriptionCard(isDark),
              const SizedBox(height: 24),
              _buildSignOutButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? AppColors.darkText : AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLang,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : AppColors.navyBlue,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: ['English', 'Urdu']
              .map((l) => DropdownMenuItem(value: l, child: Text(l)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedLang = v);
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          widget.appState.updateProfile(
              _nameCtrl.text, _emailCtrl.text, _selectedLang);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('Save',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildPremiumBadge(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 18),
          SizedBox(width: 6),
          Text('Premium Active',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionScreen(appState: widget.appState),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.teal.withValues(alpha: 0.3),
              AppColors.teal.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appState.isPremium
                        ? 'Manage Subscription'
                        : 'Upgrade to Premium',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.appState.isPremium
                        ? 'Multi-language, full history & more'
                        : 'Unlock all features',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          widget.appState.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => SignInScreen(appState: widget.appState),
            ),
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Sign Out',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
