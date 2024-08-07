import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/viewAddressMap.dart';
import 'package:zapper/Screens/editProfile.dart';
import 'package:zapper/Screens/favouriteScreen.dart';
import 'package:zapper/Screens/landingScreen.dart';
import 'package:zapper/Screens/login.dart'; // Ensure you import the LoginScreen

class ProfileScreen extends StatefulWidget {
  final String userId; // Changed from userEmail to userId

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userPhone = '';
  String profileImageUrl = '';
  String userAddress = '';
  LatLng userCoordinates = LatLng(0, 0); // Initialize with default value

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserData(); // Fetch data when dependencies change
  }

  fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId) // Fetch user data by UID
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        setState(() {
          userName = userData['fullName'] ?? '';
          userPhone = userData['phone'] ?? '';
          profileImageUrl = userData['profileImage'] ?? '';
          userAddress = userData['Address'] ?? '';

          // Retrieve latitude and longitude, ensuring they are correctly casted
          double latitude = (userData['latitude'] as num?)?.toDouble() ?? 0.0;
          double longitude = (userData['longitude'] as num?)?.toDouble() ?? 0.0;

          userCoordinates = LatLng(latitude, longitude);
        });

        print('Coordinates: $userCoordinates');
        print('Address: $userAddress');
      } else {
        print('No user found with the given UID.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 4) return phoneNumber;
    return '${phoneNumber.substring(0, 2)}******${phoneNumber.substring(phoneNumber.length - 2)}';
  }

  void _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('authTokenExpiration');
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LandingScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
      ),
      body: Column(
        children: [
          // First Container
          Container(
            color: AppColors.secondaryColor,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : AssetImage('images/profile_icon.jpg')
                              as ImageProvider,
                    ),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          maskPhoneNumber(userPhone),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 26.h),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          userId: widget.userId, // Pass UID instead of email
                        ),
                      ),
                    );
                    if (result == true) {
                      fetchUserData(); // Refresh data if needed
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(273.w, 33.h),
                  ),
                  child: Text('Edit Profile'),
                ),
              ],
            ),
          ),
          // Second Container
          Expanded(
            child: ListView.separated(
              itemCount: 7, // Number of items in the list
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                switch (index) {
                  case 0:
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('My Address'),
                      onTap: () {
                        // Navigate to View Address Map Screen
                        print('Address is $userCoordinates');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAddressMapScreen(
                              coordinates: userCoordinates,
                              address: userAddress,
                            ),
                          ),
                        ).then((_) {
                          fetchUserData(); // Refresh data if needed
                        });
                      },
                    );
                  case 1:
                    return ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text('My Orders'),
                      onTap: () {
                        // Navigate to My Orders Screen
                      },
                    );
                  case 2:
                    return ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('My Wishlist'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FavoritesScreen(userId: widget.userId),
                          ),
                        );
                      },
                    );
                  case 3:
                    return ListTile(
                      leading: Icon(Icons.chat),
                      title: Text('Chat with us'),
                      onTap: () {
                        // Navigate to Chat with us Screen
                      },
                    );
                  case 4:
                    return ListTile(
                      leading: Icon(Icons.support),
                      title: Text('Talk to our Support'),
                      onTap: () {
                        // Navigate to Support Screen
                      },
                    );
                  case 5:
                    return ListTile(
                      leading: Icon(Icons.mail),
                      title: Text('Mail to us'),
                      onTap: () {
                        // Navigate to Mail to us Screen
                      },
                    );
                  case 6:
                    return ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Log out'),
                      onTap: _logout, // Handle Logout
                    );
                  default:
                    return SizedBox
                        .shrink(); // Return an empty widget if none of the cases match
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
