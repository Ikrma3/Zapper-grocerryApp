import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Screens/home.dart';
import 'dart:convert';

import 'package:zapper/Screens/signup.dart'; // For utf8.encode

class OTPScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  String otp;

  OTPScreen({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.otp,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late String email;
  List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());
  Timer? _timer;
  int _start = 60;
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _isButtonActive = false;
    _start = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonActive = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  bool _isAllOtpFilled() {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash the bytes
    return digest.toString(); // Convert hash to string
  }

  Future<void> _storeUserData() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    await userCollection.add({
      'fullName': widget.fullName,
      'email': widget.email,
      'phone': widget.phone,
      'password': hashPassword(widget.password), // Hash the password
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _verifyOtp() async {
    String enteredOtp =
        otpControllers.map((controller) => controller.text).join('');
    if (enteredOtp == widget.otp) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );
        await _storeUserData();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('User Already Exists'),
                content: Text(
                    'The email address is already in use by another account.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      ); // Navigate to signup screen
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create user: ${e.message}')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong OTP')),
      );
    }
  }

  void _resendOtp() {
    final otp = generateOTP();
    setState(() {
      widget.otp = otp;
    });
    sendOTPEmail(widget.email, otp);
    startTimer();
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
    final username = dotenv.env['EMAIL_USERNAME'];
    final password = dotenv.env['EMAIL_PASSWORD'];
    final smtpServer = gmail(username!, password!);

    final message = Message()
      ..from = Address(username, 'Your App Name')
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
                                color: Colors.white),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'An OTP has been sent to your email',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 60.w,
                            child: TextField(
                              controller: otpControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.length == 1 && index < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                                if (_isAllOtpFilled()) {
                                  _verifyOtp();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _isButtonActive ? _resendOtp : null,
                        child: Text('Resend OTP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Resend OTP in $_start seconds',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
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
