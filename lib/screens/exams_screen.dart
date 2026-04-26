import 'package:flutter/material.dart';

import '../models/exam_model.dart';
import '../services/exam_service.dart';
import '../services/notification_service.dart';
import '../utils/app_feedback.dart';
import '../widgets/date_line.dart';
import '../widgets/empty_state.dart';
import 'exam_form_screen.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  Future<void> _deleteExam(BuildContext context, ExamModel exam) async {
    final shouldDelete = await confirmAction(
      context,
      title: 'Delete exam?',
      message: 'This will permanently delete "${exam.title}".',
    );

    if (!shouldDelete) return;

    try {
      await ExamService.instance.deleteExam(exam.id);
      await NotificationService.instance.cancelReminder(
        NotificationService.instance.notificationIdFromString('exam-${exam.id}'),
      );
      if (context.mounted) showAppSnackBar(context, 'Exam deleted.');
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyAuthMessage(error), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ExamModel>>(
        stream: ExamService.instance.streamExams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load exams',
              message: friendlyAuthMessage(snapshot.error!),
            );
          }

          final exams = snapshot.data ?? [];

          if (exams.isEmpty) {
            return const EmptyState(
              icon: Icons.event_note_rounded,
              title: 'No exams yet',
              message: 'Add your upcoming exams and revision reminders.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final isPast = exam.examDate.isBefore(DateTime.now());

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: isPast
                        ? Colors.grey.shade200
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    foregroundColor: isPast
                        ? Colors.grey.shade700
                        : Theme.of(context).colorScheme.primary,
                    child: Icon(isPast ? Icons.history_rounded : Icons.school_rounded),
                  ),
                  title: Text(
                    exam.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ExamPill(
                              icon: Icons.menu_book_outlined,
                              label: exam.subjectName.isEmpty ? 'No subject' : exam.subjectName,
                            ),
                            if (isPast)
                              const _ExamPill(
                                icon: Icons.history_rounded,
                                label: 'Past exam',
                                muted: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DateLine(date: exam.examDate, icon: Icons.event_rounded),
                        if (exam.location.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 6),
                              Expanded(child: Text(exam.location)),
                            ],
                          ),
                        ],
                        if (exam.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            exam.notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamFormScreen(exam: exam),
                          ),
                        );
                      }

                      if (value == 'delete') {
                        _deleteExam(context, exam);
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
        label: const Text('Add Exam'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExamFormScreen()),
          );
        },
      ),
    );
  }
}

class _ExamPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool muted;

  const _ExamPill({
    required this.icon,
    required this.label,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted ? Colors.grey.shade700 : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
