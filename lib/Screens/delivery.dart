import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/buttonWithIcon.dart';
import 'package:zapper/Components/colours.dart';
import 'package:intl/intl.dart';

class DeliveryScreen extends StatefulWidget {
  final String orderNumber;

  DeliveryScreen({required this.orderNumber});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Map<String, dynamic>? orderData;
  String estimatedTime = '';

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  void fetchOrderData() async {
    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('orderNumber', isEqualTo: widget.orderNumber)
        .get();

    if (orderSnapshot.docs.isNotEmpty) {
      setState(() {
        orderData = orderSnapshot.docs.first.data();
        _setEstimatedTime();
      });
    }
  }

  void _setEstimatedTime() {
    if (orderData != null) {
      if (orderData!['isOrderCompleted'] == true) {
        estimatedTime = orderData!['deliveredAt'] ?? '';
      } else {
        estimatedTime = orderData!['time'] ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.blueGrey.shade100,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blueGrey.shade100,
        elevation: 0,
        title: Text('Delivery Details', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 130.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade100,
                  Colors.white.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // White background for content
          Container(
            margin: EdgeInsets.only(top: 130.h),
            color: Colors.white,
          ),
          // Content
          orderData == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: DeliveryDetailsWidget(
                    orderData: orderData!,
                    estimatedTime: estimatedTime,
                  ),
                ),
        ],
      ),
    );
  }
}

class DeliveryDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String estimatedTime;
  DeliveryDetailsWidget({required this.orderData, required this.estimatedTime});

  @override
  Widget build(BuildContext context) {
    bool isOrderConfirmed = orderData['isOrderConfirmed'] ?? false;
    bool isOrderCompleted = orderData['isOrderCompleted'] ?? false;
    bool orderPicked = orderData['orderPicked'] ?? false;
    DateTime confirmTimer =
        orderData['confirmTime']?.toDate() ?? DateTime.now();
    DateTime deliverdAts = orderData['deliverdAt']?.toDate() ?? DateTime.now();
    DateTime orderPickTimer =
        orderData['orderPickTime']?.toDate() ?? DateTime.now();
    DateTime receivedTimer =
        orderData['receivedTime']?.toDate() ?? DateTime.now();

    String confirmTime = DateFormat('MMMM d, yyyy HH:mm').format(confirmTimer);
    String deliverdAt = DateFormat('MMMM d, yyyy HH:mm').format(deliverdAts);
    String orderPickTime =
        DateFormat('MMMM d, yyyy HH:mm').format(orderPickTimer);
    String receivedTime =
        DateFormat('MMMM d, yyyy HH:mm').format(receivedTimer);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          // Dotted line
          Positioned(
            top: 180, // Adjust this value to move the dotted line lower
            left: 14,
            child: CustomPaint(
              size: Size(2, 350), // Adjust the height to limit the dotted line
              painter: DottedLinePainter(color: Colors.grey),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    "Delivery time",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter'),
                  ),
                  Spacer(),
                  Text(
                    estimatedTime,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppin',
                        color: AppColors.secondaryColor),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20.w),
                      SizedBox(width: 10.w),
                      Text(
                        DateFormat('MMMM d, yyyy').format(
                          orderData!['timestamp'].toDate(),
                        ),
                        style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 50.h,
              ),
              buildStatusRow(
                  text: isOrderConfirmed
                      ? "Order Confirmed"
                      : "Waiting for Confirmation",
                  timestamp: confirmTime,
                  isCompleted: isOrderConfirmed,
                  color: isOrderConfirmed
                      ? Color.fromRGBO(54, 179, 126, 0.14)
                      : Color.fromRGBO(55, 71, 79, 0.14)),
              buildStatusRow(
                  text: isOrderCompleted
                      ? "Order Delivered at Home"
                      : orderPicked
                          ? "Order Picked"
                          : "Order Will Pick Soon",
                  timestamp: isOrderCompleted ? deliverdAt : orderPickTime,
                  isCompleted: isOrderCompleted || orderPicked,
                  color: isOrderCompleted || orderPicked
                      ? Color.fromRGBO(54, 179, 126, 0.14)
                      : Color.fromRGBO(55, 71, 79, 0.14)),
              buildStatusRow(
                  text: "Your order is confirmed",
                  timestamp: confirmTime,
                  isCompleted: true,
                  color: Color.fromRGBO(243, 122, 32, 0.14)),
              buildStatusRow(
                  text: "Your order is received",
                  timestamp: receivedTime,
                  isCompleted: true,
                  color: Color.fromRGBO(243, 122, 32, 0.14)),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: ButtonWithIcon(
                  color: AppColors.darkSecondaryColor,
                  borderColor: AppColors.whiteColor,
                  imagePath: 'images/support.png',
                  text: 'Contact with Support',
                  textColor: AppColors.whiteColor,
                  height: 40.h,
                  onPressed: () {
                    // Handle register as delivery person press
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatusRow({
    required String text,
    required String timestamp,
    required bool isCompleted,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tick mark
        Column(
          children: [
            SizedBox(height: 8), // Adjust this value to move the tick lower
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? Colors.white
                      : const Color.fromARGB(
                          122, 0, 0, 0), // Set border color based on condition
                  width: 1.w, // Adjust the border width as needed
                ),
              ),
              child: Icon(
                Icons.check_circle,
                color: isCompleted ? AppColors.primaryColor : Colors.white,
                size: 18.w.h, // Adjust the icon size as needed
              ),
            ),
          ],
        ),
        SizedBox(width: 10),
        // Container with status text and timestamp
        Container(
          height: 85.h,
          width: 280.w,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppin')),
              SizedBox(height: 4),
              Text(timestamp,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppin')),
            ],
          ),
        ),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 4, dashSpace = 4, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
