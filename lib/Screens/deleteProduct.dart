import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zapper/Components/adminEditFrame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';

class DeleteProductScreen extends StatefulWidget {
  @override
  _DeleteProductScreenState createState() => _DeleteProductScreenState();
}

class _DeleteProductScreenState extends State<DeleteProductScreen> {
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

  Future<void> _showDeleteConfirmationDialog(String productId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Do you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteProduct(productId); // Proceed with deletion
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully.')),
      );
      // Refresh the product list
      if (_selectedCategory != null) {
        await _loadProducts(_selectedCategory!);
      }
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Products',
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
            padding: EdgeInsets.all(8.0.w.h),
            child: Column(
              children: [
                Container(
                  height: 60.h,
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
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Chip(
                            label: Text(_categories[index],
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
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
                      ? Center(
                          child: Text('Select a category',
                              style: TextStyle(
                                  fontSize: 28.sp,
                                  fontFamily: 'Poppin',
                                  color: AppColors.secondaryColor,
                                  fontWeight: FontWeight.w600)))
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
                                _showDeleteConfirmationDialog(productId);
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
