import 'package:echosee_smart_glasses_app/screens/model/transcript.dart';
import 'package:echosee_smart_glasses_app/screens/services/firebaseservices.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<Transcript> transcripts = [];

  Future<void> loadTranscripts() async {
    transcripts = await _firestore.getTranscripts();
    notifyListeners();
  }

  Future<void> addTranscript(Transcript transcript) async {
    await _firestore.addTranscript(transcript);

    transcripts.insert(0, transcript);
    notifyListeners();
  }

  Future<void> deleteTranscript(String id) async {
    await _firestore.deleteTranscript(id);

    transcripts.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
