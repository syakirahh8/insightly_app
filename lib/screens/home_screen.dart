import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insightly_app/controllers/news_controller.dart';
import 'package:insightly_app/routes/app_pages.dart';
import 'package:insightly_app/screens/favorite_news_screen.dart';
import 'package:insightly_app/utils/app_colors.dart';
import 'package:insightly_app/widgets/category_chip.dart';
import 'package:insightly_app/widgets/loading_shimmer.dart';
import 'package:insightly_app/widgets/news_card.dart';

class HomeScreen extends GetView<NewsController> {
  final RxInt _navIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isHome = _navIndex.value == 0;

      return Scaffold(
        backgroundColor: AppColors.background,

        // appBar hanya muncul di halaman Home
        appBar: isHome
            ? PreferredSize(
                preferredSize: Size.fromHeight(88),
                child: Container(
                  color: AppColors.background,
                  padding: EdgeInsets.all(16),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hello!',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                letterSpacing: 0.2,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "Today's ",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  'Insight',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => showSearchDialog(context),
                          icon: Icon(Icons.search, size: 22),
                          color: AppColors.textPrimary,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          splashRadius: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,

        // body
        body: IndexedStack(
          index: _navIndex.value,
          children: [
            // tab home = 0
            Column(
              children: [
                Container(
                  height: 60,
                  color: AppColors.background,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      return Obx(
                        () => CategoryChip(
                          label: category.capitalize ?? category,
                          isSelected: controller.selectedCategory == category,
                          onTap: () => controller.selectCategory(category),
                        ),
                      );
                    },
                  ),
                ),

                // news list
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading) return LoadingShimmer();
                    if (controller.error.isNotEmpty) return _buildErrorWidget();
                    if (controller.articles.isEmpty) return _buildEmptyWidget();

                    return RefreshIndicator(
                      onRefresh: controller.refreshNews,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: controller.articles.length,
                        itemBuilder: (context, index) {
                          final article = controller.articles[index];
                          return NewsCard(
                            article: article,
                            onTap: () => Get.toNamed(
                              Routes.NEWS_DETAIL,
                              arguments: article,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
            FavoriteNewsScreen(),
          ],
        ),

        // === BOTTOM NAVIGATION ===
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF151515),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 12,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BottomNavigationBar(
                currentIndex: _navIndex.value,
                onTap: (i) => _navIndex.value = i,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.white70,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_rounded),
                    label: 'Favorites',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyWidget() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/internet-mascot.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text(
              'Oops... no news found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try refreshing the page',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              titlePadding: EdgeInsets.all(20),
              contentPadding: EdgeInsets.all(10),
              actionsPadding: EdgeInsets.all(15),

              // Header
              title: Row(
                children: [
                  Text(
                    'Search News',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // Input
              content: TextField(
                controller: searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type keywords…',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  isDense: true,
                  filled: true,
                  fillColor: Color(0xFF151515),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  suffixIcon: (searchController.text.isNotEmpty)
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white54,
                          ),
                          splashRadius: 18,
                          tooltip: 'Clear',
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    controller.searchNews(value);
                    Navigator.of(context).pop();
                  }
                },
              ),

              // Actions
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      controller.searchNews(searchController.text);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
