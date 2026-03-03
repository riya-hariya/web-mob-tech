class PostResponse {
  final List<Post> posts;
  final int total;
  final int skip;
  final int limit;

  PostResponse({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      posts: (json['posts'] as List)
          .map((e) => Post.fromJson(e))
          .toList(),
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}

class Post {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final Reactions? reactions; // Made final since it's a data model
  final int views;
  final int userId;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    this.reactions,
    required this.views,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      // Safely handle list conversion
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      // FIX: Use 'key: value,' syntax, not assignment '='
      reactions: json['reactions'] != null
          ? Reactions.fromJson(json['reactions'])
          : null,
      views: json['views'] ?? 0,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        // FIX: Use Collection If syntax: if (condition) key: value
        if (reactions != null) 'reactions': reactions!.toJson(),
        'views': views,
        'userId': userId,
      };
}

class Reactions {
  final int? likes;
  final int? dislikes;

  Reactions({this.likes, this.dislikes});

  // Changed to a factory for consistency, but your named constructor was okay too
  factory Reactions.fromJson(Map<String, dynamic> json) {
    return Reactions(
      likes: json['likes'],
      dislikes: json['dislikes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'likes': likes,
        'dislikes': dislikes,
      };
}