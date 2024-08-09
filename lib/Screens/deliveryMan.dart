import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class DeliveryMan extends StatelessWidget {
  final String orderNumber;

  DeliveryMan({required this.orderNumber});

  Future<Map<String, dynamic>?> _fetchDeliveryManDetails() async {
    try {
      var orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderNumber', isEqualTo: orderNumber)
          .get();
      if (orderSnapshot.docs.isNotEmpty) {
        var orderData = orderSnapshot.docs.first.data();
        if (orderData['orderPicked'] == true) {
          return {
            'name': orderData['deliveryManName'],
            'contact': orderData['deliveryManContact'],
            'image': orderData['deliveryManImage'],
          };
        }
      }
    } catch (e) {
      print("Error fetching delivery man details: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchDeliveryManDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          var deliveryManData = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(deliveryManData['image']),
                    radius: 25.r,
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deliveryManData['name'],
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        deliveryManData['contact'],
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.phone, color: AppColors.darkSecondaryColor),
                ],
              ),
            ],
          );
        } else {
          return Text(
            "Order is not picked yet.",
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter'),
          );
        }
      },
    );
  }
}
