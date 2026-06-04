import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';

class SubscriptionScreen extends StatelessWidget {
  final AppState appState;
  const SubscriptionScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isDark = appState.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.navyBlue,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.navyBlue,
        title: const Text('Subscription',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, Color(0xFF00BCD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Premium Features',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Unlock the full EchoSee experience',
                style: TextStyle(
                  color: isDark ? AppColors.darkSubtitleText : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _featureItem(
              Icons.translate,
              'Multi-language Translation',
              'Real-time translation across multiple languages',
            ),
            _featureItem(
              Icons.history,
              'Full Transcript History',
              'Unlimited storage with search by date or keyword',
            ),
            _featureItem(
              Icons.record_voice_over,
              'Speaker Identification',
              'Automatic detection and labeling of speakers',
            ),
            _featureItem(
              Icons.tune,
              'Advanced Customization',
              'Subtitle color picker, drag & drop position, and more',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  appState.isPremium = !appState.isPremium;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appState.isPremium
                          ? 'Welcome to Premium!'
                          : 'Subscription cancelled'),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.teal.withValues(alpha: 0.4),
                ),
                child: Text(
                  appState.isPremium
                      ? 'Cancel Subscription'
                      : 'Subscribe Now — \$4.99/mo',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Cancel anytime',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtitleText
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
