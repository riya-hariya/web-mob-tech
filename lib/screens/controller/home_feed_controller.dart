import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_mob_interview_task/model/feed_item.dart';
import 'package:web_mob_interview_task/model/post_response.dart';
import 'package:web_mob_interview_task/model/product_response.dart';
import 'package:web_mob_interview_task/repo/feed_repo.dart';

class HomeFeedController extends GetxController {
  final feed = <FeedItem>[].obs;

  final _products = <Product>[].obs;
  final _posts = <Post>[].obs;

  int productPage = 0;
  int postPage = 0;

  bool hasMoreProducts = true;
  bool hasMorePosts = true;
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  Timer? _searchDebounce;

  List<Product> _searchProducts = [];
  List<Post> _searchPosts = [];
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final showOfflineBanner = false.obs;
  final errorMessage = RxnString();
  final isFromCache = false.obs;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  final FeedRepository repository = FeedRepository();
  final _storage = GetStorage();
  int _requestVersion = 0;
  bool _paginationLock = false;
  static const _cacheKey = 'home_feed_cache';
  static const _cacheTimeKey = 'home_feed_cache_time';
  static const _cacheExpiryMinutes = 5;
  int get visibleProductCount => feed.whereType<ProductItem>().length;

  int get visiblePostCount => feed.whereType<PostItem>().length;
  CancelToken? _productCancelToken;
  CancelToken? _postCancelToken;
//----------------------init-------------------//
  @override
  void onInit() {
    super.onInit();

    loadCachedFeed(); // load instantly

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);

      showOfflineBanner.value = !hasConnection;

      if (hasConnection &&
          !isLoading.value &&
          !isPaginating.value &&
          !isSearching.value) {
        silentRefresh();
      }
    });

    loadInitialFeed(); // network load
  }
//--------------------onClose--------------------//
  @override
  void onClose() {
    _connectivitySub.cancel();
    super.onClose();
  }
//---------------------------------Silent refresh---------------//
  Future<void> silentRefresh() async {
    try {
      productPage = 0;
      postPage = 0;

      final productsFuture = repository.fetchProducts(page: 0);
      final postsFuture = repository.fetchPosts(page: 0);

      final products = await productsFuture;
      final posts = await postsFuture;

      _products.assignAll(products);
      _posts.assignAll(posts);

      feed.assignAll(_mergeAlternating());
    } catch (_) {}
  }
//-----------------------------load initial feed---------------//
  Future<void> loadInitialFeed() async {
    if (isLoading.value) return;

    final currentVersion = ++_requestVersion; // cancel previous

    isLoading.value = true;
    errorMessage.value = null;

    try {
      productPage = 0;
      postPage = 0;
      hasMoreProducts = true;
      hasMorePosts = true;

      final products = await repository.fetchProducts(page: productPage);

      final posts = await repository.fetchPosts(page: postPage);

      // 🚨 If a newer request started, ignore this result
      if (currentVersion != _requestVersion) return;

      _products.assignAll(products);
      _posts.assignAll(posts);

      feed.assignAll(_mergeAlternating());

      isFromCache.value = false;
      await cacheFeed(feed);
    } catch (e) {
      if (currentVersion == _requestVersion) {
        errorMessage.value = "Failed to load feed";
      }
    } finally {
      if (currentVersion == _requestVersion) {
        isLoading.value = false;
      }
    }
  }
//------------------------cache feed----------------------//
  Future<void> cacheFeed(List<FeedItem> items) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final jsonList = items.map((item) {
      if (item is ProductItem) {
        return {'type': 'product', 'data': item.product.toJson()};
      } else if (item is PostItem) {
        return {'type': 'post', 'data': item.post.toJson()};
      }
    }).toList();

    await _storage.write(_cacheKey, jsonList);
    await _storage.write(_cacheTimeKey, now);
  }
//--------------------load cached feed----------------------//
  Future<void> loadCachedFeed() async {
    final cached = _storage.read(_cacheKey);
    final timestamp = _storage.read(_cacheTimeKey);

    if (cached == null || timestamp == null) return;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

    final isExpired =
        cacheAge > Duration(minutes: _cacheExpiryMinutes).inMilliseconds;

    if (isExpired) return;

    final items = (cached as List).map<FeedItem>((item) {
      if (item['type'] == 'product') {
        return ProductItem(Product.fromJson(item['data']));
      } else {
        return PostItem(Post.fromJson(item['data']));
      }
    }).toList();

    feed.assignAll(items);
    isFromCache.value = true; // 🔥 important
  }
//-----------------------------load more------------------//
  Future<void> loadMore() async {
    if (_paginationLock) return;
    if (isLoading.value) return;
    if (!hasMoreProducts && !hasMorePosts) return;

    _paginationLock = true;
    isPaginating.value = true;

    final currentVersion = _requestVersion;

    try {
      final productCount = visibleProductCount;
      final postCount = visiblePostCount;

      /// 🔥 SEARCH MODE PAGINATION
      if (isSearching.value) {
        if (productCount <= postCount && hasMoreProducts) {
          productPage++;

          final newProducts = await repository.searchProducts(
            query: searchQuery.value,
            page: productPage,
          );

          if (currentVersion != _requestVersion) return;

          if (newProducts.isEmpty) {
            hasMoreProducts = false;
          } else {
            _searchProducts.addAll(newProducts);
          }
        } else if (hasMorePosts) {
          postPage++;

          final newPosts = await repository.searchPosts(
            query: searchQuery.value,
            page: postPage,
          );

          if (currentVersion != _requestVersion) return;

          if (newPosts.isEmpty) {
            hasMorePosts = false;
          } else {
            _searchPosts.addAll(newPosts);
          }
        }

        if (currentVersion == _requestVersion) {
          feed.assignAll(_mergeSearchResults());
        }
      }
      /// 🔥 NORMAL MODE PAGINATION
      else {
        if (productCount <= postCount && hasMoreProducts) {
          productPage++;
          final newProducts = await repository.fetchProducts(page: productPage);

          if (currentVersion != _requestVersion) return;

          if (newProducts.isEmpty) {
            hasMoreProducts = false;
          } else {
            _products.addAll(newProducts);
          }
        } else if (hasMorePosts) {
          postPage++;
          final newPosts = await repository.fetchPosts(page: postPage);

          if (currentVersion != _requestVersion) return;

          if (newPosts.isEmpty) {
            hasMorePosts = false;
          } else {
            _posts.addAll(newPosts);
          }
        }

        if (currentVersion == _requestVersion) {
          feed.assignAll(_mergeAlternating());
          await cacheFeed(feed);
        }
      }
    } finally {
      _paginationLock = false;
      isPaginating.value = false;
    }
  }
//-------------------------------merge alternating-------------//
  List<FeedItem> _mergeAlternating() {
    final merged = <FeedItem>[];

    int maxLength = max(_products.length, _posts.length);

    for (int i = 0; i < maxLength; i++) {
      if (i < _products.length) {
        merged.add(ProductItem(_products[i]));
      }
      if (i < _posts.length) {
        merged.add(PostItem(_posts[i]));
      }
    }

    return merged;
  }
//----------------------on search changed-----------------------//
  void onSearchChanged(String query) {
    searchQuery.value = query;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        _exitSearchMode();
      } else {
        _enterSearchMode(query.trim());
      }
    });
  }

//------------------------enter search mode------------------------//
  Future<void> _enterSearchMode(String query) async {
    _productCancelToken?.cancel();
    _postCancelToken?.cancel();

    _productCancelToken = CancelToken();
    _postCancelToken = CancelToken();
    final currentVersion = ++_requestVersion;

    isSearching.value = true;
    isLoading.value = true;

    try {
      productPage = 0;
      postPage = 0;
      hasMoreProducts = true;
      hasMorePosts = true;

      final productsFuture = repository.searchProducts(query: query, page: 0,cancelToken: _productCancelToken,);

      final postsFuture = repository.searchPosts(query: query, page: 0,cancelToken: _postCancelToken,);

      final products = await productsFuture;
      final posts = await postsFuture;

      if (currentVersion != _requestVersion) return;

      _searchProducts = products;
      _searchPosts = posts;

      feed.assignAll(_mergeSearchResults());
    }on DioException catch (e) {
       if (CancelToken.isCancel(e)) return;
      if (currentVersion == _requestVersion) {
        errorMessage.value = "Search failed";
      }
    } finally {
      if (currentVersion == _requestVersion) {
        isLoading.value = false;
      }
    }
  }
//------------------------------------exit search mode----------------//
  void _exitSearchMode() {
    isSearching.value = false;
    searchQuery.value = '';

    _searchProducts.clear();
    _searchPosts.clear();

    loadInitialFeed(); // restore normal feed
  }

  List<FeedItem> _mergeSearchResults() {
    final merged = <FeedItem>[];
    final maxLength = max(_searchProducts.length, _searchPosts.length);

    for (int i = 0; i < maxLength; i++) {
      if (i < _searchProducts.length) {
        merged.add(ProductItem(_searchProducts[i]));
      }
      if (i < _searchPosts.length) {
        merged.add(PostItem(_searchPosts[i]));
      }
    }

    return merged;
  }
}
