import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryLocationStatic extends StatelessWidget {
  final LatLng coordinates;
  final String address;

  DeliveryLocationStatic({required this.coordinates, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Location'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300.h,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: coordinates,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('delivery_location'),
                  position: coordinates,
                ),
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              address,
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}
