import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(StorageService.boxName);

  runApp(
    const ProviderScope(
      child: NunuyaApp(),
    ),
  );
}

class NunuyaApp extends StatelessWidget {
  const NunuyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nunuya Star Academy',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
