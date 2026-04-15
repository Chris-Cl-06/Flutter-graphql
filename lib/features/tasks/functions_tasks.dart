import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/tasks/data/models/task.dart';
import 'package:flutter_application_1/features/tasks/presentation/create_task_page.dart';
import 'package:flutter_application_1/features/tasks/presentation/edit_task_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TaskFunctions {
  static Future<void> openEditTaskPage(
    BuildContext context,
    Task task,
    VoidCallback? refetch,
  ) async {
    final updated = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => EditTaskPage(task: task)));
    if (updated == true) {
      refetch?.call();
    }
  }

  static Future<void> openCreateTaskPage(
    BuildContext context,
    VoidCallback? refetch,
  ) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateTaskPage()));

    if (created == true) {
      refetch?.call();
    }
  }

  static Future<void> deleteTask(
    BuildContext context,
    String id,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(document: gql(deleteTaskMutation), variables: {'id': id}),
    );

    if (!context.mounted) {
      return;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: ${result.exception}')),
      );
      return;
    }

    if (kDebugMode) {
      print(result.data);
    }

    refetch?.call();
  }

  static Future<void> toggleTaskState(
    BuildContext context,
    String id,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(document: gql(toggleTaskMutation), variables: {'id': id}),
    );

    if (!context.mounted) {
      return;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: ${result.exception}')),
      );
      return;
    }

    refetch?.call();
  }

  static void showInfoDialog(
    BuildContext context,
    Map<String, dynamic> pageInfo,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Page info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Total tasks', '${pageInfo['totalCount']}'),
            _InfoRow(
              'Pending tasks',
              '${pageInfo['totalCount'] - (pageInfo['taskCompleted'] ?? 0)}',
            ),
            _InfoRow('Completed tasks', '${pageInfo['taskCompleted'] ?? 0}'),
            _InfoRow('Offset', '${pageInfo['offset'] ?? 0}'),
            _InfoRow('Limit', '${pageInfo['limit'] ?? '-'}'),
            _InfoRow('Has next page', '${pageInfo['hasNextPage'] ?? false}'),
            _InfoRow(
              'Has previous page',
              '${pageInfo['hasPreviousPage'] ?? false}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Text(value),
        ],
      ),
    );
  }
}
