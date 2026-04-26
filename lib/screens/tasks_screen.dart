import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import '../utils/app_feedback.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_chip.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _statusFilter = 'All';
  String _priorityFilter = 'All';

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    return tasks.where((task) {
      final matchesStatus = switch (_statusFilter) {
        'Completed' => task.isDone,
        'Pending' => !task.isDone,
        _ => true,
      };

      final matchesPriority =
          _priorityFilter == 'All' || task.priority == _priorityFilter;

      return matchesStatus && matchesPriority;
    }).toList();
  }

  Future<void> _deleteTask(TaskModel task) async {
    final shouldDelete = await confirmAction(
      context,
      title: 'Delete task?',
      message: 'This will permanently delete "${task.title}".',
    );

    if (!shouldDelete) return;

    try {
      await TaskService.instance.deleteTask(task.id);

      await NotificationService.instance.cancelReminder(
        NotificationService.instance.notificationIdFromString(task.id),
      );

      if (mounted) {
        showAppSnackBar(context, 'Task deleted.');
      }
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, friendlyAuthMessage(error), isError: true);
      }
    }
  }

  Future<void> _updateStatus(TaskModel task, bool value) async {
    try {
      await TaskService.instance.updateTaskStatus(
        taskId: task.id,
        isDone: value,
      );
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, friendlyAuthMessage(error), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService.instance.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load tasks',
              message: friendlyAuthMessage(snapshot.error!),
            );
          }

          final allTasks = snapshot.data ?? [];
          final tasks = _applyFilters(allTasks);

          return Column(
            children: [
              _FilterBar(
                statusFilter: _statusFilter,
                priorityFilter: _priorityFilter,
                totalCount: allTasks.length,
                shownCount: tasks.length,
                onStatusChanged: (value) {
                  setState(() => _statusFilter = value);
                },
                onPriorityChanged: (value) {
                  setState(() => _priorityFilter = value);
                },
              ),
              Expanded(
                child: tasks.isEmpty
                    ? EmptyState(
                        icon: Icons.task_alt_rounded,
                        title:
                            allTasks.isEmpty ? 'No tasks yet' : 'No tasks found',
                        message: allTasks.isEmpty
                            ? 'Create your first task and set a deadline reminder.'
                            : 'Try changing the selected filters.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return _TaskCard(
                            task: task,
                            onStatusChanged: (value) {
                              _updateStatus(task, value ?? false);
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskFormScreen(task: task),
                                ),
                              );
                            },
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String statusFilter;
  final String priorityFilter;
  final int totalCount;
  final int shownCount;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;

  const _FilterBar({
    required this.statusFilter,
    required this.priorityFilter,
    required this.totalCount,
    required this.shownCount,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$shownCount of $totalCount tasks',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.filter_list_rounded),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final stackFilters = constraints.maxWidth < 360;

                final statusDropdown = _FilterDropdown(
                  label: 'Status',
                  value: statusFilter,
                  items: const ['All', 'Pending', 'Completed'],
                  onChanged: onStatusChanged,
                );

                final priorityDropdown = _FilterDropdown(
                  label: 'Priority',
                  value: priorityFilter,
                  items: const ['All', 'High', 'Medium', 'Low'],
                  onChanged: onPriorityChanged,
                );

                if (stackFilters) {
                  return Column(
                    children: [
                      statusDropdown,
                      const SizedBox(height: 10),
                      priorityDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: statusDropdown),
                    const SizedBox(width: 10),
                    Expanded(child: priorityDropdown),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<bool?> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.isDone && task.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 42,
              child: Checkbox(
                value: task.isDone,
                onChanged: onStatusChanged,
              ),
            ),
            const SizedBox(width: 8),

            // Main task content. Expanded prevents right overflow.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: Icons.menu_book_outlined,
                            label: task.subjectName.isEmpty
                                ? 'No subject'
                                : task.subjectName,
                            maxWidth: constraints.maxWidth,
                          ),
                          if (isOverdue)
                            _InfoPill(
                              icon: Icons.warning_amber_rounded,
                              label: 'Overdue',
                              isWarning: true,
                              maxWidth: constraints.maxWidth,
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _SafeDateLine(date: task.dueDate),
                  if (task.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Fixed right side. FittedBox prevents chip overflow.
            SizedBox(
              width: 82,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: PriorityChip(priority: task.priority),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert_rounded),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        }

                        if (value == 'delete') {
                          onDelete();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeDateLine extends StatelessWidget {
  final DateTime date;

  const _SafeDateLine({
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final text = DateFormat('EEE, dd MMM yyyy').format(date);

    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;
  final double maxWidth;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.maxWidth,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? Colors.red : Theme.of(context).colorScheme.primary;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Container(
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
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}