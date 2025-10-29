import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String baseUrl = 'https://newsapi.org/v2/';

  // Get API KEY form env variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // list of endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // list of categories
  static const List<String> categories = [
    'General',
    'Technology',
    'Business',
    'Sports',
    'Health',
    'Science',
    'Entertainment',
  ];
  
  // countries
  static const String defaultCountry = 'us';

  // app info
  static const String appName = 'News App';
  static const String appVersion = '1.0.0';
}