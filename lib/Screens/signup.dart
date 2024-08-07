import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/customTextField.dart';
import 'package:zapper/Components/errorCheck.dart';
import 'package:zapper/Components/mapScreen.dart';
import 'package:zapper/Components/submitButton.dart';
import 'package:zapper/Screens/otp.dart';
import 'package:zapper/config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String address = "";
  late LatLng _selectedCoordinates;

  String? emailError;
  String? passwordError;
  String? phoneError;
  String? nameError;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }
  }

  Future<Position?> _getCurrentLocation() async {
    await requestLocationPermission();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  Future<void> validateSignup() async {
    setState(() {
      emailError = ErrorCheck.validateEmail(emailController.text)
          ? null
          : 'Email is invalid';
      passwordError = ErrorCheck.validatePassword(passwordController.text)
          ? null
          : 'Password is invalid';
      phoneError = ErrorCheck.validatePhone(phoneController.text)
          ? null
          : 'Phone no is invalid';
      nameError = ErrorCheck.validateName(fullNameController.text)
          ? null
          : 'Name is invalid';
    });

    if (emailError == null &&
        passwordError == null &&
        phoneError == null &&
        nameError == null) {
      try {
        // Check if email already exists
        final emailInUse =
            await _auth.fetchSignInMethodsForEmail(emailController.text);
        if (emailInUse.isNotEmpty) {
          setState(() {
            emailError = 'Email already in use';
          });
          return;
        }

        // Generate OTP
        final otp = generateOTP();

        // Send OTP to email
        await sendOTPEmail(emailController.text, otp);

        // Navigate to OTPScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              fullName: fullNameController.text,
              email: emailController.text,
              phone: phoneController.text,
              password: passwordController.text,
              Address: address,
              otp: otp,
              coordinates: _selectedCoordinates,
            ),
          ),
        );
      } catch (e) {
        print('Error during signup: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create user: ${e.toString()}')),
        );
      }
    }
  }

  String generateOTP() {
    final otp = (1000 +
            (9999 - 1000) *
                (DateTime.now().millisecondsSinceEpoch % 1000) /
                1000)
        .round();
    return otp.toString();
  }

  Future<void> sendOTPEmail(String email, String otp) async {
    final username = Config.email;
    final password = Config.googleAppId;
    final smtpServer = gmail(username!, password!);

    final message = Message()
      ..from = Address(username, 'Zapper')
      ..recipients.add(email)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<void> _openMapScreen() async {
    Position? position = await _getCurrentLocation();

    if (position != null) {
      LatLng initialLocation = LatLng(position.latitude, position.longitude);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            initialPosition: initialLocation,
            onLocationSelected: (String address, LatLng coordinates) {
              setState(() {
                this.address = address;
                this._selectedCoordinates = coordinates;
              });
            },
          ),
        ),
      );
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
                            "Signup",
                            style: TextStyle(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          Image.asset(
                            'images/login.png',
                            height: 317.h,
                            width: 158.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      CustomTextFormField(
                        labelText: 'Full Name',
                        controller: fullNameController,
                        errorText: nameError,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        labelText: 'Email',
                        controller: emailController,
                        errorText: emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextFormField(
                        labelText: 'Phone',
                        controller: phoneController,
                        errorText: phoneError,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextFormField(
                        labelText: 'Password',
                        obscureText: true,
                        controller: passwordController,
                        errorText: passwordError,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 15.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.secondaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          minimumSize: Size(240.w, 35.h),
                        ),
                        onPressed: _openMapScreen,
                        child: Text('Select Address'),
                      ),
                      SizedBox(height: 10.h),
                      SubmitButton(
                        color: AppColors.primaryColor,
                        borderColor: AppColors.primaryColor,
                        text: 'Signup',
                        textColor: AppColors.whiteColor,
                        height: 40.h,
                        onPressed: validateSignup,
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
