import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/root_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const FieldKitApp(),
    ),
  );
}

class FieldKitApp extends StatelessWidget {
  const FieldKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldKit AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: Consumer<AppProvider>(
        builder: (context, provider, child) {
          // Navigazione top-level
          return provider.isAuthenticated ? const RootNavigationScreen() : const LoginScreen();
        },
      ),
    );
  }
}