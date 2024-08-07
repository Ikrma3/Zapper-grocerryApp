import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class ProductFrame extends StatefulWidget {
  final String id;
  final String name;
  final List<dynamic> imageUrls;
  final String price;
  final String previousPrice;
  final VoidCallback onTap;
  final String userEmail;

  ProductFrame({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.price,
    required this.previousPrice,
    required this.onTap,
    required this.userEmail,
  });

  @override
  State<ProductFrame> createState() => _ProductFrameState();
}

class _ProductFrameState extends State<ProductFrame> {
  int quantity = 1;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final userQuery = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.userEmail);
    final querySnapshot = await userQuery.get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      List<dynamic> favorites = userDoc.data()['favourites'] ?? [];

      setState(() {
        isFavorite = favorites.contains(widget.id);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userQuery = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.userEmail);
    final querySnapshot = await userQuery.get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      List<dynamic> favorites = userDoc.data()['favourites'] ?? [];

      if (isFavorite) {
        favorites.remove(widget.id);
      } else {
        favorites.add(widget.id);
      }

      setState(() {
        isFavorite = !isFavorite;
      });

      await userDoc.reference.update({'favourites': favorites});
    } else {
      // Handle the case where no user with the given email is found
      print('No user found with email: ${widget.userEmail}');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    final userQuery = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.userEmail);

    final querySnapshot = await userQuery.get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;

      List<dynamic> cart = userDoc.data()['cart'] ?? [];

      cart.add({'productId': productId, 'quantity': quantity});

      await userDoc.reference.update({'cart': cart});
    } else {
      // Handle the case where no user with the given email is found
      print('No user found with email: ${widget.userEmail}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        shadowColor: Color.fromRGBO(0, 0, 0, 1),
        elevation: 2,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: Image.network(
                    widget.imageUrls[0],
                    fit: BoxFit.cover,
                    height: 128.h,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    children: [
                      Text(
                        'Rp ${widget.price}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.previousPrice != "0")
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Text(
                      'Rp ${widget.previousPrice}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 28.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${quantity} Added to Cart"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            addToCart(widget.id, quantity);
                          },
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_box_outlined,
                          color: AppColors.primaryColor,
                          size: 20.w.h,
                        ),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.green : Colors.grey,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
