import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/productFrame.dart';
import 'package:zapper/Screens/productDetailsScreen.dart';

class FilterResult extends StatelessWidget {
  final String uid;
  final List<String> selectedCategories;
  final double? minPrice;
  final double? maxPrice;

  const FilterResult({
    Key? key,
    required this.uid,
    required this.selectedCategories,
    this.minPrice,
    this.maxPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Selected Categories: $selectedCategories');
    print('Min Price: $minPrice, Max Price: $maxPrice');

    Query query = FirebaseFirestore.instance.collection('products');

    // Apply category filter
    if (selectedCategories.isNotEmpty) {
      query = query.where('category', whereIn: selectedCategories);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Filter Results')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            var searchResults = snapshot.data!.docs;

            // Filter products based on price in the code
            if (minPrice != null || maxPrice != null) {
              searchResults = searchResults.where((doc) {
                double productPrice = double.tryParse(doc['newPrice']) ?? 0.0;
                bool matchesMinPrice =
                    minPrice != null ? productPrice >= minPrice! : true;
                bool matchesMaxPrice =
                    maxPrice != null ? productPrice <= maxPrice! : true;
                return matchesMinPrice && matchesMaxPrice;
              }).toList();
            }

            print('Search Results Length: ${searchResults.length}');
            if (searchResults.isEmpty) {
              return Center(child: Text('No products found.'));
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (1.sw / 2.1) / (0.4.sh),
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                DocumentSnapshot product = searchResults[index];
                print('Product Found: ${product['Name']}');

                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
                  child: ProductFrame(
                    id: product.id,
                    userId: uid,
                    name: product['Name'],
                    imageUrls: List<String>.from(product['imageUrls']),
                    price: double.parse(product['newPrice']).toString(),
                    previousPrice:
                        double.parse(product['previousPrice']).toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            productId: product.id,
                            userId: uid,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            print('Snapshot Error: ${snapshot.error}');
            return Center(child: Text('Error loading products.'));
          } else {
            return Center(child: Text('No products found.'));
          }
        },
      ),
    );
  }
}
