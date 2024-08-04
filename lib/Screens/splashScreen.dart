import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zapper/Screens/landingScreen.dart';
import 'package:zapper/Screens/adminPanel.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Delay to show the splash screen for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Get the current user from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate based on email
      String email = user.email!;
      if (email == 'admin@zapper.com') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanel()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingScreen()),
        );
      }
    } else {
      // No user is signed in, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set the status bar color to match the splash screen
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(
            83, 185, 124, 1), // Match the dark green color in your image
      ),
    );

    return Scaffold(
      body: Container(
        color: Color.fromRGBO(46, 174, 125, 1), // Full screen dark green color
        child: CustomPaint(
          painter: SplashPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Image.asset(
                  'images/logo.png',
                  width: 204.w,
                  height: 40.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          Color.fromRGBO(83, 185, 124, 1) // Light green color for the ellipses
      ..style = PaintingStyle.fill;

    // Define the path for the top ellipse
    final topEllipsePath = Path()
      ..addOval(Rect.fromLTWH(
          -166, -150, 576, 489)); // Top ellipse dimensions and position

    // Draw the top ellipse path on the canvas
    canvas.drawPath(topEllipsePath, paint);

    // Define the path for the bottom ellipse
    final bottomEllipsePath = Path()
      ..addOval(Rect.fromLTWH(
          -149, 598, 596, 489)); // Bottom ellipse dimensions and position

    // Draw the bottom ellipse path on the canvas
    canvas.drawPath(bottomEllipsePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
