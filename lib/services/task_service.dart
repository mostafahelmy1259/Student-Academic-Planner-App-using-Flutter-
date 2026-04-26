import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import 'firestore_refs.dart';

class TaskService {
  TaskService._();

  static final TaskService instance = TaskService._();

  Stream<List<TaskModel>> streamTasks() {
    return FirestoreRefs.tasks
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromSnapshot).toList());
  }

  Future<String> addTask(TaskModel task) async {
    final doc = await FirestoreRefs.tasks.add(task.toMap());
    return doc.id;
  }

  Future<void> updateTask(TaskModel task) async {
    await FirestoreRefs.tasks.doc(task.id).update({
      'title': task.title,
      'subjectId': task.subjectId,
      'subjectName': task.subjectName,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'priority': task.priority,
      'isDone': task.isDone,
      'notes': task.notes,
      'reminderAt': task.reminderAt == null
          ? null
          : Timestamp.fromDate(task.reminderAt!),
    });
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required bool isDone,
  }) async {
    await FirestoreRefs.tasks.doc(taskId).update({'isDone': isDone});
  }

  Future<void> deleteTask(String taskId) async {
    await FirestoreRefs.tasks.doc(taskId).delete();
  }
}
