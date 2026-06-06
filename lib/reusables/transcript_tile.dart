import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/transcript.dart';
import '../routes/custom_transitions.dart';

class TranscriptTile extends StatefulWidget {
  final Transcript transcript;
  final VoidCallback onTap;
  final int index;
  final bool isDark;

  const TranscriptTile({
    super.key,
    required this.transcript,
    required this.onTap,
    required this.index,
    this.isDark = false,
  });

  @override
  State<TranscriptTile> createState() => _TranscriptTileState();
}

class _TranscriptTileState extends State<TranscriptTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.4, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${widget.transcript.timestamp.day}/${widget.transcript.timestamp.month}/${widget.transcript.timestamp.year}';
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () => _openWithScale(context),
          child: Hero(
            tag: 'transcript_${widget.transcript.id}',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.darkCard
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.transcript.speaker,
                          style: const TextStyle(
                            color: AppColors.speakerLabel,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.transcript.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.isDark
                                ? AppColors.darkSubtitleText
                                : AppColors.subtitleText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: widget.isDark
                          ? AppColors.darkSubtitleText
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openWithScale(BuildContext context) {
    Navigator.push(
      context,
      scaleUpRoute(_TranscriptDetailPage(
        transcript: widget.transcript,
        isDark: widget.isDark,
      )),
    );
  }
}

class _TranscriptDetailPage extends StatelessWidget {
  final Transcript transcript;
  final bool isDark;
  const _TranscriptDetailPage({required this.transcript, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.navyBlue,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.navyBlue,
        title: Text(transcript.speaker,
            style: const TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Hero(
        tag: 'transcript_${transcript.id}',
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transcript.speaker,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                transcript.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkSubtitleText
                      : AppColors.subtitleText,
                ),
              ),
              const Spacer(),
              Text(
                '${transcript.timestamp.day}/${transcript.timestamp.month}/${transcript.timestamp.year} '
                '${transcript.timestamp.hour}:${transcript.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
