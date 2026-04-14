import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
import 'package:flutter_application_1/features/categories/presentation/create_category_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  Future<void> _openCreateCategoryPage(
    BuildContext context,
    VoidCallback? refetch,
  ) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateCategoryPage()));
    if (created == true) refetch?.call();
  }

  void _showInfoDialog(BuildContext context, Map<String, dynamic> pageInfo) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Page info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Total categories', '${pageInfo['totalCount']}'),
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

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getCategoriesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {fetchMore, refetch}) {
        final categoriesResponse =
            result.data?['categories'] as Map<String, dynamic>?;
        final rawCategories = (categoriesResponse?['items'] as List?) ?? [];
        final pageInfo =
            categoriesResponse?['pageInfo'] as Map<String, dynamic>?;
        final categories = rawCategories
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
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
                      'Error loading categories:\n${result.exception}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No categories yet'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            _openCreateCategoryPage(context, refetch),
                        icon: const Icon(Icons.add),
                        label: const Text('Create a new category'),
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
                        onPressed: () =>
                            _openCreateCategoryPage(context, refetch),
                        icon: const Icon(Icons.add),
                        label: const Text('Create a new category'),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 16),
                    sliver: SliverList.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        return _CategoryCard(category: categories[index]);
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

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

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
                  Icons.circle,
                  size: 10,
                  color: category.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Text('ID: ${category.id}'),
            Text('Active: ${category.isActive}'),
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
