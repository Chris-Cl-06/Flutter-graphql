import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/tasks/data/models/task.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';
import 'package:flutter_application_1/features/tasks/data/graphql/mutations.dart';
import 'package:flutter_application_1/features/categories/data/graphql/queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  bool _completed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _selectedCategoryId = widget.task.categoryId;
    _completed = widget.task.completed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateTaskMutation),
        variables: {
          'id': widget.task.id,
          'input': {
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            'completed': _completed,
            'categoryId': _selectedCategoryId,
          },
        },
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: [31m${result.exception}[0m'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    //final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Tarea')),
      body: Query(
        options: QueryOptions(document: gql(getCategoriesQuery)),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasException) {
            return Center(child: Text('Error cargando categorías'));
          }
          final List categories = result.data?['categories']?['items'] ?? [];
          final List<Categories> categoryList = categories
              .map((c) => Categories.fromJson(c))
              .where((c) => c.isActive)
              .toList();
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Ponle título jefe'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('Sin categoria'),
                      ),
                      ...categoryList.map(
                        (category) => DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
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
                  const SizedBox(height: 18),
                  SwitchListTile(
                    title: const Text('Completada'),
                    value: _completed,
                    onChanged: (v) => setState(() => _completed = v),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text('Guardar cambios'),
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
