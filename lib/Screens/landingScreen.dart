import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/submitButton.dart';
import 'package:zapper/Screens/getStart.dart';
import 'package:zapper/Screens/home.dart';
import 'package:zapper/Screens/login.dart';
import 'package:zapper/Screens/signup.dart';
import 'package:zapper/Components/googleSignin.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Background(
              topColor: AppColors.primaryColor,
              bottomColor: AppColors.whiteColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),
                      Image.asset(
                        'images/logo.png',
                        height: 34.h,
                        width: 197.w,
                      ),
                      SizedBox(height: 40.h),
                      Image.asset(
                        'images/landing.png',
                        height: 239.h,
                        width: 272.w,
                      ),
                      SubmitButton(
                        color: AppColors.primaryColor,
                        borderColor: AppColors.primaryColor,
                        text: 'Login',
                        textColor: AppColors.whiteColor,
                        height: 40.h,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                      SubmitButton(
                        color: AppColors.whiteColor,
                        borderColor: AppColors.secondaryColor,
                        text: 'Signup',
                        textColor: AppColors.secondaryColor,
                        height: 40.h,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GetStartedScreen()),
                          );
                        },
                      ),
                      SubmitButton(
                        color: AppColors.whiteColor,
                        borderColor: AppColors.primaryColor,
                        text: 'Register as a Delivery Person',
                        textColor: AppColors.primaryColor,
                        height: 40.h,
                        onPressed: () {
                          // Handle register as delivery person press
                        },
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.greyColor,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or login with-',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.greyColor,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SubmitButton(
                        color: AppColors.whiteColor,
                        borderColor: AppColors.greyColor,
                        text: 'Google',
                        textColor: AppColors.blackColor,
                        height: 30.h,
                        imagePath: 'images/google.png',
                        onPressed: () async {
                          final provider = Provider.of<GooglesigninProvider>(
                              context,
                              listen: false);
                          Map<String, String>? userInfo =
                              await provider.googleLogin();

                          if (userInfo != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(userId: userInfo['uid']!),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google Sign-In failed')),
                            );
                          }
                        },
                      ),
                      SubmitButton(
                        color: AppColors.facebookColor,
                        borderColor: AppColors.facebookColor,
                        text: 'Facebook',
                        textColor: AppColors.whiteColor,
                        height: 30.h,
                        imagePath: 'images/fb.png',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
