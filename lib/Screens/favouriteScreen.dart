import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zapper/Components/productFrame.dart';
import 'package:zapper/Screens/productDetailsScreen.dart';

class FavoritesScreen extends StatefulWidget {
  final String userEmail;

  FavoritesScreen({required this.userEmail});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<DocumentSnapshot> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      final userQuery = FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail);
      final userSnapshot = await userQuery.get();

      if (userSnapshot.docs.isNotEmpty) {
        final userDoc = userSnapshot.docs.first;
        List<dynamic> favoriteIds = userDoc.data()['favourites'] ?? [];

        if (favoriteIds.isNotEmpty) {
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
