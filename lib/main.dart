import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'base/api/endpoint/api_endpoint.dart';
import 'base/maintenance/maintenance_dialog.dart';
import 'base/utils/basic_import.dart';
import 'base/services/location_service.dart';
import 'base/services/delivery_service.dart';
import 'base/services/realtime_service.dart';
import 'base/localization/dynamic_language_shim.dart';
import 'generated/l10n/app_localizations.dart';
import 'initializer.dart';
import 'routes/routes.dart';
import 'views/all_vendors_dashboard/utils/custom_image_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Note: PusherBeamsService.initialize() is called AFTER user login
    // in the splash controller or login screen, not here at startup
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue app execution even if Firebase fails
  }
  
  await AppInitializer.init();
  
  // Debug: print presence of auth token(s) at startup (redacted by default)
  
  configureHttpClient();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is closing, disconnect Pusher
      RealtimeService().disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      designSize: const Size(375, 812),
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splashScreen,
        title: Strings.appName,
        theme: Themes.light,
        darkTheme: Themes.dark,
        getPages: Routes.list,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        initialBinding: BindingsBuilder(() async {
          Get.put(SystemMaintenanceController());
          // Initialize location and delivery services
          await Get.putAsync(() async => LocationService());
          Get.put(DeliveryService());
          try {
            // Ensure DynamicLanguage/I18n initialization completes before UI builds
            await DynamicLanguage.init(url: ApiConfig.languageUrl);
          } catch (e) {
            // Fallback if language loading fails
            print('Language initialization error: $e');
            // Continue with default language
          }
          Get.lazyPut(() => DashboardController());
        }),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return Obx(
            () => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: Directionality(
                textDirection: DynamicLanguage.isLoading
                    ? TextDirection.ltr
                    : DynamicLanguage.languageDirection,
                child: widget!,
              ),
            ),
          );
        },
      ),
    );
  }
}
