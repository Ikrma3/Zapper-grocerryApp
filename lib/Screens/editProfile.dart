import 'dart:io';
import 'dart:math'; // For generating OTP

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/mapScreen.dart';
import 'package:zapper/Screens/login.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  EditProfileScreen({required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String userName = '';
  String userPhone = '';
  String userAddress = '';
  String userEmail = '';
  LatLng userCoordinates = LatLng(0, 0);
  String profileImageUrl = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  String? _otp;
  String? _newEmail;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        setState(() {
          userName = userData['fullName'] ?? '';
          userPhone = userData['phone'] ?? '';
          userAddress = userData['Address'] ?? '';
          userEmail = userData['email'] ?? '';
          profileImageUrl = userData['profileImage'] ?? '';

          double latitude = userData['latitude']?.toDouble() ?? 0.0;
          double longitude = userData['longitude']?.toDouble() ?? 0.0;

          userCoordinates = LatLng(latitude, longitude);

          nameController.text = userName;
          phoneController.text = userPhone;
          addressController.text = userAddress;
          emailController.text = userEmail;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(
              '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_imageFile!);

      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        profileImageUrl = downloadUrl;
      });

      await _updateProfileImageInFirestore(downloadUrl);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _updateProfileImageInFirestore(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'profileImage': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      print('Error updating profile image in Firestore: $e');
    }
  }

  Future<bool> _isEmailRegistered(String email) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email registration: $e');
      return false;
    }
  }

  Future<void> _sendOtp(String email) async {
    // Generate a random OTP
    _otp = (Random().nextInt(900000) + 100000).toString();

    // Ideally, send the OTP via email here using your preferred method.
    // For demonstration, we'll just print it.
    print('OTP for email verification: $_otp');

    // You might want to save the OTP temporarily to verify later.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailOtp', _otp!);
    await prefs.setString('newEmail', email);

    // Replace this with your method to send OTP via email.
    // For now, we assume the OTP is sent to the new email address.
  }

  Future<void> _verifyOtp(String enteredOtp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedOtp = prefs.getString('emailOtp');
    String? newEmail = prefs.getString('newEmail');

    if (storedOtp == enteredOtp) {
      // OTP matches, update email in Firebase Auth and Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && newEmail != null) {
        try {
          await user.updateEmail(newEmail);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .update({'email': newEmail});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email updated successfully')),
          );

          // Clear OTP and newEmail
          await prefs.remove('emailOtp');
          await prefs.remove('newEmail');
        } catch (e) {
          print('Error updating email: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating email')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  Future<void> _showEmailPopup() async {
    String newEmail = '';
    TextEditingController emailPopupController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailPopupController,
                decoration: InputDecoration(labelText: 'New Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => newEmail = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await _isEmailRegistered(newEmail)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email is already registered')),
                  );
                } else {
                  _newEmail = newEmail;
                  await _sendOtp(newEmail);
                  Navigator.pop(context);
                  _showOtpVerificationDialog();
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOtpVerificationDialog() async {
    String otp = '';
    TextEditingController otpController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Verify OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
                onChanged: (value) => otp = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _verifyOtp(otp);
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialPosition: userCoordinates,
          onLocationSelected: (address, coordinates) {
            setState(() {
              userAddress = address;
              addressController.text = address;
              userCoordinates = coordinates;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        userAddress = result['address'];
        userCoordinates = result['coordinates'];
        addressController.text = userAddress;
      });
    }
  }

  void _updateProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'fullName': nameController.text,
        'phone': phoneController.text,
        'Address': userAddress,
        'email': userEmail,
        'latitude': userCoordinates.latitude,
        'longitude': userCoordinates.longitude,
        'profileImage': profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : AssetImage('images/profile_icon.jpg')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Name'),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            Text('Phone'),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            SizedBox(height: 10),
            Text('Address'),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: 'Enter your address',
              ),
              onTap: _openMapScreen,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: Size(240.w, 35.h),
              ),
              onPressed: _updateProfile,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
