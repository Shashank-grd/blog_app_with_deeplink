import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zarity/core/screens/blog_upload_screen.dart';
import 'package:zarity/core/screens/home.dart';


import 'firebase_options.dart';

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const BlogUploadScreen(),
      ),
      GoRoute(
        path: '/post/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId'] ?? '';
          return HomeScreen(initialDeeplink: 'post/$postId');
        },
      ),
    ],
    redirect: (context, state) {
      final uri = state.uri;
      final host = uri.host;
      final path = uri.path;


      if (host == 'zarity.example.com') {
        
        if (path.startsWith('/upload')) {
          return '/upload';
        }
        
        if (path.startsWith('/post/')) {
          final postId = path.substring('/post/'.length);
          if (postId.isNotEmpty) {
            return '/post/$postId';
          }
        }
      }
      
      return null;
    },
    onException: (_, GoRouterState state, GoRouter router) {
      debugPrint('Navigation error: ${state.uri}');
      router.go('/');
    },
  );


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //define Global theme data
    return MaterialApp.router(
      title: 'Blog App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        primaryColor: const Color(0xFF3F51B5), // Indigo
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF3F51B5),
          elevation: 2,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF3F51B5),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF3F51B5),
            elevation: 3,
            shadowColor: const Color(0xFF3F51B5).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          floatingLabelStyle: const TextStyle(color: Color(0xFF3F51B5)),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
            letterSpacing: -0.2,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF424242),
            height: 1.5,
            letterSpacing: 0.1,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF424242),
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}


