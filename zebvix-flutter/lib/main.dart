import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/security/app_lock_wrapper.dart';
import 'core/performance/performance_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Lock orientation (portrait only) — mobile only ────
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ── 2. Status bar & nav bar styling ─────────────────────
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0E11),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  // ── 3. Firebase ───────────────────────────────────────────
  // Web: skipped — no firebase config yet (add FirebaseOptions for web later).
  // Mobile: add google-services.json (Android) / GoogleService-Info.plist (iOS).
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }
  }

  // ── 4. Performance configuration ─────────────────────────
  await PerformanceConfig.initialize();

  // ── 5. Memory pressure handler — mobile only ──────────────
  if (!kIsWeb) {
    MemoryManager().init();
  }

  // ── 6. Hive offline cache ─────────────────────────────────
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('markets'),
    Hive.openBox('portfolio'),
    Hive.openBox('settings'),
    Hive.openBox('news'),
    Hive.openBox('orderbook'),
    Hive.openBox('notifications'),
  ]);

  runApp(
    const ProviderScope(
      child: ZebvixApp(),
    ),
  );
}

class ZebvixApp extends ConsumerWidget {
  const ZebvixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      scrollBehavior: const SmoothScrollBehavior(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: AppLockWrapper(child: child!),
        );
      },
    );
  }
}
