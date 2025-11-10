//      "id": 1,
//         "url": "https://cataas.com/cat?unique=0&width=80&height=80",
//         "label": "Cat 0",
//         "category": "cat"

import 'package:chat_app/features/conversation/domain/entities/avatar.dart';

class AvatarModel {
  final int id;
  final String url;
  final String label;
  final String category;

  AvatarModel({
    required this.id,
    required this.url,
    required this.label,
    required this.category,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'],
      url: json['url'],
      label: json['label'],
      category: json['category'] ?? 'default', // Default category if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'label': label,
      'category': category,
    };
  }

  Avatar toEntity() {
    return Avatar(
      id: id,
      url: url,
      label: label,
      category: category,
    );
  }
}