import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/app_gradient_background.dart';
import 'package:flutter_application_1/features/categories/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
import 'package:flutter_application_1/features/categories/presentation/create_category_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  static const int _limit = 8;
  int _offset = 0;

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
  Future<void> _deleteCategory(
    String id,
    bool isActive,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(deleteCategoryMutation),
        variables: {'id': id, 'isActive': !isActive},
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

    refetch?.call();
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
                            onDelete: () => _deleteCategory(
                              category.id,
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

class _CategoryCard extends StatelessWidget {
  final Categories category;
  final int index;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onDelete,
  });

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
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? const Color(0xFF10B981)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Indice #${index + 1}')),
                Chip(label: Text('ID ${category.id}')),
                Chip(label: Text(category.isActive ? 'Activa' : 'Inactiva')),
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
