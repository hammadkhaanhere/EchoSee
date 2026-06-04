import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../reusables/app_bottom_nav.dart';
import '../reusables/font_size_selector.dart';
import '../reusables/theme_toggle.dart';
import '../reusables/subtitle_customizer.dart';
import '../models/transcript.dart';
import 'transcript_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  final List<Map<String, String>> _subtitles = [
    {'speaker': 'Speaker 1', 'text': 'Hello, how are you today?'},
    {'speaker': 'Speaker 2', 'text': 'I am doing great, thanks for asking!'},
    {'speaker': 'Speaker 1', 'text': 'Are you coming to the meeting later?'},
    {'speaker': 'Speaker 2', 'text': 'Yes, I will be there at 3 PM sharp.'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final isDark = widget.appState.themeMode == ThemeMode.dark;
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.navyBlue,
          body: _pages[_currentIndex],
          bottomNavigationBar: AppBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }

  List<Widget> get _pages => [
        TranscriptScreen(appState: widget.appState),
        _buildListenPage(),
        _buildVisionPage(),
        ProfileScreen(appState: widget.appState),
      ];

  Widget _buildListenPage() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildSubtitleArea()),
          _buildBottomMic(),
        ],
      ),
    );
  }

  Widget _buildVisionPage() {
    final isDark = widget.appState.themeMode == ThemeMode.dark;
    return Center(
      child: Text(
        'Vision Assistance',
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isDark = widget.appState.themeMode == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenLive,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Live',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.settings,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary),
                onPressed: () => _showSettingsSheet(),
              ),
              IconButton(
                icon: Icon(Icons.text_fields,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary),
                onPressed: () => _showFontSheet(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFontSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: FontSizeSelector(appState: widget.appState),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ThemeToggle(appState: widget.appState),
            const Divider(height: 32),
            SubtitleCustomizer(appState: widget.appState),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleArea() {
    final isDark = widget.appState.themeMode == ThemeMode.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? widget.appState.subtitleBgColor.withValues(alpha: 0.15)
            : widget.appState.subtitleBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _subtitles.length,
        itemBuilder: (context, index) {
          final item = _subtitles[index];
          return _buildDialogueBubble(item['speaker']!, item['text']!, isDark);
        },
      ),
    );
  }

  Widget _buildDialogueBubble(String speaker, String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.speakerLabel.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              speaker,
              style: const TextStyle(
                color: AppColors.speakerLabel,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? AppColors.darkSubtitleText : AppColors.subtitleText,
                fontSize: 14 * widget.appState.textScaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomMic() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.mic, color: Colors.white, size: 32),
            onPressed: () {
              final t = Transcript(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                speaker: 'Speaker ${(_subtitles.length % 2) + 1}',
                text: 'Simulated transcription entry.',
                timestamp: DateTime.now(),
              );
              widget.appState.addTranscript(t);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transcript saved'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
