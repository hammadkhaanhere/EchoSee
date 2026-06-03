import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echosee_smart_glasses_app/screens/model/transcript.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTranscript(Transcript transcript) async {
    await _firestore
        .collection('transcripts')
        .doc(transcript.id)
        .set(transcript.toJson());
  }

  Future<List<Transcript>> getTranscripts() async {
    final snapshot = await _firestore
        .collection('transcripts')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Transcript.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteTranscript(String id) async {
    await _firestore.collection('transcripts').doc(id).delete();
  }
}