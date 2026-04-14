import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/queries.dart';
import 'package:flutter_application_1/features/tasks/data/models/task.dart';
import 'package:flutter_application_1/features/tasks/presentation/create_task_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  void _showInfoDialog(BuildContext context, Map<String, dynamic> pageInfo) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Page info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Total tasks', '${pageInfo['totalCount']}'),
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

  Future<void> _deleteTask(String id, VoidCallback? refetch) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(document: gql(deleteTaskMutation), variables: {'id': id}),
    );

    if (!mounted) {
      return;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: ${result.exception}')),
      );
      return;
    }

    refetch?.call();
  }

  Future<void> _openCreateTaskPage(VoidCallback? refetch) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateTaskPage()));

    if (created == true) {
      refetch?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getTasksQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.hasException) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading tasks:\n${result.exception}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final findAllTasks =
            result.data?['findAllTasks'] as Map<String, dynamic>?;
        final rawTasks = (findAllTasks?['items'] as List?) ?? [];
        final pageInfo = findAllTasks?['pageInfo'] as Map<String, dynamic>?;
        final tasks = rawTasks
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            centerTitle: true,
            actions: [
              if (pageInfo != null)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Page info',
                  onPressed: () => _showInfoDialog(context, pageInfo),
                ),
            ],
          ),
          body: Builder(
            builder: (ctx) {
              if (result.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (result.hasException) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading tasks:\n${result.exception}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No tasks yet'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _openCreateTaskPage(refetch),
                        icon: const Icon(Icons.add),
                        label: const Text('Create a new task'),
                      ),
                    ],
                  ),
                );
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: FilledButton.icon(
                        onPressed: () => _openCreateTaskPage(refetch),
                        icon: const Icon(Icons.add),
                        label: const Text('Create a new task'),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 16),
                    sliver: SliverList.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _TaskCard(
                          task: task,
                          index: index,
                          onDelete: () => _deleteTask(task.id, refetch),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  task.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.completed
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
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
