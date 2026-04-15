class Categories {
  final String id;
  final String name;
  final bool isActive;

  const Categories({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
