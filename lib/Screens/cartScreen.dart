import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapper/Components/billCalculate.dart';
import 'package:zapper/Components/cartFrame.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/placeOrder.dart';
import 'package:zapper/Screens/deliveryMethodScreen.dart';
import 'package:zapper/Screens/home.dart';
import 'package:zapper/Components/dateTimeDelivery.dart';
import 'package:zapper/Components/deliveryLocation.dart';

class CartScreen extends StatefulWidget {
  final String uid;

  CartScreen({required this.uid});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double subtotal = 0.0;
  double deliveryCharges = 0.0;
  double total = 0.0;
  late DocumentSnapshot userDoc;
  bool isLoading = true;
  List<Map<String, dynamic>> cart = [];
  DateTime? selectedDate;
  String? selectedTime;
  LatLng? deliveryCoordinates;
  String? deliveryAddress;
  bool paymentDone = false;
  String? paymentMethod;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    setState(() {
      cart = List<Map<String, dynamic>>.from(userDoc['cart']);
      isLoading = false;
    });
  }

  void updateQuantity(String productId, int quantity) {
    setState(() {
      int index = cart.indexWhere((item) => item['productId'] == productId);
      if (index != -1) {
        if (quantity > 0) {
          cart[index]['quantity'] = quantity;
        } else {
          cart.removeAt(index);
        }
      }
    });

    // Update Firestore
    userDoc.reference.update({'cart': cart});
  }

  void updateDeliveryLocation(LatLng coordinates, String Address) {
    setState(() {
      deliveryCoordinates = coordinates;
      deliveryAddress = Address;
    });
    print('Selected Delivery Location: $deliveryCoordinates');
  }

  void _navigateToDeliveryMethod() async {
    final selectedPaymentMethod = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryMethodScreen(),
      ),
    );

    if (selectedPaymentMethod != null) {
      setState(() {
        paymentMethod = selectedPaymentMethod;
      });
      print('Selected Payment Method: $selectedPaymentMethod');
    }
  }

  void _placeOrder() {
    if (paymentMethod == null && deliveryCoordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method and address')),
      );
      return;
    }

    placeOrder(
        uid: widget.uid,
        cart: cart,
        subtotal: subtotal,
        deliveryCharges: deliveryCharges,
        total: total,
        deliveryCoordinates: deliveryCoordinates!,
        deliveryAddress: deliveryAddress!,
        paymentDone: paymentDone,
        selectedDate: selectedDate!,
        selectedTime: selectedTime!,
        context: context,
        paymentMethod: paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cart.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: widget.uid),
                  ),
                );
              },
            ),
          ),
          body: Center(child: Text('You have nothing in cart')));
    }

    return Scaffold(
        body: Stack(children: [
      Container(
        height: 290.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade100, Colors.white.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 290.h),
        color: Colors.white,
      ),
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 80.h,
              child: AppBar(
                title: Text('My Bag'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.h),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  var item = cart[index];
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('products')
                        .doc(item['productId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      var product = snapshot.data;
                      return Column(
                        children: [
                          CartFrame(
                            imageUrl: List<String>.from(product?['imageUrls']),
                            productName: product?['Name'],
                            quantity: item['quantity'],
                            previousPrice: product?['previousPrice'],
                            price: product?['newPrice'],
                            onAdd: () {
                              updateQuantity(
                                  item['productId'], item['quantity'] + 1);
                            },
                            onRemove: () {
                              updateQuantity(
                                  item['productId'], item['quantity'] - 1);
                            },
                          ),
                          Divider(
                            color: Color.fromRGBO(240, 240, 240, 1),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: AppColors.primaryColor,
                backgroundColor: Colors.cyan.shade50.withOpacity(1),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: Size(340.w, 48.h),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: widget.uid),
                  ),
                );
              },
              child: Text(
                'Add More Product',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter'),
              ),
            ),
            SizedBox(height: 40.h),
            DateTimeDelivery(
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
              onTimeSelected: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
            SizedBox(height: 20.h),
            DeliveryLocation(
              uid: widget.uid,
              onLocationUpdated: updateDeliveryLocation,
            ),
            SizedBox(height: 20.h),
            BillCalculate(
              uid: widget.uid,
              onBillCalculated: (sub, delivery, tot) {
                setState(() {
                  subtotal = sub;
                  deliveryCharges = delivery;
                  total = tot;
                });

                print("Subtotal: $subtotal");
                print("Delivery Charges: $deliveryCharges");
                print("Total: $total");
              },
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: _navigateToDeliveryMethod,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.w.h),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Color.fromRGBO(54, 179, 126, 0.14)),
                    width: 340.w,
                    height: 85.h,
                    child: Padding(
                      padding: EdgeInsets.all(4.w.h),
                      child: Row(
                        children: [
                          Image.asset(
                            'images/payment.png',
                            width: 40.w,
                            height: 40.h,
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            'Tap Here to select your\n Payment Method',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppin'),
                            maxLines: 3,
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 24.sp),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _placeOrder,
              child: Text('Place Order'),
            ),
          ],
        ),
      ),
    ]));
  }
}
