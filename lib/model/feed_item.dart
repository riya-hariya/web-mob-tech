import 'package:web_mob_interview_task/model/post_response.dart';
import 'package:web_mob_interview_task/model/product_response.dart';

sealed class FeedItem {
  const FeedItem();
}

class ProductItem extends FeedItem {
  final Product product;
  const ProductItem(this.product);
}

class PostItem extends FeedItem {
  final Post post;
  const PostItem(this.post);
}