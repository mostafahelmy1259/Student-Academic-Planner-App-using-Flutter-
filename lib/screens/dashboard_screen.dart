import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/exam_model.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/exam_service.dart';
import '../services/task_service.dart';
import '../utils/app_feedback.dart';
import '../widgets/date_line.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_chip.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  List<TaskModel> _upcomingTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    final result = tasks
        .where((task) => !task.isDone && task.dueDate.isAfter(now))
        .toList();
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result.take(3).toList();
  }

  List<ExamModel> _upcomingExams(List<ExamModel> exams) {
    final now = DateTime.now();
    final result = exams.where((exam) => exam.examDate.isAfter(now)).toList();
    result.sort((a, b) => a.examDate.compareTo(b.examDate));
    return result.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: TaskService.instance.streamTasks(),
      builder: (context, taskSnapshot) {
        return StreamBuilder<List<ExamModel>>(
          stream: ExamService.instance.streamExams(),
          builder: (context, examSnapshot) {
            if (taskSnapshot.connectionState == ConnectionState.waiting &&
                examSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskSnapshot.hasError || examSnapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load dashboard',
                message: friendlyAuthMessage(
                  taskSnapshot.error ?? examSnapshot.error!,
                ),
              );
            }

            final tasks = taskSnapshot.data ?? [];
            final exams = examSnapshot.data ?? [];

            final totalTasks = tasks.length;
            final doneTasks = tasks.where((task) => task.isDone).length;
            final pendingTasks = totalTasks - doneTasks;
            final overdueTasks = tasks
                .where((task) => !task.isDone && task.dueDate.isBefore(DateTime.now()))
                .length;
            final completion = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

            final upcomingTasks = _upcomingTasks(tasks);
            final upcomingExams = _upcomingExams(exams);

            return ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                _GreetingCard(
                  pendingTasks: pendingTasks,
                  overdueTasks: overdueTasks,
                  upcomingExams: upcomingExams.length,
                  completion: completion,
                ),
                const _SectionTitle(title: 'Upcoming Tasks'),
                if (upcomingTasks.isEmpty)
                  const _DashboardEmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'No upcoming tasks',
                    message: 'Add tasks to see the nearest deadlines here.',
                  )
                else
                  ...upcomingTasks.map((task) => _TaskPreview(task: task)),
                const _SectionTitle(title: 'Upcoming Exams'),
                if (upcomingExams.isEmpty)
                  const _DashboardEmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'No upcoming exams',
                    message: 'Add your exam schedule to see it here.',
                  )
                else
                  ...upcomingExams.map((exam) => _ExamPreview(exam: exam)),
              ],
            );
          },
        );
      },
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _DashboardEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: EmptyState(
        icon: icon,
        title: title,
        message: message,
        compact: true,
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final int pendingTasks;
  final int overdueTasks;
  final int upcomingExams;
  final double completion;

  const _GreetingCard({
    required this.pendingTasks,
    required this.overdueTasks,
    required this.upcomingExams,
    required this.completion,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (completion * 100).round();
    final user = AuthService.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Student';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            const Color(0xFF6982F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Study progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Pending',
                  value: '$pendingTasks',
                  icon: Icons.pending_actions_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Overdue',
                  value: '$overdueTasks',
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Exams',
                  value: '$upcomingExams',
                  icon: Icons.school_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _TaskPreview extends StatelessWidget {
  final TaskModel task;

  const _TaskPreview({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.task_alt_rounded),
        ),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.subjectName.isEmpty ? 'No subject' : task.subjectName),
              const SizedBox(height: 6),
              DateLine(date: task.dueDate),
            ],
          ),
        ),
        trailing: PriorityChip(priority: task.priority),
      ),
    );
  }
}

class _ExamPreview extends StatelessWidget {
  final ExamModel exam;

  const _ExamPreview({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          foregroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.school_rounded),
        ),
        title: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.subjectName.isEmpty ? 'No subject' : exam.subjectName),
              const SizedBox(height: 6),
              DateLine(date: exam.examDate, icon: Icons.event_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
