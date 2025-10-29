import 'dart:ui'; // 👈 perlu untuk BackdropFilter (glass)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:insightly_app/models/news_articles.dart';
import 'package:insightly_app/utils/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago ;

class NewsDetailScreen extends StatelessWidget {
  final NewsArticles article = Get.arguments as NewsArticles;

  NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String publishedLabel =
        (article.publishedAt != null && article.publishedAt!.isNotEmpty)
            ? timeago.format(DateTime.parse(article.publishedAt!))
            : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,

              // 👇 tambahan UI (dark++): judul kecil saat collapse (1 baris saja)
              titlePadding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 14),
              title: (article.title ?? '').isNotEmpty
                  ? Text(
                      article.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : null,

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
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white38),
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

                  // 👇 tambahan UI (dark++): gradient atas untuk kontras status bar & actions
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),

                  // 👇 tambahan UI (dark++): title, pill source, meta di atas foto (bawah)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((article.source?.name ?? '').isNotEmpty)
                          _GlassPill(label: article.source!.name!),
                        const SizedBox(height: 10),

                        if ((article.title ?? '').isNotEmpty)
                          Text(
                            article.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            const Text('Trending', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(width: 6),
                            const Text('•', style: TextStyle(color: Colors.white54)),
                            const SizedBox(width: 6),
                            Text(publishedLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 👇 tambahan UI (dark++): dock actions kaca mengambang (Share / Copy / Open)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _FloatingActionDock(
                      onShare: _shareArticle,
                      onCopy: _showLinkSheet,   // 👈 copy tampilkan bottom sheet cantik
                      onOpen: _openInBrowser,
                    ),
                  ),

                  // 👇 tambahan UI (dark++): gradient bawah agar transisi ke panel konten mulus
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // actions default tetap ada (biar familiar); boleh dibiarkan untuk akses tambahan
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareArticle(),
                tooltip: 'Share',
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'copy_link':
                      _showLinkSheet(); // 👉 buat lebih cantik daripada snackbar polos
                      break;
                    case 'open_browser':
                      _openInBrowser();
                      break;
                  }
                },
                color: const Color(0xFF151515),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy_link',
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Copy Link', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'open_browser',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Open in browser', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
              const SizedBox(width: 6),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              // 👇 tambahan UI (dark++): panel konten gelap dengan border & gradient ring tipis
              padding: EdgeInsets.zero,
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                  // “gradient ring” halus di tepi panel
                  gradient: const LinearGradient(
                    colors: [Color(0x22FFFFFF), Color(0x11000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // source and date
                        Row(
                          children: [
                            if (article.source?.name != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  article.source!.name!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (article.publishedAt != null) ...{
                              Text(
                                timeago.format(DateTime.parse(article.publishedAt!)),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            }
                          ],
                        ),
                        const SizedBox(height: 16),

                        //title
                        if (article.title != null) ...[
                          Text(
                            article.title!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.3
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        //description
                        if (article.description != null) ...[
                          Text(
                            article.description!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.5
                            ),
                          )
                        ],
                        const SizedBox(height: 20),

                        //content
                        if (article.content != null) ...[
                          const Text(
                            'content',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.content!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              height: 1.6
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Read full article button
                        if (article.url != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _openInBrowser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                                )
                              ),
                              child: const Text(
                                'Read Full Article',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _shareArticle() {
    if (article.url != null) {
      Share.share(
        '${article.title ?? 'Check out this news'}\n\n${article.url!}',
        subject: article.title
      );
    }
  }

  void _copyLink() {
    if (article.url != null) {
      Clipboard.setData(ClipboardData(text: article.url!));
      // 👇 tambahan UI (dark++): snackbar bergaya floating + icon
      Get.snackbar(
        'Link Copied',
        'URL saved to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1A1A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white70),
        snackStyle: SnackStyle.FLOATING,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _openInBrowser() async{
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
          snackPosition: SnackPosition.BOTTOM
        );
      }
    }
  }

  // 👇 tambahan UI (dark++): bottom sheet cantik untuk preview & copy link
  void _showLinkSheet() {
    if (article.url == null || article.url!.isEmpty) return;

    final url = article.url!;
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: const Color(0xFF1A1A1A).withOpacity(0.9),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Article Link',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: Colors.white54, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              _copyLink();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                            label: const Text('Copy', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openInBrowser();
                            },
                            icon: const Icon(Icons.open_in_browser, size: 18),
                            label: const Text('Open in Browser'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.25)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _shareArticle();
                            },
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.25)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============ WIDGET KECIL TAMBAHAN ============

// pill kaca kecil
class _GlassPill extends StatelessWidget {
  final String label;
  const _GlassPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// dock actions kaca di kanan atas header
class _FloatingActionDock extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onOpen;

  const _FloatingActionDock({
    required this.onShare,
    required this.onCopy,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              _dockBtn(icon: Icons.share, tooltip: 'Share', onTap: onShare),
              _dockDivider(),
              _dockBtn(icon: Icons.link, tooltip: 'Copy link', onTap: onCopy),
              _dockDivider(),
              _dockBtn(icon: Icons.open_in_browser, tooltip: 'Open', onTap: onOpen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dockBtn({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _dockDivider() => Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        color: Colors.white.withOpacity(0.18),
      );
}
