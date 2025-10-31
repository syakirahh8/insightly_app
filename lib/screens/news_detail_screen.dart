import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:insightly_app/models/news_articles.dart';
import 'package:insightly_app/utils/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:insightly_app/controllers/news_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsDetailScreen extends StatelessWidget {
  final NewsArticles article = Get.arguments as NewsArticles;

  NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String published = (article.publishedAt?.isNotEmpty ?? false)
        ? timeago.format(DateTime.parse(article.publishedAt!))
        : '';

    const bool ShowBodyTitle = true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              collapseMode: CollapseMode.parallax,
              expandedTitleScale: 1.0,

              background: Stack(
                fit: StackFit.expand,
                children: [
                  // statement yang akan dijalankan ketika server memiliki gambar
                  article.urlToImage != null && article.urlToImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.divider,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white38,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.divider,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.textHint,
                            ),
                          ),
                        )
                      // statement yang akan dijalankan ketika server tidak memiliki gambar
                      // atau => image == null
                      : Container(
                          color: AppColors.divider,
                          child: Icon(
                            Icons.newspaper,
                            size: 50,
                            color: AppColors.textHint,
                          ),
                        ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Colors.black45, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Row(
                      children: [
                        if ((article.source?.name ?? '').isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.62),
                              ),
                            ),
                            child: Text(
                              article.source!.name!,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (published.isNotEmpty) ...[
                          SizedBox(width: 8),
                          Text('•', style: TextStyle(color: Colors.white54)),
                          SizedBox(width: 8),
                          Text(
                            published,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              Obx(() {
                final c = Get.find<NewsController>();
                final isFav = c.isFavorite(
                  article,
                ); // pastikan NewsController punya isFavorite()

                return IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                  tooltip: isFav ? 'Remove from Favorites' : 'Add to Favorites',
                  onPressed: () => c.toggleFavorite(
                    article,
                  ), // toggleFavorite()
                );
              }),

              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareArticle(),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'copy_link':
                      _copyLink();
                      break;
                    case 'open_browser':
                      _openInBrowser();
                  }
                },
                color: Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'copy_link',
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'Copy Link',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'open_browser',
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_in_browser,
                          size: 18,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Open in browser',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert),
              ),
              SizedBox(width: 6),
            ],
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF151515),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              padding: EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ShowBodyTitle && (article.title ?? '').isNotEmpty) ...[
                    Text(
                      article.title!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 14),
                  ],

                  //description
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: 18),

                  //content
                  if (article.content != null) ...[
                    Text(
                      'content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      article.content!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 22),
                  ],
                  // button nya biar ttp dibawah
                  Spacer(),

                  // button
                  if (article.url != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openInBrowser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Read Full Article',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareArticle() {
    if (article.url != null) {
      Share.share(
        '${article.title ?? 'Check out this news'}\n\n${article.url!}',
        subject: article.title,
      );
    }
  }

  void _copyLink() {
    if (article.url != null) {
      Clipboard.setData(ClipboardData(text: article.url!));
      Get.snackbar(
        'Link Copied',
        'URL saved to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF1A1A1A),
        colorText: Colors.white,
        margin: EdgeInsets.all(12),
        borderRadius: 12,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.check_circle, color: Colors.white70),
        snackStyle: SnackStyle.FLOATING,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _openInBrowser() async {
    if (article.url != null) {
      final Uri url = Uri.parse(article.url!);
      // proses menunggu apakah  url valid dan bisa dibuka oleh browser
      if (await canLaunchUrl(url)) {
        // proses menunggu ketika url udh valid dan sedang di proses oleh browser sampai datanya muncul
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          "couldn't open the link",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF1A1A1A),
          colorText: Colors.white,
          margin: EdgeInsets.all(12),
          borderRadius: 12,
          duration: Duration(seconds: 3),
          icon: Icon(Icons.error_outline_rounded, color: Colors.white70),
          snackStyle: SnackStyle.FLOATING,
        );
        HapticFeedback.lightImpact();
      }
    }
  }
}
