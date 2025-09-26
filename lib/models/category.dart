class Category {
  final String id;
  final String name;
  final String icon;
  final String description;
  final bool isPrimary;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.isPrimary = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'isPrimary': isPrimary,
    };
  }
}