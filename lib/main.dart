import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zapper/Components/googleSignin.dart';
import 'package:zapper/Screens/adminPanel.dart';
import 'package:zapper/Screens/landingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zapper/Screens/splashScreen.dart';
import 'package:provider/provider.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyAYZbaOVKkb4OvGIj_5O_TTDhCnM8Lzhx8',
          appId: '1:317867164121:android:0d518e64b6b7dbcc8819c8',
          iosBundleId: 'com.example.zapper',
          messagingSenderId: '317867164121',
          projectId: 'zapper-8b2c0',
          storageBucket: 'gs://zapper-8b2c0.appspot.com'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (context) => GooglesigninProvider(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(), // Default light theme
            darkTheme: ThemeData.dark(), // Default dark theme
            themeMode: ThemeMode.system, // Use the system theme
            home: SplashScreen(),
          ),
        );
      },
    );
  }
}
