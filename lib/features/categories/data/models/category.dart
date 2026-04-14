class Category {
  final String id;
  final String name;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
