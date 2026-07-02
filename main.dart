import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'shared/constants/flavor_config.dart';
import 'shared/themes/app_theme.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/ai_service.dart';
import 'shared/utils/accessibility_helper.dart';

// App Entry Points
import 'customer/app.dart' as customer_app;
import 'delivery/app.dart' as delivery_app;
import 'admin/app.dart' as admin_app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize AI Service
  await AIService.initialize();

  // Set preferred orientations (support all screens)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Detect flavor from environment or app package
  final flavor = FlavorConfig.currentFlavor;

  runApp(RestaurantSystemApp(flavor: flavor));
}

class RestaurantSystemApp extends StatelessWidget {
  final AppFlavor flavor;

  const RestaurantSystemApp({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: flavor.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(flavor),
          darkTheme: AppTheme.getDarkTheme(flavor),
          themeMode: ThemeMode.system,

          // Accessibility
          showSemanticsDebugger: false,

          // Responsive Framework
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1200, name: DESKTOP),
              const Breakpoint(start: 1201, end: double.infinity, name: '4K'),
            ],
          ),

          home: _getAppHome(),
        );
      },
    );
  }

  Widget _getAppHome() {
    switch (flavor) {
      case AppFlavor.customer:
        return const customer_app.CustomerApp();
      case AppFlavor.delivery:
        return const delivery_app.DeliveryApp();
      case AppFlavor.admin:
        return const admin_app.AdminApp();
    }
  }
}
