import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String name;
  final String instructor;
  final String colorHex;
  final DateTime? createdAt;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.instructor,
    required this.colorHex,
    required this.createdAt,
  });

  factory SubjectModel.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      instructor: data['instructor'] ?? '',
      colorHex: data['colorHex'] ?? '3F51B5',
      createdAt: _dateFromFirestore(data['createdAt']),
    );
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Color get color {
    final cleaned = colorHex.replaceAll('#', '');
    return Color(int.parse('0xff$cleaned'));
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'instructor': instructor,
      'colorHex': colorHex.replaceAll('#', ''),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
