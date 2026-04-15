import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/app_gradient_background.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/queries.dart';
import 'package:flutter_application_1/features/tasks/data/models/task.dart';
import 'package:flutter_application_1/features/tasks/functions_tasks.dart';
import 'package:flutter_application_1/features/tasks/presentation/widgets/task_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  static const int _easterEggTapTarget = 6;
  static const Duration _tapResetWindow = Duration(milliseconds: 1200);
  static const Duration _easterEggDuration = Duration(seconds: 5);
  static const String _easterEggGifUrl =
      'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExY25kYTY3YjRiM2Z2cnhoc25nOXhmcmhhejAyd2c1ZzZ5aGMzbjY0ayZlcD12MV9naWZzX3NlYXJjaCZjdD1n/YaP3iYxN3T8nIEN5rD/giphy.gif';

  int _titleTapCount = 0;
  Timer? _titleTapResetTimer;
  Timer? _easterEggCloseTimer;
  bool _isEasterEggOpen = false;

  static const int _limit = 5;
  int _offset = 0;

  void _onTareasTitleTap() {
    _titleTapResetTimer?.cancel();
    _titleTapCount += 1;

    if (_titleTapCount >= _easterEggTapTarget) {
      _titleTapCount = 0;
      _showEasterEggGif();
      return;
    }

    _titleTapResetTimer = Timer(_tapResetWindow, () {
      _titleTapCount = 0;
    });
  }

  void _showEasterEggGif() {
    if (!_isEasterEggOpen) {
      setState(() {
        _isEasterEggOpen = true;
      });
    }

    _easterEggCloseTimer?.cancel();
    _easterEggCloseTimer = Timer(_easterEggDuration, () {
      if (!mounted) {
        return;
      }
      if (_isEasterEggOpen) {
        setState(() {
          _isEasterEggOpen = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleTapResetTimer?.cancel();
    _easterEggCloseTimer?.cancel();
    super.dispose();
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

        final listContent = tasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Todavia no hay tareas'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          TaskFunctions.openCreateTaskPage(context, refetch),
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
                        onPressed: () =>
                            TaskFunctions.openCreateTaskPage(context, refetch),
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
                                style: Theme.of(context).textTheme.titleSmall,
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
                      return TaskCard(
                        task: task,
                        index: _offset + index,
                        onDelete: () =>
                            TaskFunctions.deleteTask(context, task.id, refetch),
                        onEdit: () => TaskFunctions.openEditTaskPage(
                          context,
                          task,
                          refetch,
                        ),
                        onToggle: () => TaskFunctions.toggleTaskState(
                          context,
                          task.id,
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
                                    () => _offset = (_offset - _limit).clamp(
                                      0,
                                      _offset,
                                    ),
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
              );

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: GestureDetector(
              onTap: _onTareasTitleTap,
              child: const Text('Tareas'),
            ),
            centerTitle: true,
            actions: [
              if (pageInfo != null)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info de pagina',
                  onPressed: () =>
                      TaskFunctions.showInfoDialog(context, pageInfo),
                ),
            ],
          ),
          body: AppGradientBackground(
            child: Stack(
              fit: StackFit.expand,
              children: [
                listContent,
                if (_isEasterEggOpen)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.18),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _easterEggGifUrl,
                          width: 260,
                          height: 260,
                          fit: BoxFit.cover,
                        ),
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
