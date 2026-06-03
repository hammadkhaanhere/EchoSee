import 'package:flutter/material.dart';
import '../state/app_state.dart';

class ThemeToggle extends StatelessWidget {
  final AppState appState;

  const ThemeToggle({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.themeMode == ThemeMode.dark;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            GestureDetector(
              onTap: appState.toggleTheme,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark ? Colors.teal : Colors.grey[400],
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  alignment:
                      isDark ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 14,
                      color: isDark ? Colors.teal : Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
