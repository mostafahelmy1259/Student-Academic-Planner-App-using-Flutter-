import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subject_model.dart';
import 'firestore_refs.dart';

class SubjectService {
  SubjectService._();

  static final SubjectService instance = SubjectService._();

  Stream<List<SubjectModel>> streamSubjects() {
    return FirestoreRefs.subjects
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(SubjectModel.fromSnapshot).toList(),
        );
  }

  Future<String> addSubject({
    required String name,
    required String instructor,
    required String colorHex,
  }) async {
    final doc = await FirestoreRefs.subjects.add({
      'name': name.trim(),
      'instructor': instructor.trim(),
      'colorHex': colorHex.replaceAll('#', ''),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updateSubject({
    required String subjectId,
    required String name,
    required String instructor,
    required String colorHex,
  }) async {
    await FirestoreRefs.subjects.doc(subjectId).update({
      'name': name.trim(),
      'instructor': instructor.trim(),
      'colorHex': colorHex.replaceAll('#', ''),
    });
  }

  Future<void> deleteSubject(String subjectId) async {
    await FirestoreRefs.subjects.doc(subjectId).delete();
  }
}
