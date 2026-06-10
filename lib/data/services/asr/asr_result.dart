class AsrResult {
  const AsrResult({
    required this.text,
    required this.isFinal,
    this.confidence,
    this.timestamp,
  });

  final String text;
  final bool isFinal;
  final double? confidence;
  final DateTime? timestamp;
}
