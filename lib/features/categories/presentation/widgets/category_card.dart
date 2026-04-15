import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/data/models/category.dart';

class CategoryCard extends StatefulWidget {
  final Categories category;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final Future<bool> Function(String newName) onSaveName;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.onDelete,
    required this.onToggle,
    required this.onSaveName,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late final TextEditingController _nameController;
  bool _isEditingName = false;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void didUpdateWidget(covariant CategoryCard oldWidget) {
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
