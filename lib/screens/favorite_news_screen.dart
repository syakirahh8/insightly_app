import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insightly_app/controllers/news_controller.dart';
import 'package:insightly_app/models/news_articles.dart';
import 'package:insightly_app/routes/app_pages.dart';
import 'package:insightly_app/utils/app_colors.dart';

class FavoriteNewsScreen extends GetView<NewsController> {
  const FavoriteNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Obx(() {
        // kalau kosong
        if (controller.favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/cry_love.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Favorites Yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // list buat favorite
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: controller.favorites.length,
          separatorBuilder: (_, __) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final NewsArticles article = controller.favorites[index];
            final imageUrl = article.urlToImage ?? '';
            final title = article.title ?? 'Untitled';
            final source = article.source?.name ?? 'Unknown';
            final date = (article.publishedAt?.isNotEmpty ?? false)
                ? article.publishedAt!.split('T').first
                : '';

            return GestureDetector(
              onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
              child: Stack(
                children: [
                  // card
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF151515),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 110,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _fallbackThumb(),
                                )
                              : _fallbackThumb(),
                        ),
                       SizedBox(width: 12),

                        // info teks
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                               SizedBox(height: 4),

                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                               SizedBox(height: 6),

                                Text(
                                  date,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // icon heart nya
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.toggleFavorite(article),
                        customBorder: CircleBorder(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _fallbackThumb() => Container(
    width: 110,
    height: 90,
    color: AppColors.divider,
    child: Icon(Icons.image_not_supported, color: Colors.white54),
  );
}
