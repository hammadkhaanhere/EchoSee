import 'dart:async';
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
  bool _isListening = false;
  Timer? _timer;
  int _fakeIndex = 0;
  final List<Map<String, String>> _displayed = [];
  final ScrollController _scrollCtrl = ScrollController();

  static const List<Map<String, String>> _fakeSubtitles = [
    {'speaker': 'Speaker 1', 'text': 'Welcome to EchoSee live transcription.'},
    {'speaker': 'Speaker 2', 'text': 'This is a simulated conversation demo.'},
    {'speaker': 'Speaker 1', 'text': 'Each subtitle fades and slides up smoothly.'},
    {'speaker': 'Speaker 2', 'text': 'Tap the mic again to pause at any time.'},
    {'speaker': 'Speaker 1', 'text': 'When all entries are shown it stops.'},
    {'speaker': 'Speaker 2', 'text': 'Transcripts are saved to your Log tab.'},
    {'speaker': 'Speaker 1', 'text': 'Premium users get unlimited history.'},
    {'speaker': 'Speaker 2', 'text': 'With search by keyword or date.'},
    {'speaker': 'Speaker 1', 'text': 'You can also export transcripts as PDF.'},
    {'speaker': 'Speaker 2', 'text': 'Check the Log tab to view them all.'},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final isDark = widget.appState.themeMode == ThemeMode.dark;
        return Scaffold(
          backgroundColor:
               isDark ? AppColors.darkBackground : AppColors.lightBackground,
          body: _PageFadeSwitcher(
            index: _currentIndex,
            pages: _pages,
          ),
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
          color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? AppColors.greenLive : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isListening ? 'Live' : 'Idle',
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
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
                    color: isDark ? AppColors.darkText : AppColors.lightTextPrimary),
                onPressed: () => _showSettingsSheet(),
              ),
              IconButton(
                icon: Icon(Icons.text_fields,
                    color: isDark ? AppColors.darkText : AppColors.lightTextPrimary),
                onPressed: () => _showFontSheet(),
              ),
            ],
          ),
        ],
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
      child: _displayed.isEmpty
          ? Center(
              child: Text(
                'Tap the mic to start',
                style: TextStyle(
                  color:
                      isDark ? AppColors.darkSubtitleText : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _displayed.length,
              itemBuilder: (context, index) {
                final item = _displayed[index];
                return _AnimatedSubtitle(
                  key: ValueKey('sub_${item.hashCode}_$index'),
                  speaker: item['speaker']!,
                  text: item['text']!,
                  isDark: isDark,
                );
              },
            ),
    );
  }

  Widget _buildBottomMic() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: GestureDetector(
        onTap: _toggleListening,
        child: _PulsingMic(isListening: _isListening),
      ),
    );
  }

  void _toggleListening() {
    if (_isListening) {
      _timer?.cancel();
      setState(() => _isListening = false);
    } else {
      if (_fakeIndex >= _fakeSubtitles.length) {
        _fakeIndex = 0;
        _displayed.clear();
      }
      setState(() => _isListening = true);
      _addNext();
      _timer = Timer.periodic(const Duration(seconds: 2), (_) => _addNext());
    }
  }

  void _addNext() {
    if (_fakeIndex >= _fakeSubtitles.length) {
      _timer?.cancel();
      setState(() => _isListening = false);
      return;
    }
    final item = _fakeSubtitles[_fakeIndex];
    _fakeIndex++;

    final t = Transcript(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      speaker: item['speaker']!,
      text: item['text']!,
      timestamp: DateTime.now(),
    );
    widget.appState.addTranscript(t);

    setState(() => _displayed.add(item));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
}

// ─── Pulsing Mic ──────────────────────────────────────────

class _PulsingMic extends StatefulWidget {
  final bool isListening;
  const _PulsingMic({required this.isListening});

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isListening) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingMic old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !old.isListening) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isListening && old.isListening) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isListening ? Colors.redAccent : AppColors.teal,
          boxShadow: [
            BoxShadow(
              color: (widget.isListening ? Colors.redAccent : AppColors.teal)
                  .withValues(alpha: 0.4),
              blurRadius: widget.isListening ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

// ─── Page Fade Switcher ───────────────────────────────────

class _PageFadeSwitcher extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  const _PageFadeSwitcher({required this.index, required this.pages});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: SizedBox(
        key: ValueKey('tab_$index'),
        child: pages[index],
      ),
    );
  }
}

// ─── Animated Subtitle Tile ──────────────────────────────

class _AnimatedSubtitle extends StatefulWidget {
  final String speaker;
  final String text;
  final bool isDark;

  const _AnimatedSubtitle({
    super.key,
    required this.speaker,
    required this.text,
    required this.isDark,
  });

  @override
  State<_AnimatedSubtitle> createState() => _AnimatedSubtitleState();
}

class _AnimatedSubtitleState extends State<_AnimatedSubtitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _buildBubble(),
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
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
              widget.speaker,
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
              widget.text,
              style: TextStyle(
                color: widget.isDark
                    ? AppColors.darkSubtitleText
                    : AppColors.lightSubtitleText,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
