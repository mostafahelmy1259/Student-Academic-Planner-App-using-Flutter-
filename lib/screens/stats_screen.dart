import 'package:flutter/material.dart';

import '../models/exam_model.dart';
import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../services/exam_service.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../utils/app_feedback.dart';
import '../widgets/empty_state.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: TaskService.instance.streamTasks(),
      builder: (context, taskSnapshot) {
        return StreamBuilder<List<ExamModel>>(
          stream: ExamService.instance.streamExams(),
          builder: (context, examSnapshot) {
            return StreamBuilder<List<SubjectModel>>(
              stream: SubjectService.instance.streamSubjects(),
              builder: (context, subjectSnapshot) {
                if (taskSnapshot.connectionState == ConnectionState.waiting &&
                    examSnapshot.connectionState == ConnectionState.waiting &&
                    subjectSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskSnapshot.hasError ||
                    examSnapshot.hasError ||
                    subjectSnapshot.hasError) {
                  return EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load statistics',
                    message: friendlyAuthMessage(
                      taskSnapshot.error ??
                          examSnapshot.error ??
                          subjectSnapshot.error!,
                    ),
                  );
                }

                final tasks = taskSnapshot.data ?? [];
                final exams = examSnapshot.data ?? [];
                final subjects = subjectSnapshot.data ?? [];

                final completed = tasks.where((task) => task.isDone).length;
                final pending = tasks.length - completed;
                final overdue = tasks.where((task) {
                  return !task.isDone && task.dueDate.isBefore(DateTime.now());
                }).length;
                final highPriority =
                    tasks.where((task) => task.priority == 'High').length;
                final upcomingExams = exams
                    .where((exam) => exam.examDate.isAfter(DateTime.now()))
                    .length;
                final completion = tasks.isEmpty ? 0.0 : completed / tasks.length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Completion',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Based on completed tasks.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: completion,
                                    minHeight: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '${(completion * 100).round()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 700 ? 4 : 2,
                      childAspectRatio:
                          MediaQuery.of(context).size.width > 700 ? 1.15 : 1.0,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _MetricCard(
                          icon: Icons.task_alt_rounded,
                          value: '${tasks.length}',
                          label: 'Total Tasks',
                        ),
                        _MetricCard(
                          icon: Icons.check_circle_rounded,
                          value: '$completed',
                          label: 'Completed',
                        ),
                        _MetricCard(
                          icon: Icons.pending_actions_rounded,
                          value: '$pending',
                          label: 'Pending',
                        ),
                        _MetricCard(
                          icon: Icons.warning_amber_rounded,
                          value: '$overdue',
                          label: 'Overdue',
                        ),
                        _MetricCard(
                          icon: Icons.priority_high_rounded,
                          value: '$highPriority',
                          label: 'High Priority',
                        ),
                        _MetricCard(
                          icon: Icons.event_note_rounded,
                          value: '${exams.length}',
                          label: 'Total Exams',
                        ),
                        _MetricCard(
                          icon: Icons.upcoming_rounded,
                          value: '$upcomingExams',
                          label: 'Upcoming Exams',
                        ),
                        _MetricCard(
                          icon: Icons.menu_book_rounded,
                          value: '${subjects.length}',
                          label: 'Subjects',
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
