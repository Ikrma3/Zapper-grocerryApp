import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/productFrame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Screens/filterScreen.dart';
import 'package:zapper/Screens/productDetailsScreen.dart';
import 'package:zapper/Screens/searchScreen.dart';

class CategoryScreen extends StatefulWidget {
  final String initialCategoryId;
  final String userId; // Changed from userEmail to userId

  CategoryScreen({required this.initialCategoryId, required this.userId});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<DocumentSnapshot> categories = [];
  List<DocumentSnapshot> products = [];
  late String selectedCategoryId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.initialCategoryId;
    loadCategories();
  }

  void loadCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categories = querySnapshot.docs;
    });

    // After loading categories, scroll to the selected category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedCategory();
    });

    loadProducts(selectedCategoryId);
  }

  void loadProducts(String categoryId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryId)
        .get();
    setState(() {
      products = querySnapshot.docs;
    });
  }

  void _onSearchSubmitted(String searchText) {
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            productName: searchText,
            userId: widget.userId,
          ),
        ),
      );
    }
  }

  void scrollToSelectedCategory() {
    int selectedIndex =
        categories.indexWhere((category) => category.id == selectedCategoryId);
    if (selectedIndex != -1) {
      double position = selectedIndex *
          80.w; // Adjust 80.w based on your item width and padding
      _scrollController.animateTo(
        position,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          width: 253.w,
          height: 36.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Color.fromRGBO(242, 242, 242, 1)),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for fruits, vegetables... ',
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                ],
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FilterScreen(uid: widget.userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              fillColor: Colors.white,
            ),
            onSubmitted: _onSearchSubmitted,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Handle cart action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15.h,
          ),
          Container(
            height: 100.h,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                DocumentSnapshot category = categories[index];
                bool isSelected = category.id == selectedCategoryId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryId = category.id;
                      loadProducts(selectedCategoryId);
                      scrollToSelectedCategory();
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: isSelected
                                ? Border.all(color: Colors.green, width: 2)
                                : null,
                          ),
                          child: Image.network(
                            category['imageUrl'],
                            fit: BoxFit.cover,
                            width: 54.w,
                            height: 53.h,
                          ),
                        ),
                        Text(category['name']),
                        SizedBox(
                          height: 20.h,
                        ),
                        if (isSelected)
                          Container(
                            width: 60.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12.r),
                                    topLeft: Radius.circular(12.r)),
                                color: AppColors.primaryColor),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: (1.sw / 2.1) / (0.4.sh),
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot product = products[index];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
                    child: ProductFrame(
                      id: product.id,
                      userId: widget.userId, // Changed from userEmail to userId
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
                                  .userId, // Changed from userEmail to userId
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
