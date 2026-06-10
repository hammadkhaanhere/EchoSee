class TranscriptItem {
  const TranscriptItem({
    required this.text,
    required this.translation,
    required this.speakerLabel,
    required this.timestamp,
    this.isFinal = true,
  });

  final String text;
  final String translation;
  final String speakerLabel;
  final DateTime timestamp;
  final bool isFinal;
}
