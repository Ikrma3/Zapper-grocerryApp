import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/orderFrame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyOrder extends StatefulWidget {
  final String uid;

  MyOrder({required this.uid});

  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  late String email;
  List<Map<String, dynamic>> ongoingOrders = [];
  List<Map<String, dynamic>> historyOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchEmailAndOrders();
  }

  Future<void> _fetchEmailAndOrders() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      email = userDoc['email'];

      for (String orderNumber in userDoc['orders']) {
        var orderQuerySnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('orderNumber', isEqualTo: orderNumber)
            .get();

        for (var doc in orderQuerySnapshot.docs) {
          var orderData = doc.data();
          if (orderData['isOrderCompleted'] == false) {
            ongoingOrders.add(orderData);
          } else {
            historyOrders.add(orderData);
          }
        }
      }
      setState(() {});
    } catch (e) {
      print("Error fetching user or orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 290.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade100,
                  Colors.white.withOpacity(0.6)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 290.h),
            color: Colors.white,
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('Orders', style: TextStyle(color: Colors.black)),
                centerTitle: true,
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Ongoing'),
                          Tab(text: 'History'),
                        ],
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppin',
                        ),
                        indicatorColor: AppColors.primaryColor,
                        labelColor: AppColors.primaryColor,
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: TabBarView(
                          children: [
                            ongoingOrders.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset('images/orders.png'),
                                          Text(
                                            'There is no ongoing order right now.\nYou can order from home.',
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: ongoingOrders.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          OrdersFrame(
                                              order: ongoingOrders[index],
                                              uid: widget.uid),
                                          Divider()
                                        ],
                                      );
                                    },
                                  ),
                            historyOrders.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset('images/orders.png'),
                                          Text(
                                              'There is no order history right now.'),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: historyOrders.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          OrdersFrame(
                                              order: historyOrders[index],
                                              uid: widget.uid),
                                          Divider()
                                        ],
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
