import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: isDark
            ? AppColors.darkSubtitleText
            : AppColors.lightTextSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.hearing), label: 'Listen'),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Vision',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
