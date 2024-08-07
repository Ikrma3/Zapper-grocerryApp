import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zapper/Components/BottomBar.dart';
import 'package:zapper/Components/HomeBackground.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/homeCard.dart';
import 'package:zapper/Components/specialOffer.dart';
import 'package:zapper/Screens/categoriesScreen.dart';
import 'package:zapper/Screens/favouriteScreen.dart';
import 'package:zapper/Screens/profile.dart';
import 'package:zapper/Screens/searchScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? userEmail;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: widget.userId),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoritesScreen(userId: widget.userId),
          ),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 2:
        // Navigate to Cart screen
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: widget.userId),
          ),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }

  Future<String?> getUserEmailById() async {
    try {
      var userDoc =
          await firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['email'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user email: $e');
      return null;
    }
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

  Future<List<Map<String, dynamic>>> getSpecialOffers() async {
    var querySnapshot = await firestore
        .collection('products')
        .where('isSpecialOffer', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Fetch user email if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Row(
          children: [
            SizedBox(
              width: 100.w,
            ),
            Image.asset(
              'images/logo.png',
              width: 100.w,
              height: 30.h,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout action
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            HomeBackground(
              topColor: AppColors.primaryColor,
              bottomColor: AppColors.whiteColor,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10.w,
                      ),
                      Container(
                        width: 253.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.white),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white,
                          ),
                          onSubmitted: _onSearchSubmitted,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.mail_outlined,
                          color: Colors.white,
                          size: 26.w.h,
                        ),
                        onPressed: () {
                          // Handle notification icon press
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 26.w.h,
                        ),
                        onPressed: () {
                          // Handle shopping cart icon press
                        },
                      ),
                    ],
                  ),
                  FutureBuilder<String?>(
                    future: getUserEmailById(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text('Email not found'));
                      }
                      String? email = snapshot.data;
                      return FutureBuilder<DocumentSnapshot>(
                        future: firestore
                            .collection('users')
                            .doc(widget.userId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return Center(child: Text('Address not found'));
                          }
                          var userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0.w, vertical: 10.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.white,
                                ),
                                Container(
                                  width: 280.w,
                                  child: Text(
                                    'Sent to: ${userData['Address']}',
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Colors.white),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  FutureBuilder<QuerySnapshot>(
                    future: firestore
                        .collection('categories')
                        .where('discount', isGreaterThan: 0)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No discounted items'));
                      }
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Container(
                              height: 173.h,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var doc = snapshot.data!.docs[index];
                                  return HomeCard(
                                    id: doc.id,
                                    image: doc['discountImage'],
                                    discount: doc['discount'],
                                    name: doc['name'],
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              SmoothPageIndicator(
                                controller: _pageController,
                                count: snapshot.data!.docs.length,
                                effect: ExpandingDotsEffect(
                                  activeDotColor: AppColors.primaryColor,
                                  dotColor: Colors.grey,
                                  dotHeight: 8.0,
                                  dotWidth: 8.0,
                                  spacing: 4.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Categories', style: TextStyle(fontSize: 20)),
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future: firestore.collection('categories').limit(8).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No categories available'));
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(
                                    initialCategoryId: doc.id,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 61.w,
                                  height: 53.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(doc['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  doc['name'],
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to MoreScreen.dart
                      },
                      child: Text(
                        'More',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: AppColors.secondaryColor),
                      ),
                    ),
                  ),
                  Divider(thickness: 2.0),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getSpecialOffers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('No special offers available'));
                      }
                      return SpecialOffer(specialOffers: snapshot.data!);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -8,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: BottomBar(
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
