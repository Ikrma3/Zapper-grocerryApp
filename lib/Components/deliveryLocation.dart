import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/mapScreen.dart';

class DeliveryLocation extends StatefulWidget {
  final String uid;
  final Function(LatLng, String) onLocationUpdated;

  DeliveryLocation({required this.uid, required this.onLocationUpdated});

  @override
  _DeliveryLocationState createState() => _DeliveryLocationState();
}

class _DeliveryLocationState extends State<DeliveryLocation> {
  String userAddress = '';
  LatLng userCoordinates = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  void fetchUserAddress() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userAddress = userDoc['Address'] ?? '';
          double latitude = userDoc['latitude']?.toDouble() ?? 0.0;
          double longitude = userDoc['longitude']?.toDouble() ?? 0.0;
          userCoordinates = LatLng(latitude, longitude);
        });
        // Send coordinates after fetching the user address
        widget.onLocationUpdated(userCoordinates, userAddress);
      }
    } catch (e) {
      print('Error fetching user address: $e');
    }
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
              userCoordinates = coordinates;
            });
            widget.onLocationUpdated(userCoordinates, userAddress);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        userAddress = result['address'];
        userCoordinates = result['coordinates'];
      });
      widget.onLocationUpdated(userCoordinates, userAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Location',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppin',
                ),
              ),
              TextButton(
                onPressed: _openMapScreen,
                child: Text(
                  'Change',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppin',
                      color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Image.asset(
                'images/location_pin.png',
                width: 40.w,
                height: 40.h,
              ),
              SizedBox(
                width: 4.w,
              ),
              Container(
                width: 260.w,
                child: Text(
                  userAddress.isNotEmpty ? userAddress : 'No address available',
                  style: TextStyle(fontSize: 16.sp),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
