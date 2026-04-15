import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/categories/presentation/create_category_page.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CategoryFunctions {
  static Future<void> openCreateCategoryPage(
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

  static Future<void> deleteCategory(
    BuildContext context,
    String id,
    VoidCallback? refetch,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(deleteCategoryMutation),
        variables: {'id': id},
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: ${result.exception}')),
      );
      return;
    }

    if (kDebugMode) {
      print(result.data);
    }

    await _refetchTasksAfterCategoryDelete(context);
    refetch?.call();
  }

  static Future<void> toggleCategory(
    BuildContext context,
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

    if (!context.mounted) {
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

    if (kDebugMode) {
      print(result.data);
    }

    refetch?.call();
  }

  static Future<bool> updateCategoryName(
    BuildContext context,
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

    if (!context.mounted) {
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

  static void showInfoDialog(
    BuildContext context,
    Map<String, dynamic> pageInfo,
  ) {
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

  static Future<void> _refetchTasksAfterCategoryDelete(
    BuildContext context,
  ) async {
    final client = GraphQLProvider.of(context).value;
    await client.query(
      QueryOptions(
        document: gql(getTasksQuery),
        variables: {'offset': 0, 'limit': 5},
        fetchPolicy: FetchPolicy.networkOnly,
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
