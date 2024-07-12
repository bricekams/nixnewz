import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/models/article.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 3)
class Bookmark {
  @HiveField(0)
  String id;
  @HiveField(1)
  Article article;
  @HiveField(2)
  DateTime? createdAt;

  Bookmark({required this.id, required this.article, this.createdAt});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      article: Article.fromJson(json['article']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['article'] = article.toJson();
    data['owner'] = supabase.auth.currentUser?.id??"";
    return data;
  }

  static String generateId(Article article) {
    return (article.url ?? article.publishedAt ?? "") +
        (supabase.auth.currentUser?.id??"");
  }
}
