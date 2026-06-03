import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speaker': speaker,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      id: json['id'] ?? '',
      speaker: json['speaker'] ?? '',
      text: json['text'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}