import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';

class EditComponentScreen extends StatefulWidget {
  final String productId;

  EditComponentScreen({required this.productId});

  @override
  _EditComponentScreenState createState() => _EditComponentScreenState();
}

class _EditComponentScreenState extends State<EditComponentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController();
  final TextEditingController _previousPriceController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nutritionFactController =
      TextEditingController();
  bool _isSpecialOffer = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        setState(() {
          _nameController.text = productData['Name'] ?? '';
          _newPriceController.text = productData['newPrice'] ?? '';
          _previousPriceController.text = productData['previousPrice'] ?? '';
          _descriptionController.text = productData['description'] ?? '';
          _nutritionFactController.text = productData['nutritionFact'] ?? '';
          _isSpecialOffer = productData['isSpecialOffer'] ?? false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found.')),
        );
      }
    } catch (e) {
      print("Error loading product details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product details: $e')),
      );
    }
  }

  Future<void> _updateProduct() async {
    final name = _nameController.text.trim();
    final newPrice = _newPriceController.text.trim();
    final previousPrice = _previousPriceController.text.trim();
    final description = _descriptionController.text.trim();
    final nutritionFact = _nutritionFactController.text.trim();

    if (name.isEmpty ||
        newPrice.isEmpty ||
        previousPrice.isEmpty ||
        description.isEmpty ||
        nutritionFact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'Name': name,
        'newPrice': newPrice,
        'previousPrice': previousPrice,
        'description': description,
        'nutritionFact': nutritionFact,
        'isSpecialOffer': _isSpecialOffer,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error updating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Product',
          style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: Stack(children: [
          Background(
            topColor: AppColors.primaryColor,
            bottomColor: AppColors.whiteColor,
            // Adjust this value as needed
          ),
          Padding(
            padding: EdgeInsets.all(20.0.w.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _newPriceController,
                    decoration: InputDecoration(
                      hintText: 'New Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _previousPriceController,
                    decoration: InputDecoration(
                      hintText: 'Previous Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _nutritionFactController,
                    decoration: InputDecoration(
                      hintText: 'Nutrition Facts',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Checkbox(
                        value: _isSpecialOffer,
                        onChanged: (value) {
                          setState(() {
                            _isSpecialOffer = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'Special Offer',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'Inter',
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _updateProduct,
                          child: Text(
                            'Update',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: Size(double.infinity, 40),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
