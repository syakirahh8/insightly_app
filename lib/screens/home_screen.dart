// A brand new way for make a screen using get state management

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insightly_app/controllers/news_controller.dart';
import 'package:insightly_app/routes/app_pages.dart';
import 'package:insightly_app/utils/app_colors.dart';
import 'package:insightly_app/widgets/category_chip.dart';
import 'package:insightly_app/widgets/loading_shimmer.dart';
import 'package:insightly_app/widgets/news_card.dart';

class HomeScreen extends GetView<NewsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(88),
        child: Container(
          color: AppColors.background,
          padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
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
                            fontFamily: 'Manrope',
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
                            fontFamily: 'Manrope',
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
      ),

      body: Column(
        children: [
          // categories
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
              if (controller.isLoading) {
                return LoadingShimmer();
              }
              if (controller.error.isNotEmpty) {
                return _buildErrorWidget();
              }

              if (controller.articles.isEmpty) {
                return _buildEmptyWidget();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshNews,
                child: Container(
                  color: AppColors.background,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: controller.articles.length,
                    itemBuilder: (context, index) {
                      final article = controller.articles[index];
                      return NewsCard(
                        article: article,
                        onTap: () =>
                            Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Search News',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: searchController,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Please type a news...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.textSecondary),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              controller.searchNews(value);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                controller.searchNews(searchController.text);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
}
