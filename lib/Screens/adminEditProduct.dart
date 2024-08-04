import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zapper/Components/adminEditFrame.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/editComponent.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String? _selectedCategory;
  List<String> _categories = [];
  List<Map<String, dynamic>> _products = [];
  List<String> _productIds = []; // To store document IDs

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

  Future<void> _loadProducts(String category) async {
    final productsSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .get();
    setState(() {
      _products = productsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _productIds = productsSnapshot.docs
          .map((doc) => doc.id)
          .toList(); // Get document IDs
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Products',
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
            padding: EdgeInsets.all(8.0.w.h),
            child: Column(
              children: [
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = _categories[index];
                            _loadProducts(_selectedCategory!);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          alignment: Alignment.center,
                          child: Chip(
                            label: Text(
                              _categories[index],
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            backgroundColor:
                                _selectedCategory == _categories[index]
                                    ? Color.fromARGB(255, 253, 150, 71)
                                    : AppColors.greyColor,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _selectedCategory == null
                      ? Center(child: Text('Select a category'))
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final productId =
                                _productIds[index]; // Get document ID
                            return AdminProductFrame(
                              imageUrl: product['imageUrls']?.isNotEmpty == true
                                  ? product['imageUrls'][0]
                                  : 'default_image_url',
                              name: product['Name'] ?? 'Unnamed Product',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditComponentScreen(
                                      productId: productId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
