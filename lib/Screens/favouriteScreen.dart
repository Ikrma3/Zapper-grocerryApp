import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zapper/Components/productFrame.dart';
import 'package:zapper/Screens/productDetailsScreen.dart';

class FavoritesScreen extends StatefulWidget {
  final String userId;

  FavoritesScreen({required this.userId});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<DocumentSnapshot> favoriteProducts = [];
  bool isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmailAndFavorites();
  }

  Future<void> _loadUserEmailAndFavorites() async {
    try {
      // Fetch user data from Firestore using UID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userEmail = userDoc.data()?['email'];
        });

        List<dynamic> favoriteIds = userDoc.data()?['favourites'] ?? [];

        if (favoriteIds.isNotEmpty) {
          // Fetch favorite products
          final productQuery = FirebaseFirestore.instance
              .collection('products')
              .where(FieldPath.documentId, whereIn: favoriteIds);
          final productSnapshot = await productQuery.get();

          setState(() {
            favoriteProducts = productSnapshot.docs;
            isLoading = false;
          });
        } else {
          setState(() {
            favoriteProducts = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          favoriteProducts = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorite products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteProducts.isEmpty
              ? Center(child: Text('No favorites found.'))
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot product = favoriteProducts[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: ProductFrame(
                          userId: widget.userId,
                          id: product.id,
                          // Use userEmail if needed
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
                                      .userId, // Pass UID to ProductDetailScreen
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
