import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expense_tracker_app/constants/theme.dart';
import 'package:flutter_expense_tracker_app/controllers/theme_controller.dart';
import 'package:flutter_expense_tracker_app/providers/database_provider.dart';
import 'package:flutter_expense_tracker_app/views/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  await GetStorage.init();
  await DatabaseProvider.initDb();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.rightToLeftWithFade,
          transitionDuration: Duration(milliseconds: 1000),
          title: 'Pocket Hishab',
          theme: Themes.lightTheme,
          themeMode: _themeController.theme,
          darkTheme: Themes.darkTheme,
          home: SplashScreen(
            child: HomeScreen(),
          ),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Widget child;

  SplashScreen({required this.child});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay of 5 seconds before navigating to the main screen
    Timer(Duration(seconds: 5), () {
      Get.off(() => widget.child);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Use Image.asset for your splash screen image
        child: Image.asset('assets/splash_image.png', ),
      ),
    );
  }
}
