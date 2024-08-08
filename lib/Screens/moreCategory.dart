import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/moreCategoryFrame.dart';
import 'package:zapper/Screens/categoriesScreen.dart';

class MoreCategoryScreen extends StatefulWidget {
  final String userId;

  const MoreCategoryScreen({required this.userId});

  @override
  _MoreCategoryScreenState createState() => _MoreCategoryScreenState();
}

class _MoreCategoryScreenState extends State<MoreCategoryScreen> {
  String? selectedCategoryId;

  Future<List<DocumentSnapshot>> _fetchCategories() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 290.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade100,
                  Colors.white.withOpacity(0.6)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 290.h),
            color: Colors.white,
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('Categories',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter')),
                actions: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        minimumSize: Size(82.w, 34.h),
                      ),
                      onPressed: selectedCategoryId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(
                                    initialCategoryId: selectedCategoryId!,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text("Apply"),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading categories'));
                    }

                    final categories = snapshot.data ?? [];

                    return GridView.builder(
                      padding: EdgeInsets.all(8.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 1,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final doc = categories[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return MoreCategoryFrame(
                          imageUrl: data['imageUrl'],
                          name: data['name'],
                          isSelected: selectedCategoryId == doc.id,
                          onTap: () {
                            setState(() {
                              selectedCategoryId = doc.id;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
