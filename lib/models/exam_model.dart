import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String id;
  final String title;
  final String subjectId;
  final String subjectName;
  final DateTime examDate;
  final String location;
  final String notes;
  final DateTime? reminderAt;
  final DateTime? createdAt;

  const ExamModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.examDate,
    required this.location,
    required this.notes,
    required this.reminderAt,
    required this.createdAt,
  });

  factory ExamModel.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return ExamModel(
      id: doc.id,
      title: data['title'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      examDate: _dateFromFirestore(data['examDate']) ?? DateTime.now(),
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      reminderAt: _dateFromFirestore(data['reminderAt']),
      createdAt: _dateFromFirestore(data['createdAt']),
    );
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'examDate': Timestamp.fromDate(examDate),
      'location': location,
      'notes': notes,
      'reminderAt': reminderAt == null ? null : Timestamp.fromDate(reminderAt!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
