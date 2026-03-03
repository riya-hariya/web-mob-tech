import 'package:dio/dio.dart';
import 'package:web_mob_interview_task/model/post_response.dart';
import 'package:web_mob_interview_task/model/product_response.dart';
import 'package:web_mob_interview_task/repo/performance_interceptor.dart';

class FeedRepository {
  final Dio _dio = Dio();
  final Map<String, Future> _ongoingRequests = {};


   FeedRepository() {
    _dio.interceptors.add(PerformanceInterceptor());
  }

  Future<T> _deduplicate<T>(String key, Future<T> Function() request) {
    if (_ongoingRequests.containsKey(key)) {
      return _ongoingRequests[key] as Future<T>;
    }

    final future = request();
    _ongoingRequests[key] = future;

    future.whenComplete(() {
      _ongoingRequests.remove(key);
    });

    return future;
  }

  //----------------------------fetch products--------------------//
  Future<List<Product>> fetchProducts({
    required int page,
    CancelToken? cancelToken,
  }) async {
    final key = "products_page_$page";

    return _deduplicate(key, () async {
      final skip = page * 10;

      final response = await _dio.get(
        'https://dummyjson.com/products',
        cancelToken: cancelToken,
        queryParameters: {'limit': 10, 'skip': skip},
      );

      return ProductResponse.fromJson(response.data).products;
    });
  }

  //------------------------------fetch posts-------------------//
  Future<List<Post>> fetchPosts({
  required int page,
  CancelToken? cancelToken,
}) {
  final key = "posts_page_$page";

  return _deduplicate(key, () async {
    final skip = page * 10;

    final response = await _dio.get(
      'https://dummyjson.com/posts',
      cancelToken: cancelToken,
      queryParameters: {
        'limit': 10,
        'skip': skip,
      },
    );

    return PostResponse.fromJson(response.data).posts;
  });
}

  //--------------------------------------------search products-----------//
  Future<List<Product>> searchProducts({
  required String query,
  required int page,
  CancelToken? cancelToken,
}) {
  final key = "search_products_${query}_page_$page";

  return _deduplicate(key, () async {
    final skip = page * 10;

    final response = await _dio.get(
      'https://dummyjson.com/products/search',
      cancelToken: cancelToken,
      queryParameters: {
        'q': query,
        'limit': 10,
        'skip': skip,
      },
    );

    return ProductResponse.fromJson(response.data).products;
  });
}

  //------------------------search posts----------------//
  Future<List<Post>> searchPosts({
  required String query,
  required int page,
  CancelToken? cancelToken,
}) {
  final key = "search_posts_${query}_page_$page";

  return _deduplicate(key, () async {
    final skip = page * 10;

    final response = await _dio.get(
      'https://dummyjson.com/posts/search',
      cancelToken: cancelToken,
      queryParameters: {
        'q': query,
        'limit': 10,
        'skip': skip,
      },
    );

    return PostResponse.fromJson(response.data).posts;
  });
}
}
