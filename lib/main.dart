import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:dynamic_languages/dynamic_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'base/api/endpoint/api_endpoint.dart';
import 'base/maintenance/maintenance_dialog.dart';
import 'base/utils/basic_import.dart';
import 'base/services/location_service.dart';
import 'base/services/delivery_service.dart';
import 'initializer.dart';
import 'routes/routes.dart';
import 'views/all_vendors_dashboard/utils/custom_image_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        initialBinding: BindingsBuilder(() async {
          Get.put(SystemMaintenanceController());
          // Initialize location and delivery services
          await Get.putAsync(() async => LocationService());
          Get.put(DeliveryService());
          try {
            DynamicLanguage.init(url: ApiConfig.languageUrl);
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
