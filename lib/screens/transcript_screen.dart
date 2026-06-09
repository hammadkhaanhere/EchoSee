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
        final filtered = query.isNotEmpty
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
              : AppColors.lightBackground,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                _buildSearchBar(isDark),
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
      child: Text(
        'Transcripts',
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
        color: isDark ? AppColors.darkCard : AppColors.lightFieldBg,
        borderRadius: BorderRadius.circular(_searchExpanded ? 24 : 20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _searchExpanded ? Icons.close : Icons.search,
              color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
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
                style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by speaker or keyword...',
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : AppColors.lightTextSecondary),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          if (!_searchExpanded)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Search',
                style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightTextPrimary,
                    fontSize: 13),
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
              color: isDark ? Colors.white24 : AppColors.lightTextSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'No transcripts yet',
            style: TextStyle(
              color: isDark ? AppColors.darkSubtitleText : AppColors.lightTextSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the mic button to start transcribing',
            style: TextStyle(
              color: isDark ? Colors.white38 : AppColors.lightTextSecondary.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

}
