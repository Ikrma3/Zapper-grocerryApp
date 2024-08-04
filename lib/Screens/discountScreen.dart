import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';

class AddDiscountScreen extends StatefulWidget {
  @override
  _AddDiscountScreenState createState() => _AddDiscountScreenState();
}

class _AddDiscountScreenState extends State<AddDiscountScreen> {
  String? _selectedCategory;
  final TextEditingController _discountController = TextEditingController();
  List<String> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoriesSnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = categoriesSnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _applyDiscount() async {
    final discountStr = _discountController.text.trim();
    final discount = double.tryParse(discountStr) ?? 0;

    if (_selectedCategory == null || discount < 0 || discount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select a category and enter a valid discount percentage.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: _selectedCategory)
          .get();

      for (var doc in productsSnapshot.docs) {
        final productData = doc.data();
        final previousPrice =
            double.tryParse(productData['previousPrice'] ?? '0') ?? 0;
        final newPrice = double.tryParse(productData['newPrice'] ?? '0') ?? 0;

        double updatedNewPrice;
        double updatedPreviousPrice;

        if (discount > 0) {
          updatedNewPrice = newPrice * (1 - discount / 100);
          updatedPreviousPrice = newPrice;
        } else {
          updatedNewPrice = newPrice;
          updatedPreviousPrice = 0;
        }

        await doc.reference.update({
          'newPrice': updatedNewPrice.toStringAsFixed(2),
          'previousPrice': updatedPreviousPrice.toStringAsFixed(2),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discount applied successfully.')),
      );

      // Clear the input
      setState(() {
        _selectedCategory = null;
        _discountController.clear();
      });
    } catch (e) {
      print("Error applying discount: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying discount: $e')),
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
        title: Text('Add Discount',
            style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w600)),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text('Select a category',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category,
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      hintText: 'Enter discount percentage',
                      hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  SizedBox(height: 420.h),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _applyDiscount,
                          child: Text('Apply Discount',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: Size(double.infinity, 40.h),
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
