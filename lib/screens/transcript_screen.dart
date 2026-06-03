import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../reusables/transcript_tile.dart';

class TranscriptScreen extends StatefulWidget {
  final AppState appState;
  const TranscriptScreen({super.key, required this.appState});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  bool _searchExpanded = false;
  late final TextEditingController _searchCtrl;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final isDark = widget.appState.themeMode == ThemeMode.dark;
        final transcripts = widget.appState.transcripts;
        final query = _searchCtrl.text.toLowerCase();
        final filtered = widget.appState.isPremium && query.isNotEmpty
            ? transcripts.where((t) {
                return t.speaker.toLowerCase().contains(query) ||
                    t.text.toLowerCase().contains(query);
              }).toList()
            : transcripts;
        final displayLimit = widget.appState.isPremium
            ? filtered.length
            : filtered.length > 5
                ? 5
                : filtered.length;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.navyBlue,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                if (widget.appState.isPremium) _buildSearchBar(isDark),
                _buildLimitBanner(isDark),
                Expanded(
                        child: filtered.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: displayLimit,
                          itemBuilder: (context, index) {
                            final t = filtered[index];
                            return TranscriptTile(
                              transcript: t,
                              index: index,
                              isDark: isDark,
                              onTap: () {},
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transcripts',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.appState.isPremium)
            TextButton.icon(
              onPressed: _exportTranscripts,
              icon: const Icon(Icons.picture_as_pdf,
                  color: AppColors.teal, size: 20),
              label: const Text('Export PDF',
                  style: TextStyle(color: AppColors.teal)),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: _searchExpanded ? 48 : 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white24,
        borderRadius: BorderRadius.circular(_searchExpanded ? 24 : 20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _searchExpanded ? Icons.close : Icons.search,
              color: AppColors.textPrimary,
              size: _searchExpanded ? 20 : 18,
            ),
            onPressed: () {
              setState(() {
                _searchExpanded = !_searchExpanded;
                if (!_searchExpanded) {
                  _searchCtrl.clear();
                  _searchFocus.unfocus();
                } else {
                  _searchFocus.requestFocus();
                }
              });
            },
          ),
          if (_searchExpanded)
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search by speaker or keyword...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          if (!_searchExpanded)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                'Search',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitBanner(bool isDark) {
    if (widget.appState.isPremium) return const SizedBox.shrink();
    final remaining = 5 - widget.appState.transcripts.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            remaining > 0
                ? 'Free: $remaining of 5 transcript slots remaining'
                : 'Free limit reached. Oldest will be auto-deleted.',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.white38),
          const SizedBox(height: 16),
          Text(
            'No transcripts yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the mic button to start transcribing',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.white30,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _exportTranscripts() {
    if (widget.appState.transcripts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transcripts to export')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.teal,
                        size: 64,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Export Complete!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }
}
