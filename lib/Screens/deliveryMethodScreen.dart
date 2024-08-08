import 'package:flutter/material.dart';

class DeliveryMethodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Cash on delivery'),
              leading: Icon(Icons.money),
              onTap: () {
                Navigator.pop(context, 'Cash on delivery');
              },
            ),
            ListTile(
              title: Text('Online Payment'),
              leading: Icon(Icons.credit_card),
              onTap: () {
                Navigator.pop(context, 'Online Payment');
              },
            ),
          ],
        ),
      ),
    );
  }
}
