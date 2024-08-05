import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/customTextField.dart';
import 'package:zapper/Components/errorCheck.dart';
import 'package:zapper/Components/submitButton.dart';
import 'package:zapper/Screens/home.dart';
import 'package:zapper/Screens/adminPanel.dart'; // Import the AdminPanel screen

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Set the initial screen
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      try {
        await FirebaseAuth.instance.signInWithCustomToken(token);
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String email = user.email!;
          if (email == 'admin@zapper.com') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPanel()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        userEmail: email,
                      )),
            );
          }
        }
      } catch (e) {
        // If there's an error (e.g., token expired), clear the token and show login screen
        prefs.remove('authToken');
      }
    }
  }

  void validateAndSignIn() async {
    setState(() {
      emailError = ErrorCheck.validateEmail(emailController.text)
          ? null
          : 'Email is invalid';
      passwordError = ErrorCheck.validatePassword(passwordController.text)
          ? null
          : 'Password is invalid';
    });

    if (emailError == null && passwordError == null) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Save the token
        String? token = await userCredential.user?.getIdToken();
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('authToken', token);
        }

        // Check if the user is an admin
        if (userCredential.user != null) {
          // Get user email
          String email = userCredential.user!.email!;
          String userId = userCredential.user!.uid; // Get user ID

          if (email == 'admin@zapper.com') {
            // Navigate to Admin Panel if admin email
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPanel()),
            );
          } else {
            // Navigate to Home Screen if not admin, passing userId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        userEmail: email,
                      )),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong password provided for that user.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong email or password')),
          );
        }
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
                            "Login",
                            style: TextStyle(
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Colors.white),
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
                      Row(
                        children: [
                          Text(
                            "email",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      CustomTextFormField(
                        labelText: 'yourmail@gmail.com',
                        controller: emailController,
                        errorText: emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Text(
                            "password",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      CustomTextFormField(
                          labelText: 'Password',
                          obscureText: true,
                          controller: passwordController,
                          errorText: passwordError,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next),
                      Row(
                        children: [
                          Spacer(),
                          TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(color: AppColors.primaryColor),
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SubmitButton(
                        color: AppColors.primaryColor,
                        borderColor: AppColors.primaryColor,
                        text: 'Login',
                        textColor: AppColors.whiteColor,
                        height: 40.h,
                        onPressed: validateAndSignIn,
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
