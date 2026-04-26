import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exam_model.dart';
import 'firestore_refs.dart';

class ExamService {
  ExamService._();

  static final ExamService instance = ExamService._();

  Stream<List<ExamModel>> streamExams() {
    return FirestoreRefs.exams
        .orderBy('examDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ExamModel.fromSnapshot).toList());
  }

  Future<String> addExam(ExamModel exam) async {
    final doc = await FirestoreRefs.exams.add(exam.toMap());
    return doc.id;
  }

  Future<void> updateExam(ExamModel exam) async {
    await FirestoreRefs.exams.doc(exam.id).update({
      'title': exam.title,
      'subjectId': exam.subjectId,
      'subjectName': exam.subjectName,
      'examDate': Timestamp.fromDate(exam.examDate),
      'location': exam.location,
      'notes': exam.notes,
      'reminderAt': exam.reminderAt == null
          ? null
          : Timestamp.fromDate(exam.reminderAt!),
    });
  }

  Future<void> deleteExam(String examId) async {
    await FirestoreRefs.exams.doc(examId).delete();
  }
}
