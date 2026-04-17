class Task {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final String? categoryId;
  final String? categoryName;
  final bool? categoryActive;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    this.categoryId,
    this.categoryName,
    this.categoryActive,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return Task(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      categoryId: json['categoryId'] as String?,
      categoryName: category?['name'] as String?,
      categoryActive: category?['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryActive': categoryActive,
    };
  }
}
