import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../utils/app_feedback.dart';
import '../utils/validators.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSubjectId;
  String _priority = 'Medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _reminderAt;
  bool _isSaving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _notesController.text = task.notes;
      _selectedSubjectId = task.subjectId.isEmpty ? null : task.subjectId;
      _priority = task.priority;
      _dueDate = task.dueDate;
      _reminderAt = task.reminderAt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDueDate() async {
    final picked = await _pickDateTime(_dueDate);
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminder() async {
    final initial = _reminderAt ?? _dueDate.subtract(const Duration(hours: 2));
    final picked = await _pickDateTime(initial);
    if (picked != null) setState(() => _reminderAt = picked);
  }

  Future<void> _save(List<SubjectModel> subjects) async {
    if (!_formKey.currentState!.validate()) return;

    if (_reminderAt != null && _reminderAt!.isAfter(_dueDate)) {
      showAppSnackBar(
        context,
        'Reminder must be before the task due date.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    final existingTask = widget.task;
    SubjectModel? selectedSubject;
    if (_selectedSubjectId != null) {
      for (final subject in subjects) {
        if (subject.id == _selectedSubjectId) {
          selectedSubject = subject;
          break;
        }
      }
    }

    final task = TaskModel(
      id: existingTask?.id ?? '',
      title: _titleController.text.trim(),
      subjectId: selectedSubject?.id ?? '',
      subjectName: selectedSubject?.name ?? '',
      dueDate: _dueDate,
      priority: _priority,
      isDone: existingTask?.isDone ?? false,
      notes: _notesController.text.trim(),
      reminderAt: _reminderAt,
      createdAt: existingTask?.createdAt,
    );

    try {
      final taskId = _isEdit
          ? existingTask!.id
          : await TaskService.instance.addTask(task);

      if (_isEdit) await TaskService.instance.updateTask(task);

      final notificationId =
          NotificationService.instance.notificationIdFromString(taskId);

      await NotificationService.instance.cancelReminder(notificationId);

      if (_reminderAt != null) {
        await NotificationService.instance.scheduleReminder(
          id: notificationId,
          title: 'Task Reminder',
          body: '${task.title} is due soon.',
          scheduledAt: _reminderAt!,
        );
      }

      if (mounted) {
        showAppSnackBar(context, _isEdit ? 'Task updated.' : 'Task saved.');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, friendlyAuthMessage(error), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SubjectModel>>(
      stream: SubjectService.instance.streamSubjects(),
      builder: (context, snapshot) {
        final subjects = snapshot.data ?? [];

        if (_selectedSubjectId == null && subjects.isNotEmpty && !_isEdit) {
          _selectedSubjectId = subjects.first.id;
        }

        final selectedIdExists = subjects.any(
          (subject) => subject.id == _selectedSubjectId,
        );

        final dropdownValue = selectedIdExists ? _selectedSubjectId : null;

        return Scaffold(
          appBar: AppBar(title: Text(_isEdit ? 'Edit Task' : 'Add Task')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Task title',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (value) =>
                              AppValidators.requiredText(value, 'a task title'),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: dropdownValue,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            prefixIcon: Icon(Icons.menu_book_outlined),
                          ),
                          hint: const Text('Select subject'),
                          items: subjects
                              .map(
                                (subject) => DropdownMenuItem(
                                  value: subject.id,
                                  child: Text(subject.name),
                                ),
                              )
                              .toList(),
                          onChanged: (subjectId) {
                            setState(() => _selectedSubjectId = subjectId);
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: const ['High', 'Medium', 'Low']
                              .map(
                                (priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _priority = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DateButton(
                          label: 'Due date',
                          date: _dueDate,
                          onPressed: _pickDueDate,
                        ),
                        const SizedBox(height: 10),
                        _DateButton(
                          label: 'Reminder',
                          date: _reminderAt,
                          onPressed: _pickReminder,
                          emptyText: 'No reminder set',
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _reminderAt == null
                                ? null
                                : () => setState(() => _reminderAt = null),
                            icon: const Icon(Icons.notifications_off_outlined),
                            label: const Text('Clear reminder'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _isSaving ? null : () => _save(subjects),
                          child: _isSaving
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isEdit ? 'Update Task' : 'Save Task'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (subjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'Tip: add subjects first to organize tasks better.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPressed;
  final String emptyText;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onPressed,
    this.emptyText = '',
  });

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? emptyText
        : DateFormat('EEE, d MMM yyyy  •  h:mm a').format(date!);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.event_rounded),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Flexible(child: Text(text, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
