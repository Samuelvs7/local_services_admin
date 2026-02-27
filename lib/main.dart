import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'core/screens/not_found_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/widgets/app_toaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Local Services Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.orangeTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeType == AppThemeType.orange ? ThemeMode.light : ThemeMode.dark,
      home: const AdminLoginScreen(),
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const NotFoundScreen(),
      ),
      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const AppToaster(),
          ],
        );
      },
    );
  }
}
