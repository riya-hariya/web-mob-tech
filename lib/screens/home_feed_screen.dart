import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_mob_interview_task/model/feed_item.dart';
import 'package:web_mob_interview_task/screens/controller/home_feed_controller.dart';
import 'package:web_mob_interview_task/screens/widgets/post_card.dart';
import 'package:web_mob_interview_task/screens/widgets/product_card.dart';

class HomeFeedScreen extends StatefulWidget {
  HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HomeFeedController controller = Get.put(HomeFeedController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {
      if (!controller.isPaginating.value &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Deep dark background
      body: SafeArea(
        child: Obx(() {
          /// 1️⃣ Full Screen Loading
          if (controller.isLoading.value && controller.feed.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 2️⃣ Error State
          if (controller.errorMessage.value != null &&
              controller.feed.isEmpty) {
            return _buildErrorState();
          }

          /// 3️⃣ Unified Feed
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              _buildTopAppBar(),

              /// Cache Indicator
              if (controller.isFromCache.value) _buildCacheIndicator(),

              Obx(
                () => controller.showOfflineBanner.value
                    ? _buildOfflineBanner()
                    : const SliverToBoxAdapter(child: SizedBox()),
              ),

              _buildFeedList(),

              /// Bottom Pagination Loader
              if (controller.isPaginating.value)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: Colors.white,)),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),

                    /// 🔥 SEARCH FIELD WITH CONTROLLER
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: controller.onSearchChanged,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "Search Vibes, People, Products...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),

                    /// ❌ CLEAR BUTTON
                    Obx(
                      () => controller.searchQuery.value.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear(); // 🔥 clears UI
                                controller.onSearchChanged('');
                                FocusScope.of(context).unfocus();
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 18,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            Badge(
              backgroundColor: Colors.blue,
              label: const Text('3'),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),

            const SizedBox(width: 12),
            const Icon(Icons.person_outline, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Offline Data",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Viewing Offline Data (Content may not be current)",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList() {
    return Obx(
      () => SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = controller.feed[index];

          if (item is ProductItem) {
            return ProductCard(product: item.product);
          } else if (item is PostItem) {
            return PostCard(post: item.post);
          }
          return const SizedBox();
        }, childCount: controller.feed.length),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 50),
          const SizedBox(height: 12),
          const Text(
            "Something went wrong",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.loadInitialFeed,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Colors.orange, size: 16),
            SizedBox(width: 6),
            Text(
              "Showing cached data",
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
