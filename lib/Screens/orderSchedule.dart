import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zapper/Components/buttonWithIcon.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Screens/delivery.dart';
import 'package:zapper/Screens/deliveryLocationStatic.dart';
import 'package:zapper/Screens/deliveryMan.dart';

class OrderScheduleDetail extends StatefulWidget {
  final String uid;
  final String orderNumber;

  OrderScheduleDetail({required this.uid, required this.orderNumber});

  @override
  _OrderScheduleDetailState createState() => _OrderScheduleDetailState();
}

class _OrderScheduleDetailState extends State<OrderScheduleDetail> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String estimatedTime = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      var orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderNumber', isEqualTo: widget.orderNumber)
          .get();
      if (orderSnapshot.docs.isNotEmpty) {
        setState(() {
          orderData = orderSnapshot.docs.first.data();
          _setEstimatedTime();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching order details: $e");
      setState(() {
        isLoading = false;
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
        title: Text('${widget.orderNumber}',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: 100.h,
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
                Container(
                  margin: EdgeInsets.only(top: 100.h),
                  color: Colors.white,
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Estimated Delivery",
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
                            SizedBox(height: 5.h),
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
                            SizedBox(height: 20.h),
                            _buildProgressIndicator(),
                            SizedBox(height: 20.h),
                            Text(
                              orderData!['isOrderConfirmed'] == false
                                  ? "We are on the way"
                                  : "Order Confirmed",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter',
                                  color: Color.fromRGBO(119, 119, 119, 1)),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                foregroundColor: AppColors.primaryColor,
                                backgroundColor:
                                    Colors.cyan.shade50.withOpacity(1),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                minimumSize: Size(340.w, 48.h),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeliveryScreen(
                                      orderNumber: widget.orderNumber,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Show Delivery Details',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter'),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                foregroundColor: AppColors.primaryColor,
                                backgroundColor:
                                    Colors.cyan.shade50.withOpacity(1),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                minimumSize: Size(340.w, 48.h),
                              ),
                              onPressed: () {},
                              child: Text(
                                'Show Package Details',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter'),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Text(
                              "Delivery Man",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            DeliveryMan(orderNumber: widget.orderNumber),
                            SizedBox(
                              height: 20.h,
                            ),
                            Text(
                              "Delivery Location",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: GestureDetector(
                                onTap: () {
                                  if (orderData != null &&
                                      orderData!['deliveryCoordinates'] !=
                                          null) {
                                    GeoPoint coordinates =
                                        orderData!['deliveryCoordinates'];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DeliveryLocationStatic(
                                          coordinates: LatLng(
                                              coordinates.latitude,
                                              coordinates.longitude),
                                          address:
                                              orderData!['deliveryAddress'] ??
                                                  'No address available',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'images/location_pin.png',
                                        width: 40.w,
                                        height: 40.h,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          orderData != null
                                              ? orderData!['deliveryAddress'] ??
                                                  'No address available'
                                              : 'No address available',
                                          style: TextStyle(fontSize: 16.sp),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
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
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Container(
                          child: Column(
                            children: [
                              _buildRow('Subtotal', orderData!['subtotal']),
                              _buildRow('Delivery Charges',
                                  orderData!['deliveryCharges']),
                              _buildRow('Total', orderData!['total']),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                          ),
                          Text('Payment Method'),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        child: Container(
                          height: 85.h,
                          width: 342.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Color.fromRGBO(54, 179, 126, 0.14)),
                          child: Padding(
                            padding: EdgeInsets.all(8.w.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'images/payment.png',
                                  width: 40.w,
                                  height: 40.h,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "You selected",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Inter',
                                          color:
                                              Color.fromRGBO(55, 71, 79, 0.72)),
                                    ),
                                    Text(orderData!['paymentMethod'],
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Inter'))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'Cash on derivery has some potential risks of spreading contamination. You can select other payment methods for a contactless safe delivery.',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter'),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
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
                      orderData!['isOrderConfirmed'] != true
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: ButtonWithIcon(
                                color: AppColors.primaryColor,
                                borderColor: AppColors.whiteColor,
                                imagePath: 'images/tick.png',
                                text: 'Confrim Delivery',
                                textColor: AppColors.whiteColor,
                                height: 40.h,
                                onPressed: () async {
                                  try {
                                    // Query the document with the specific orderNumber
                                    var orderSnapshot = await FirebaseFirestore
                                        .instance
                                        .collection('orders')
                                        .where('orderNumber',
                                            isEqualTo: widget.orderNumber)
                                        .get();

                                    if (orderSnapshot.docs.isNotEmpty) {
                                      var orderDoc = orderSnapshot.docs.first;

                                      // Update the document
                                      await orderDoc.reference.update({
                                        'isOrderConfirmed': true,
                                        'confirmTime': Timestamp
                                            .now(), // Store the current timestamp
                                      });

                                      // Provide feedback to the user (optional)
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Delivery Confirmed')),
                                      );

                                      // Optionally, refresh the order details to reflect the changes
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await _fetchOrderDetails();
                                    } else {
                                      // Handle the case where the document is not found
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Order not found')),
                                      );
                                    }
                                  } catch (e) {
                                    print("Error updating order: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to confirm delivery')),
                                    );
                                  }
                                },
                              ),
                            )
                          : SizedBox(
                              height: 10.h,
                            )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressIndicator() {
    int completedSteps = 2;

    if (orderData!['isOrderCompleted'] == true) {
      completedSteps = 4;
    } else if (orderData!['orderPicked'] == true) {
      completedSteps = 3;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 1.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            color: index < completedSteps ? Colors.green : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16.0)),
          Text('\$${value.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }
}
