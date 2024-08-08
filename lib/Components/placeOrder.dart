import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapper/Screens/myOrders.dart';

Future<void> placeOrder({
  required String uid,
  required List<Map<String, dynamic>> cart,
  required double subtotal,
  required double deliveryCharges,
  required double total,
  required LatLng deliveryCoordinates,
  required bool paymentDone,
  required DateTime selectedDate,
  required String selectedTime,
  required BuildContext context,
  required String? paymentMethod,
}) async {
  try {
    // Get a reference to the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get the current orders collection
    final ordersCollection = firestore.collection('orders');

    // Get the current order count
    final orderSnapshot = await ordersCollection.get();
    final orderCount = orderSnapshot.docs.length;

    // Create a new order number
    final orderNumber = 'Order #${orderCount + 1}';

    // Get the current date and time
    final now = DateTime.now();

    // Create the order data
    final orderData = {
      'orderNumber': orderNumber,
      'userId': uid,
      'cart': cart,
      'subtotal': subtotal,
      'deliveryCharges': deliveryCharges,
      'total': total,
      'deliveryCoordinates':
          GeoPoint(deliveryCoordinates.latitude, deliveryCoordinates.longitude),
      'paymentDone': paymentDone,
      'date': selectedDate,
      'time': selectedTime,
      'isOrderCompleted': false,
      'paymentMethod': paymentMethod,
      'isOrderConfirmed': false,
      'orderPicked': false,
      'timestamp': now,
    };

    // Save the order data to the Firestore orders collection
    final orderDoc = await ordersCollection.add(orderData);

    // Update the user document with the new order number
    final userDoc = firestore.collection('users').doc(uid);
    await userDoc.update({
      'orders': FieldValue.arrayUnion([orderNumber])
    });

    // Clear the user's cart
    await userDoc.update({
      'cart': [],
    });

    // Navigate to the My Orders screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyOrder(uid: uid),
      ),
    );
  } catch (e) {
    // Handle any errors that occur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error placing order: $e')),
    );
  }
}
