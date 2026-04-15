import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/app_gradient_background.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/queries.dart';
import 'package:flutter_application_1/features/tasks/data/models/task.dart';
import 'package:flutter_application_1/features/tasks/presentation/create_task_page.dart';
import 'package:flutter_application_1/features/tasks/presentation/edit_task_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  Future<void> _openEditTaskPage(Task task, VoidCallback? refetch) async {
    final updated = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => EditTaskPage(task: task)));
    if (updated == true) {
      refetch?.call();
    }
  }

  static const int _limit = 5;
  int _offset = 0;

  void _showInfoDialog(
    BuildContext context,
    Map<String, dynamic> pageInfo,
    // int pendingCount,
    // int completedCount,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Page info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Total tasks', '${pageInfo['totalCount']}'),
            // _InfoRow('Pending tasks', '$pendingCount'),
            // _InfoRow('Completed tasks', '$completedCount'),
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

  //metodo para eliminar , se llama al apretar el icono de basura
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

    print(result.data);

    refetch?.call();
  }

  Future<void> _editTaskState(
    String id,
    bool completed,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateTaskMutation),
        variables: {
          'id': id,
          'input': {'completed': completed},
        },
      ),
    );
    if (!mounted) return;
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: [31m${result.exception}[0m'),
        ),
      );
      return;
    }
    refetch?.call();
  }

  //Metodo que abre la pagina de crear una task
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
        variables: {'offset': _offset, 'limit': _limit},
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
        final totalCount = (pageInfo?['totalCount'] as num?)?.toInt() ?? 0;
        final hasNextPage = (pageInfo?['hasNextPage'] as bool?) ?? false;
        final hasPreviousPage =
            (pageInfo?['hasPreviousPage'] as bool?) ?? false;
        final totalPages = ((totalCount + _limit - 1) ~/ _limit).clamp(
          1,
          999999,
        );
        final currentPage = (_offset ~/ _limit) + 1;
        // final pendingCount = rawTasks
        //     .where((t) => t['completed'] == false)
        //     .length;
        // final completedCount = rawTasks
        //     .where((t) => t['completed'] == true)
        //     .length;

        final tasks = rawTasks
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Tareas'),
            centerTitle: true,
            actions: [
              if (pageInfo != null)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info de pagina',
                  onPressed: () => _showInfoDialog(
                    context,
                    pageInfo /*, pendingCount, completedCount*/,
                  ),
                ),
            ],
          ),
          body: AppGradientBackground(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Todavia no hay tareas'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _openCreateTaskPage(refetch),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear nueva tarea'),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
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
                            label: const Text('Crear nueva tarea'),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insights_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Mostrando ${tasks.length} de $totalCount tareas',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverList.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _TaskCard(
                            task: task,
                            index: _offset + index,
                            onDelete: () => _deleteTask(task.id, refetch),
                            onEdit: () => _openEditTaskPage(task, refetch),
                            onToggle: () => _editTaskState(
                              task.id,
                              !task.completed,
                              refetch,
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.chevron_left),
                                tooltip: 'Pagina anterior',
                                onPressed: hasPreviousPage
                                    ? () => setState(
                                        () => _offset = (_offset - _limit)
                                            .clamp(0, _offset),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$currentPage / $totalPages',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(width: 16),
                              IconButton.outlined(
                                icon: const Icon(Icons.chevron_right),
                                tooltip: 'Pagina siguiente',
                                onPressed: hasNextPage
                                    ? () => setState(() => _offset += _limit)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _TaskCard({
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
