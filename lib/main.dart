import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mini_social_media_application/core/routes/app_routes.dart';
import 'package:mini_social_media_application/core/theme/app_theme.dart';
import 'package:mini_social_media_application/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mini Social Media',
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: AppTheme.light,

      // Dark Theme
      darkTheme: AppTheme.dark,

      // Follow mobile system theme
      themeMode: ThemeMode.system,

      routerConfig: appRouter,
    );
  }
}
