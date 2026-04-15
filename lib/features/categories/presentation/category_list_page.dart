import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/app_gradient_background.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
import 'package:flutter_application_1/features/categories/functions_categories.dart';
import 'package:flutter_application_1/features/categories/presentation/widgets/category_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  static const int _limit = 8;
  int _offset = 0;

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
                  onPressed: () =>
                      CategoryFunctions.showInfoDialog(context, pageInfo),
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
                              CategoryFunctions.openCreateCategoryPage(
                                context,
                                refetch,
                              ),
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
                                CategoryFunctions.openCreateCategoryPage(
                                  context,
                                  refetch,
                                ),
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
                          return CategoryCard(
                            category: category,
                            index: _offset + index,
                            onDelete: () => CategoryFunctions.deleteCategory(
                              context,
                              category.id,
                              refetch,
                            ),
                            onToggle: () => CategoryFunctions.toggleCategory(
                              context,
                              category.id,
                              category.isActive,
                              refetch,
                            ),
                            onSaveName: (newName) =>
                                CategoryFunctions.updateCategoryName(
                                  context,
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
