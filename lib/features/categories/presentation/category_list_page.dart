import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/app_gradient_background.dart';
import 'package:flutter_application_1/features/categories/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
import 'package:flutter_application_1/features/categories/presentation/create_category_page.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  static const int _limit = 8;
  int _offset = 0;

  Future<void> _refetchTasksAfterCategoryDelete() async {
    final client = GraphQLProvider.of(context).value;
    await client.query(
      QueryOptions(
        document: gql(getTasksQuery),
        variables: {'offset': 0, 'limit': 5},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
  }

  Future<void> _openCreateCategoryPage(
    BuildContext context,
    VoidCallback? refetch,
  ) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateCategoryPage()));
    if (created == true) {
      refetch?.call();
    }
  }

  //metodo para eliminar , se llama al apretar el icono de basura
  Future<void> _deleteCategory(String id, VoidCallback? refetch) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(deleteCategoryMutation),
        variables: {'id': id},
      ),
    );

    if (!mounted) {
      return;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: ${result.exception}')),
      );
      return;
    }

    print(result.data);

    await _refetchTasksAfterCategoryDelete();

    refetch?.call();
  }

  Future<void> _toggleCategory(
    String id,
    bool isActive,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateCategoryMutation),
        variables: {'id': id, 'name': null, 'isActive': !isActive},
      ),
    );

    if (!mounted) {
      return;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating category state: ${result.exception}'),
        ),
      );
      return;
    }

    print(result.data);

    refetch?.call();
  }

  Future<bool> _updateCategoryName(
    String id,
    String name,
    bool isActive,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateCategoryMutation),
        variables: {'id': id, 'name': name, 'isActive': isActive},
      ),
    );

    if (!mounted) {
      return false;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating category name: ${result.exception}'),
        ),
      );
      return false;
    }

    refetch?.call();
    return true;
  }

  void _showInfoDialog(BuildContext context, Map<String, dynamic> pageInfo) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info de pagina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Total categorias', '${pageInfo['totalCount']}'),
            _InfoRow('Offset', '${pageInfo['offset'] ?? 0}'),
            _InfoRow('Limit', '${pageInfo['limit'] ?? '-'}'),
            _InfoRow(
              'Tiene siguiente pagina',
              '${pageInfo['hasNextPage'] ?? false}',
            ),
            _InfoRow(
              'Tiene pagina anterior',
              '${pageInfo['hasPreviousPage'] ?? false}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getCategoriesQuery),
        variables: {'offset': _offset, 'limit': _limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {fetchMore, refetch}) {
        final categoriesResponse =
            result.data?['categories'] as Map<String, dynamic>?;
        final rawCategories = (categoriesResponse?['items'] as List?) ?? [];
        final pageInfo =
            categoriesResponse?['pageInfo'] as Map<String, dynamic>?;
        final totalCount = (pageInfo?['totalCount'] as num?)?.toInt() ?? 0;
        final hasNextPage = (pageInfo?['hasNextPage'] as bool?) ?? false;
        final hasPreviousPage =
            (pageInfo?['hasPreviousPage'] as bool?) ?? false;
        final totalPages = ((totalCount + _limit - 1) ~/ _limit).clamp(
          1,
          999999,
        );
        final currentPage = (_offset ~/ _limit) + 1;

        final categories = rawCategories
            .map((item) => Categories.fromJson(item as Map<String, dynamic>))
            .toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Categorias'),
            centerTitle: true,
            actions: [
              if (pageInfo != null)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info de pagina',
                  onPressed: () => _showInfoDialog(context, pageInfo),
                ),
            ],
          ),
          body: AppGradientBackground(
            child: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Todavia no hay categorias'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              _openCreateCategoryPage(context, refetch),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear nueva categoria'),
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
                                _openCreateCategoryPage(context, refetch),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear nueva categoria'),
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
                                  Icons.auto_awesome_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Mostrando ${categories.length} de $totalCount categorias',
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
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _CategoryCard(
                            category: category,
                            index: _offset + index,
                            onDelete: () =>
                                _deleteCategory(category.id, refetch),
                            onToggle: () => _toggleCategory(
                              category.id,
                              category.isActive,
                              refetch,
                            ),
                            onSaveName: (newName) => _updateCategoryName(
                              category.id,
                              newName,
                              category.isActive,
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

class _CategoryCard extends StatefulWidget {
  final Categories category;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final Future<bool> Function(String newName) onSaveName;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onDelete,
    required this.onToggle,
    required this.onSaveName,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  late final TextEditingController _nameController;
  bool _isEditingName = false;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void didUpdateWidget(covariant _CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nameChanged = oldWidget.category.name != widget.category.name;
    final categoryChanged = oldWidget.category.id != widget.category.id;
    if ((nameChanged || categoryChanged) && !_isEditingName) {
      _nameController.text = widget.category.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEditOrSave() async {
    if (_isSavingName) {
      return;
    }

    if (!_isEditingName) {
      setState(() {
        _isEditingName = true;
      });
      return;
    }

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacio')),
      );
      return;
    }

    if (newName == widget.category.name) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    setState(() {
      _isSavingName = true;
    });

    final saved = await widget.onSaveName(newName);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSavingName = false;
      if (saved) {
        _isEditingName = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.onToggle,
                  icon: Icon(
                    widget.category.isActive
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.category.isActive
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _isEditingName
                      ? TextField(
                          controller: _nameController,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleEditOrSave(),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Nuevo nombre',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          widget.category.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
                IconButton(
                  icon: _isSavingName
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isEditingName
                              ? Icons.check_circle_outline
                              : Icons.edit_outlined,
                        ),
                  tooltip: _isEditingName ? 'Guardar nombre' : 'Editar nombre',
                  onPressed: _handleEditOrSave,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const Divider(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Indice #${widget.index + 1}')),
                //Chip(label: Text('ID ${widget.category.id}')),
                Chip(
                  label: Text(widget.category.isActive ? 'Activa' : 'Inactiva'),
                ),
              ],
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
