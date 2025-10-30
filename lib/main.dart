import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:insightly_app/bindings/app_bindings.dart';
import 'package:insightly_app/routes/app_pages.dart';
import 'package:insightly_app/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load environtment variables first before running the app
  await dotenv.load(fileName: '.env');

  runApp(InsightlyApp());
}

class InsightlyApp extends StatelessWidget {
  const InsightlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'News App',
      theme: ThemeData(
        fontFamily: 'Manrope',
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white
          )
        )
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
      debugShowCheckedModeBanner: false,
    );
  }
}

