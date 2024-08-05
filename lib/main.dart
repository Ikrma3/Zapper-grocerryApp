import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zapper/Components/googleSignin.dart';
import 'package:zapper/Screens/adminPanel.dart';
import 'package:zapper/Screens/home.dart';
import 'package:zapper/Screens/landingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zapper/Screens/splashScreen.dart';
import 'package:provider/provider.dart';
import 'package:zapper/config.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: Config.apiKey,
          appId: Config.appId,
          iosBundleId: Config.iosBundleId,
          messagingSenderId: Config.messagingSenderId,
          projectId: Config.projectId,
          storageBucket: Config.storageBucket));
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
            themeMode: ThemeMode.system,
            home: SplashScreen(),
            // Use the system theme
            // home: HomeScreen(
            //   userEmail: 'f190231@nu.edu.pk',
            // ),
          ),
        );
      },
    );
  }
}
