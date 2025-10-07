import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constants/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/location_setup_screen.dart';
import 'services/billing_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.initialize();
  
  runApp(const AivellumApp());
}

class AivellumApp extends StatefulWidget {
  const AivellumApp({super.key});

  @override
  State<AivellumApp> createState() => _AivellumAppState();
}

class _AivellumAppState extends State<AivellumApp> {
  @override
  void dispose() {
    BillingService.dispose();
    AdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Aivellum',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/main': (context) => const MainScreen(),
          '/location-setup': (context) => const LocationSetupScreen(),
        },
      ),
    );
  }
}