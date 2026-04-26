import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreRefs {
  FirestoreRefs._();

  static String get userId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('No logged-in user found.');
    }

    return user.uid;
  }

  static DocumentReference<Map<String, dynamic>> get userDoc {
    return FirebaseFirestore.instance.collection('users').doc(userId);
  }

  static CollectionReference<Map<String, dynamic>> get subjects {
    return userDoc.collection('subjects');
  }

  static CollectionReference<Map<String, dynamic>> get tasks {
    return userDoc.collection('tasks');
  }

  static CollectionReference<Map<String, dynamic>> get exams {
    return userDoc.collection('exams');
  }
}
