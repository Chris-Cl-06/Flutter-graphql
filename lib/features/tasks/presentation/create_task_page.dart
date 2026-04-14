import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/mutations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) {
      return;
    }

    setState(() => _saving = true);
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(createTaskMutation),
        variables: {
          'input': {
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            'categoryId': _selectedCategoryId,
          },
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating task: ${result.exception}')),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task'), centerTitle: true),
      body: Query(
        options: QueryOptions(
          document: gql(getCategoriesQuery),
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
                  'Error loading categories:\n${result.exception}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final categoriesResponse =
              result.data?['categories'] as Map<String, dynamic>?;
          final rawCategories = (categoriesResponse?['items'] as List?) ?? [];
          final categories = rawCategories
              .map((item) => Category.fromJson(item as Map<String, dynamic>))
              .where((category) => category.isActive)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('No category'),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem<String>(
                          value: category.id,
                          child: Text('${category.name} (${category.id})'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value == null || value.isEmpty
                            ? null
                            : value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create task'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
