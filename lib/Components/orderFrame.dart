import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zapper/Screens/orderDetails.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Screens/orderSchedule.dart';

class OrdersFrame extends StatelessWidget {
  final Map<String, dynamic> order;
  final String uid;

  OrdersFrame({required this.order, required this.uid});

  @override
  Widget build(BuildContext context) {
    String title = order['orderNumber'];
    print(title);
    String subtitle;
    IconData icon;
    String imageUrl;
    if (order['isOrderConfirmed']) {
      subtitle = "Your Order is Completed.";
      imageUrl = 'images/delivered.png';
    } else if (order['isOrderCompleted']) {
      subtitle = "Your Order is Completed. Waiting for Confirmation";
      imageUrl = 'images/orderComplete.png';
    } else if (order['orderPicked']) {
      subtitle = "Your Order is Delivering to your home";
      imageUrl = 'images/picked.png';
    } else {
      subtitle = "Your Order is Being Processed";
      imageUrl = 'images/notConfirm.png';
    }

    var timestamp = order['timestamp'] as Timestamp;
    var orderTime = DateFormat('HH:mm').format(timestamp.toDate());

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 18.sp, fontWeight: FontWeight.w500, fontFamily: 'Poppin'),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.w500, fontFamily: 'Poppin'),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(orderTime),
          Image.asset(
            imageUrl,
            width: 30.w,
            height: 30.h,
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderScheduleDetail(
                uid: uid, orderNumber: order['orderNumber']),
          ),
        );
      },
    );
  }
}
