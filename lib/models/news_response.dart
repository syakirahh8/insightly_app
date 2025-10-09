import 'package:news_app/models/news_articles.dart';

class NewsResponse {
  final String status;
  final int totalResult;
  final List<NewsArticles> articles;

  NewsResponse({required this.status, required this.totalResult, required this.articles});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      totalResult: json['totalResult'] ?? 0,
      // kode yang digunakan untuk mengkonversi data mentah dari server
      // agar siap digunakan oleh aplikasi
      articles: (json['articles'] as List<dynamic>?)
                ?.map((article) => NewsArticles.fromJson(article))
                .toList() ?? []
    );
  }
}