import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/productFrame.dart';
import 'package:zapper/Screens/productDetailsScreen.dart';

class SearchScreen extends StatefulWidget {
  final String productName;
  final String userId; // Changed from userEmail to userId

  SearchScreen({required this.productName, required this.userId});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    searchProducts();
  }

  void searchProducts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('Name', isGreaterThanOrEqualTo: widget.productName.toUpperCase())
        .where('Name',
            isLessThanOrEqualTo: widget.productName.toLowerCase() + '\uf8ff')
        .where('Name', isLessThanOrEqualTo: widget.productName + '\uf8ff')
        .get();

    setState(() {
      searchResults = querySnapshot.docs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: (1.sw / 2.1) / (0.4.sh),
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot product = searchResults[index];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
                    child: ProductFrame(
                      id: product.id,
                      userId: widget.userId, // Pass userId instead of userEmail
                      name: product['Name'],
                      imageUrls: List<String>.from(product['imageUrls']),
                      price: product['newPrice'],
                      previousPrice: product['previousPrice'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: product.id,
                              userId: widget
                                  .userId, // Pass userId instead of userEmail
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
