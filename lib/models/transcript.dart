class Transcript {
  final String id;
  final String speaker;
  final String text;
  final DateTime timestamp;

  Transcript({
    required this.id,
    required this.speaker,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'speaker': speaker,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Transcript.fromJson(Map<String, dynamic> json) => Transcript(
        id: json['id'] as String,
        speaker: json['speaker'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
