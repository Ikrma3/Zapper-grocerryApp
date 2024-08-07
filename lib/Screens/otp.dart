import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Screens/home.dart';
import 'package:zapper/Screens/login.dart';
import 'dart:convert';

import 'package:zapper/Screens/signup.dart';

class OTPScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String Address;
  final String otp;
  final LatLng coordinates;

  const OTPScreen({
    Key? key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.Address,
    required this.otp,
    required this.coordinates,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  String? otpError;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _verifyOTP() async {
    setState(() {
      otpError = otpController.text == widget.otp ? null : 'Invalid OTP';
    });

    if (otpError == null) {
      try {
        // Create user in Firebase Auth
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );

        // Save user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': widget.fullName,
          'email': widget.email,
          'phone': widget.phone,
          'Address': widget.Address,
          'coordinates': {
            'latitude': widget.coordinates.latitude,
            'longitude': widget.coordinates.longitude,
          },
        });

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        print('Error during OTP verification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.primaryColor,
      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Enter OTP",
                            style: TextStyle(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      TextField(
                        controller: otpController,
                        decoration: InputDecoration(
                          labelText: 'OTP',
                          errorText: otpError,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _verifyOTP,
                        child: Text('Verify OTP'),
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
