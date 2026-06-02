import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../reusables/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  late final List<Widget> _pages = [
    _buildLogPage(),
    _buildListenPage(),
    _buildVisionPage(),
    _buildMePage(),
  ];

  Widget _buildLogPage() {
    return const Center(
      child: Text(
        'Conversation Logs',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
    );
  }

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
    return const Center(
      child: Text(
        'Vision Assistance',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
    );
  }

  Widget _buildMePage() {
    return const Center(
      child: Text(
        'Profile & Settings',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
    );
  }
  Widget _buildTopBar() {
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
                icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.text_fields,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.subtitleBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _subtitles.length,
        itemBuilder: (context, index) {
          final item = _subtitles[index];
          return _buildDialogueBubble(item['speaker']!, item['text']!);
        },
      ),
    );
  }

  Widget _buildDialogueBubble(String speaker, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
              style: const TextStyle(
                color: AppColors.subtitleText,
                fontSize: 14,
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
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
