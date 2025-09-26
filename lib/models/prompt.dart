class Prompt {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String content;
  final bool isPremium;
  final String difficulty;
  final String estimatedTime;
  final List<String> tags;
  bool isFavorite;
  bool isUnlocked;

  Prompt({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.content,
    required this.isPremium,
    required this.difficulty,
    required this.estimatedTime,
    required this.tags,
    this.isFavorite = false,
    this.isUnlocked = false,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      isPremium: json['isPremium'],
      difficulty: json['difficulty'],
      estimatedTime: json['estimatedTime'],
      tags: List<String>.from(json['tags']),
      isFavorite: json['isFavorite'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'content': content,
      'isPremium': isPremium,
      'difficulty': difficulty,
      'estimatedTime': estimatedTime,
      'tags': tags,
      'isFavorite': isFavorite,
      'isUnlocked': isUnlocked,
    };
  }

  Prompt copyWith({
    bool? isFavorite,
    bool? isUnlocked,
  }) {
    return Prompt(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      content: content,
      isPremium: isPremium,
      difficulty: difficulty,
      estimatedTime: estimatedTime,
      tags: tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}