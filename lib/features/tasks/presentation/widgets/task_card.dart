import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/tasks/data/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onDelete,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: task.completed
          ? Colors.greenAccent.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    task.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.completed
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              '#${index + 1}  ·  ${task.completed ? 'Completed' : 'Pending'}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${task.description?.isNotEmpty == true ? task.description : '-'}',
            ),
            Text(
              'Category: ${task.categoryName?.isNotEmpty == true ? task.categoryName : '-'}',
            ),
          ],
        ),
      ),
    );
  }
}
