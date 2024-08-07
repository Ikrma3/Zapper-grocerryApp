import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String userId; // Changed from userEmail to userId

  ProductDetailScreen({required this.productId, required this.userId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  DocumentSnapshot? product;
  int quantity = 1;
  bool isDescriptionSelected = true;

  @override
  void initState() {
    super.initState();
    loadProductDetails();
  }

  void loadProductDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    setState(() {
      product = doc;
    });
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      // Fetch user document using UID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        // Get the existing cart or initialize it as an empty list
        List<dynamic> cart = userDoc.data()?['cart'] ?? [];

        // Add the new product to the cart
        cart.add({'productId': productId, 'quantity': quantity});

        // Update the user document with the new cart
        await userDoc.reference.update({'cart': cart});
      } else {
        print('No user found with UID: ${widget.userId}');
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Image.network(
              product!['imageUrls'][0],
              fit: BoxFit.cover,
            ),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
          ),
          // Content Container
          Positioned(
            top: 250.h, // Adjust based on your design
            left: 0,
            right: 0,
            child: Container(
              height: 508.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Color.fromRGBO(76, 173, 115, 0.2)),
                      child: Padding(
                        padding: EdgeInsets.all(3.w.h),
                        child: Text(
                          product!['category'],
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                              fontFamily: 'Inter'),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product!['Name'],
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter'),
                    ),
                    Row(
                      children: [
                        Text(
                          'Rp ${product!['newPrice']}',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: AppColors.primaryColor),
                        ),
                        SizedBox(width: 8),
                        if (product!['previousPrice'] != "0")
                          Text(
                            'Rp ${product!['previousPrice']}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Inter',
                              color: AppColors.greyColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDescriptionSelected = true;
                            });
                          },
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60.w,
                                  ),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Inter',
                                        color: isDescriptionSelected
                                            ? AppColors.primaryColor
                                            : Colors.black),
                                  ),
                                ],
                              ),
                              if (isDescriptionSelected)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 60.w,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      height: 3.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.r),
                                            topRight: Radius.circular(12.r)),
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDescriptionSelected = false;
                            });
                          },
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60.w,
                                  ),
                                  Text(
                                    'Nutrition Facts',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: isDescriptionSelected
                                            ? Colors.black
                                            : AppColors.primaryColor,
                                        fontSize: 12.sp),
                                  ),
                                ],
                              ),
                              if (!isDescriptionSelected)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 60.w,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      height: 3.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.r),
                                            topRight: Radius.circular(12.r)),
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      isDescriptionSelected
                          ? product!['description']
                          : product!['nutritionFact'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Related Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    RelatedProductsFrame(
                      currentProductId: product!.id,
                      categoryId: product!['category'],
                      onProductTap: (productId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: productId,
                              userId: widget.userId, // Pass UID
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 92.h,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                        0, 0, 0, 0.07), // Shadow color with opacity
                    offset: Offset(0, 3), // Horizontal and vertical offset
                    blurRadius: 5.0,
                    spreadRadius: 3, // Blur radius
                  ),
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.w,
                  ),
                  Container(
                    height: 32.h,
                    width: 34.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 50.h,
                    width: 50.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Color.fromRGBO(248, 192, 165, 1)),
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Container(
                    height: 32.h,
                    width: 34.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${quantity} Added to Cart"),
                          duration: Duration(
                              seconds:
                                  2), // Optional: specify how long the SnackBar should be displayed
                        ),
                      );
                      addToCart(widget.productId, quantity);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.secondaryColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      minimumSize: Size(140.w, 45.h),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RelatedProductsFrame extends StatelessWidget {
  final String currentProductId;
  final String categoryId;
  final Function(String) onProductTap;

  RelatedProductsFrame({
    required this.currentProductId,
    required this.categoryId,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: categoryId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> relatedProducts = snapshot.data!.docs
            .where((doc) => doc.id != currentProductId)
            .toList();
        return Container(
          height: 63.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              var product = relatedProducts[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  height: 63.h,
                  width: 206.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.07),
                        offset: Offset(0, 3),
                        blurRadius: 5.0,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => onProductTap(product.id),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          product['imageUrls'][0],
                          height: 63.h,
                          width: 84.w,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product['Name'],
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter'),
                            ),
                            Text(
                              'Rp ${product['newPrice']}',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
