import 'package:get/get.dart';
import 'package:insightly_app/models/news_articles.dart';
import 'package:insightly_app/services/news_services.dart';
import 'package:insightly_app/utils/constants.dart';

class NewsController extends GetxController {
  // untuk memproses request yang sudah dibuat oleh news services
  final NewsServices _newsServices = NewsServices();

  // setter
  // observable variables (variable yang bisa berubah)
  final _isLoading = false.obs; // apakah aplikasi sedang membuat berita dan nilainya adalah
  final _articles = <NewsArticles>[].obs; // ini untuk menampilkan data berita yang sudah berhasil didapat.
  final _selectedCategory = 'general'.obs; // untuk handle category yang sedang dipilih (atau yang akan muncul di home screen)
  final _error = ''.obs; // kalau ada kesalahan pesan error akan disimpan disini

  // Getters
  // getter ini seperti jendela untuk melihat isi variable yang sudah didefinisikan
  // dengan ini UI bisa dengan mudah melihat data dari controller
  bool get isLoading => _isLoading.value;
  List<NewsArticles> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  // begitu aplikasi dibuka, aplikasi langsung menampilkan berita utama 
  // dari endpoint top-headline
  // TODO: Fetching data dari endpoint top-headlines

  Future<void> fetchTopHeadlines({String? category}) async {
    // blok ini akan dijalankan ketika REST API berhasil berkomunikasi dengan server
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsServices.getTopHeadLines(
        category: category ?? _selectedCategory.value,
      );

      _articles.value = response.articles;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      // finally akan tetap di execute setelah salah satu dari blok try atau catch sudah berhasil mendapatkan hasil
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) return;
    
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsServices.searchNews(query: query);
      _articles.value = response.articles;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      _isLoading.value = false;
    }
  }
}