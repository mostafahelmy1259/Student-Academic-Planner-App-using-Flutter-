import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String subjectId;
  final String subjectName;
  final DateTime dueDate;
  final String priority;
  final bool isDone;
  final String notes;
  final DateTime? reminderAt;
  final DateTime? createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.dueDate,
    required this.priority,
    required this.isDone,
    required this.notes,
    required this.reminderAt,
    required this.createdAt,
  });

  factory TaskModel.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      dueDate: _dateFromFirestore(data['dueDate']) ?? DateTime.now(),
      priority: data['priority'] ?? 'Medium',
      isDone: data['isDone'] ?? false,
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
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isDone': isDone,
      'notes': notes,
      'reminderAt': reminderAt == null ? null : Timestamp.fromDate(reminderAt!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
