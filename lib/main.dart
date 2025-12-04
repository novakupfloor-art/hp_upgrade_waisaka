import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/screens_splash.dart';
import 'providers/management_property.dart';
import 'providers/management_article.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
  } catch (e) {
    debugPrint('❌ CRITICAL: Could not load .env file: $e');
    // Continue anyway - app will use fallback values
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
      ],
      child: MaterialApp(
        title: 'Waisaka Property',
        theme: ThemeData(
          primaryColor: const Color(0xFF1A237E),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
