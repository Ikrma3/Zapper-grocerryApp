import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillCalculate extends StatefulWidget {
  final String uid;
  final Function(double, double, double) onBillCalculated;

  BillCalculate({required this.uid, required this.onBillCalculated});

  @override
  _BillCalculateState createState() => _BillCalculateState();
}

class _BillCalculateState extends State<BillCalculate> {
  double subtotal = 0.0;
  double deliveryCharges = 0.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    calculateBill();
  }

  Future<void> calculateBill() async {
    try {
      // Fetch user cart
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      List cart = userDoc['cart'];

      for (var item in cart) {
        String productId = item['productId'];
        int quantity = item['quantity'] is String
            ? int.parse(item['quantity'])
            : item['quantity'];

        // Fetch product price
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        double productPrice = productDoc['newPrice'] is String
            ? double.parse(productDoc['newPrice'])
            : productDoc['newPrice'].toDouble();

        subtotal += productPrice * quantity;
      }

      // Fetch delivery charges from the first document in the deliveryCharges collection
      QuerySnapshot deliveryChargesSnapshot = await FirebaseFirestore.instance
          .collection('deliveryCharges')
          .limit(1)
          .get();

      if (deliveryChargesSnapshot.docs.isNotEmpty) {
        var deliveryDoc = deliveryChargesSnapshot.docs.first;
        deliveryCharges = deliveryDoc['amount'] is String
            ? double.parse(deliveryDoc['amount'])
            : deliveryDoc['amount'].toDouble();
      } else {
        throw Exception("No delivery charges found");
      }

      total = subtotal + deliveryCharges;

      // Update UI
      setState(() {});

      // Send values to CartScreen
      widget.onBillCalculated(subtotal, deliveryCharges, total);
    } catch (e) {
      print('Error calculating bill: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          _buildRow('Subtotal', subtotal),
          _buildRow('Delivery Charges', deliveryCharges),
          _buildRow('Total', total),
        ],
      ),
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
