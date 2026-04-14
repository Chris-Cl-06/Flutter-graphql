import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/data/graphql/mutations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
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
        document: gql(createCategoryMutation),
        variables: {
          'input': {'name': _nameController.text.trim()},
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating category: ${result.exception}')),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Category'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
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
                    : const Text('Create category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
