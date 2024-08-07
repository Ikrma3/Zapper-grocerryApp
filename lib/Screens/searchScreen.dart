import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapper/Components/productFrame.dart';
import 'package:zapper/Screens/productDetailsScreen.dart';

class SearchScreen extends StatefulWidget {
  final String productName;
  final String userEmail;

  SearchScreen({required this.productName, required this.userEmail});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false; // Add this line

  @override
  void initState() {
    super.initState();
    searchProducts();
  }

  void searchProducts() async {
    setState(() {
      isLoading = true; // Show loading indicator
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
      isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3.1,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot product = searchResults[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: ProductFrame(
                      id: product.id,
                      userEmail: widget.userEmail,
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
                              userEmail: widget.userEmail,
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
