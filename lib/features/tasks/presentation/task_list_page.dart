import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:flutter_application_1/core/widgets/app_gradient_background.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
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

  static const int _limit = 4;
  int _offset = 0;
  final Set<String> _selectedCategoryIds = <String>{};

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
      setState(() => _isEasterEggOpen = true);
    }

    _easterEggCloseTimer?.cancel();
    _easterEggCloseTimer = Timer(_easterEggDuration, () {
      if (!mounted) return;
      if (_isEasterEggOpen) {
        setState(() => _isEasterEggOpen = false);
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
        variables: {
          'offset': _offset,
          'limit': _limit,
          'categoryId': _selectedCategoryIds.isEmpty
              ? null
              : _selectedCategoryIds.toList(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.hasException) {
          return Center(child: Text('Error: ${result.exception}'));
        }

        // --- PROCESAMIENTO DE TAREAS ---
        final findAllTasks =
            result.data?['findAllTasks'] as Map<String, dynamic>?;
        final rawTasks = (findAllTasks?['items'] as List?) ?? [];
        final pageInfo = findAllTasks?['pageInfo'] as Map<String, dynamic>?;
        final totalCount = (pageInfo?['totalCount'] as num?)?.toInt() ?? 0;

        final tasks = rawTasks
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();

        // --- LÓGICA DE PAGINACIÓN ---
        final hasPreviousPage = _offset > 0;
        final hasNextPage = _offset + _limit < totalCount;
        final totalPages = ((totalCount + _limit - 1) ~/ _limit).clamp(
          1,
          999999,
        );
        final currentPage = (_offset ~/ _limit) + 1;

        // --- CONSTRUCCIÓN DEL CONTENIDO (CustomScrollView) ---
        final listContent =
            (tasks.isEmpty && !result.isLoading && _selectedCategoryIds.isEmpty)
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Todavía no hay tareas'),
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
                  // 1. Botón Crear
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

                  // 2. Info de contador
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
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
                                _selectedCategoryIds.isEmpty
                                    ? 'Mostrando ${tasks.length} de $totalCount tareas'
                                    : 'Mostrando ${tasks.length} resultados filtrados',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. SCROLL HORIZONTAL DE FILTROS
                  SliverToBoxAdapter(
                    child: Query(
                      options: QueryOptions(
                        document: gql(getCategoriesQuery),
                        variables: const {'offset': 0, 'limit': 100},
                        fetchPolicy: FetchPolicy.networkOnly,
                      ),
                      builder: (categoriesResult, {fetchMore, refetch}) {
                        final categoriesResponse =
                            categoriesResult.data?['categories']
                                as Map<String, dynamic>?;
                        final rawCategories =
                            (categoriesResponse?['items'] as List?) ?? [];
                        final categories = rawCategories
                            .map(
                              (item) => Categories.fromJson(
                                item as Map<String, dynamic>,
                              ),
                            )
                            .where((category) => category.isActive)
                            .toList();

                        return SizedBox(
                          height: 52,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: const Text('Todas'),
                                  selected: _selectedCategoryIds.isEmpty,
                                  onSelected: (_) {
                                    setState(() {
                                      _offset = 0;
                                      _selectedCategoryIds.clear();
                                    });
                                  },
                                ),
                              ),
                              ...categories.map((category) {
                                final catId = category.id.toString();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(category.name),
                                    selected: _selectedCategoryIds.contains(
                                      catId,
                                    ),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _offset = 0;
                                        if (selected) {
                                          _selectedCategoryIds.add(catId);
                                        } else {
                                          _selectedCategoryIds.remove(catId);
                                        }
                                      });
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 4. Lista de Tareas o Mensaje de Vacío
                  if (tasks.isEmpty &&
                      !result.isLoading &&
                      _selectedCategoryIds.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 40, 16, 12),
                        child: Center(child: Text('No hay resultados')),
                      ),
                    )
                  else
                    SliverList.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          index: _offset + index,
                          onDelete: () => TaskFunctions.deleteTask(
                            context,
                            task.id,
                            refetch,
                          ),
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

                  // 5. Paginación
                  if (tasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: hasPreviousPage
                                  ? () => setState(() => _offset -= _limit)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Text('$currentPage / $totalPages'),
                            const SizedBox(width: 16),
                            IconButton.outlined(
                              icon: const Icon(Icons.chevron_right),
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
                  onPressed: () =>
                      TaskFunctions.showInfoDialog(context, pageInfo),
                ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              AppGradientBackground(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    listContent,
                    if (_isEasterEggOpen)
                      Center(
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
                  ],
                ),
              ),
              if (result.isLoading)
                const ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
