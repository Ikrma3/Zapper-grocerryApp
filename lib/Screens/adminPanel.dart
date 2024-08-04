import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Screens/addCategory.dart';
import 'package:zapper/Screens/addProduct.dart';
import 'package:zapper/Screens/adminEditProduct.dart';
import 'package:zapper/Screens/deleteProduct.dart';
import 'package:zapper/Screens/discountScreen.dart';
import 'package:zapper/Screens/editCategories.dart';
import 'package:zapper/Screens/landingScreen.dart'; // Import the landing screen

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Admin Panel',
          style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();

                // Remove the token from SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('authToken');

                // Navigate to the landing screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LandingScreen()),
                );
              } catch (e) {
                print("Error signing out: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(children: [
          Background(
            topColor: AppColors.primaryColor,
            bottomColor: AppColors.secondaryColor,
            // Adjust this value as needed
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AdminOptionButton(
                    text: 'Add Category',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCategoryScreen()),
                      );
                    },
                  ),
                  AdminOptionButton(
                    text: 'Add Product',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddProductScreen()),
                      );
                    },
                  ),
                  AdminOptionButton(
                    text: 'Edit Category',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditCategoryScreen()),
                      );
                    },
                  ),
                  AdminOptionButton(
                    text: 'Edit Product',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProductScreen()),
                      );
                    },
                  ),
                  AdminOptionButton(
                    text: 'Delete Product',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteProductScreen()),
                      );
                    },
                  ),
                  AdminOptionButton(
                    text: 'ADD Discount',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddDiscountScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class AdminOptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  AdminOptionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.whiteColor,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
