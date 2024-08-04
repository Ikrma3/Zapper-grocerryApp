import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/submitButton.dart';
import 'package:zapper/Screens/signup.dart';

class GetStartedScreen extends StatefulWidget {
  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onContinuePressed() {
    if (_currentIndex == 2) {
      // Navigate to the next screen when the "Get Started" button is pressed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupScreen()),
      ); // Replace with your next screen
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Widget _buildPageContent(String text, String imagePath, String imagePath2) {
    return Padding(
      padding: EdgeInsets.all(8.0.w.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png',
            height: 34.h,
            width: 184.w,
          ), // Your logo image
          SizedBox(height: 60.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 10.w,
              ),
              Image.asset(imagePath, height: 285.h),
              Image.asset(imagePath2, height: 285.h),
            ],
          ), // Dynamic image based on index
          SizedBox(height: 60.h),
          Text(
            text,
            style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Roboto',
                color: Colors.white,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          SubmitButton(
            color: AppColors.whiteColor,
            borderColor: AppColors.whiteColor,
            text: _currentIndex == 2 ? 'Get Started' : 'Continue',
            textColor: AppColors.primaryColor,
            height: 40.h,
            onPressed: _onContinuePressed,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Background(
            topColor: AppColors.primaryColor,
            bottomColor: AppColors.secondaryColor,
            // Adjust this value as needed
          ),
          Padding(
            padding: EdgeInsets.all(8.0.w.h),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildPageContent(
                          'Welcome to Zapper! Explore the features and enjoy.',
                          'images/getStart.png',
                          'images/login.png'),
                      _buildPageContent(
                          'Discover new possibilities and stay connected.',
                          'images/getStart.png',
                          'images/login.png'),
                      _buildPageContent(
                          'Zapper is a solution for Grocery Shopping every you need',
                          'images/getStart.png',
                          'images/login.png'),
                    ],
                  ),
                ),
                _buildPageIndicators(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: _currentIndex == index ? 12.w : 8.w,
            height: _currentIndex == index ? 12.h : 8.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index ? Colors.white : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}
