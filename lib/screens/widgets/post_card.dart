import 'package:flutter/material.dart';
import 'package:web_mob_interview_task/model/post_response.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Mocked user data based on userId (since API doesn’t provide user info)
    final userName = "User ${post.userId}";
    final userHandle = "@user${post.userId}";
    final profileImage =
        "https://i.pravatar.cc/150?img=${post.userId % 70}";
    final postImage =
        "https://picsum.photos/seed/${post.id}/800/500";

    final likes = post.reactions?.likes ?? 0;
    final dislikes = post.reactions?.dislikes ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profileImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$userHandle • ${post.views} views",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 12),

          /// TITLE
          Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          /// BODY
          Text(
            post.body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          /// TAGS
          if (post.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              children: post.tags
                  .map(
                    (tag) => Text(
                      "#$tag",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 12),

          /// IMAGE (mocked)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              postImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(height: 200),
            ),
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            children: [
              const Icon(Icons.favorite_border,
                  color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(
                _formatCount(likes),
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(width: 20),

              const Icon(Icons.thumb_down_alt_outlined,
                  color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(
                _formatCount(dislikes),
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12),
              ),

              const Spacer(),

              const Icon(Icons.share_outlined,
                  color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    return value.toString();
  }
}