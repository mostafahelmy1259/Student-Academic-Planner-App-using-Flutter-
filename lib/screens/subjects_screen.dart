import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../utils/app_feedback.dart';
import '../utils/validators.dart';
import '../widgets/empty_state.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  Future<void> _openSubjectDialog(
    BuildContext context, {
    SubjectModel? subject,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => _SubjectDialog(subject: subject),
    );
  }

  Future<void> _deleteSubject(BuildContext context, SubjectModel subject) async {
    final shouldDelete = await confirmAction(
      context,
      title: 'Delete subject?',
      message: 'This deletes "${subject.name}" from the subjects list. Existing tasks keep their saved subject name.',
    );

    if (!shouldDelete) return;

    try {
      await SubjectService.instance.deleteSubject(subject.id);
      if (context.mounted) showAppSnackBar(context, 'Subject deleted.');
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyAuthMessage(error), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<SubjectModel>>(
        stream: SubjectService.instance.streamSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load subjects',
              message: friendlyAuthMessage(snapshot.error!),
            );
          }

          final subjects = snapshot.data ?? [];

          if (subjects.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'No subjects yet',
              message: 'Add subjects such as Database, Programming, Math, or English.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: subject.color,
                    child: const Icon(Icons.book_rounded, color: Colors.white),
                  ),
                  title: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subject.instructor.isEmpty
                          ? 'No instructor added'
                          : 'Instructor: ${subject.instructor}',
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openSubjectDialog(context, subject: subject);
                      }

                      if (value == 'delete') {
                        _deleteSubject(context, subject);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
        onPressed: () => _openSubjectDialog(context),
      ),
    );
  }
}

class _SubjectDialog extends StatefulWidget {
  final SubjectModel? subject;

  const _SubjectDialog({this.subject});

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructorController = TextEditingController();

  String _colorHex = '3657D6';
  bool _isSaving = false;

  final _colors = const [
    '3657D6',
    '00A896',
    'E91E63',
    'FF9800',
    '4CAF50',
    '9C27B0',
    '607D8B',
    '795548',
  ];

  @override
  void initState() {
    super.initState();

    final subject = widget.subject;

    if (subject != null) {
      _nameController.text = subject.name;
      _instructorController.text = subject.instructor;
      _colorHex = subject.colorHex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final subject = widget.subject;

      if (subject == null) {
        await SubjectService.instance.addSubject(
          name: _nameController.text,
          instructor: _instructorController.text,
          colorHex: _colorHex,
        );
      } else {
        await SubjectService.instance.updateSubject(
          subjectId: subject.id,
          name: _nameController.text,
          instructor: _instructorController.text,
          colorHex: _colorHex,
        );
      }

      if (mounted) {
        showAppSnackBar(
          context,
          subject == null ? 'Subject added.' : 'Subject updated.',
        );
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
    return AlertDialog(
      title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Subject name',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: (value) => AppValidators.requiredText(value, 'a subject name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _colorHex,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
                items: _colors
                    .map(
                      (color) => DropdownMenuItem(
                        value: color,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(int.parse('0xff$color')),
                            ),
                            const SizedBox(width: 8),
                            Text('#$color'),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _colorHex = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
