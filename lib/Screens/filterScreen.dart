import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';
import 'package:zapper/Components/customCheckbox.dart';
import 'package:zapper/Screens/filterResult.dart';

class FilterScreen extends StatefulWidget {
  final String uid;

  const FilterScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  List<String> selectedCategories = [];
  List<String> categories = [];
  bool checkAll = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categories =
          querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  _toggleCheckAll() {
    setState(() {
      checkAll = !checkAll;
      selectedCategories = checkAll ? List.from(categories) : [];
    });
  }

  _onCategorySelected(bool selected, String category) {
    setState(() {
      if (selected) {
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });
  }

  _submitFilters() {
    double? minPrice = minPriceController.text.isNotEmpty
        ? double.parse(minPriceController.text)
        : null;
    double? maxPrice = maxPriceController.text.isNotEmpty
        ? double.parse(maxPriceController.text)
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterResult(
          uid: widget.uid,
          selectedCategories: selectedCategories,
          minPrice: minPrice,
          maxPrice: maxPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Container with gradient
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
          // Main content container with padding on top
          Container(
            margin: EdgeInsets.only(top: 290.h),
            color: Colors.white,
          ),
          Padding(
            padding: EdgeInsets.all(16.w.h),
            child: Column(
              children: [
                // AppBar or title
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                // Price Range
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Minimum',
                            hintStyle: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(240, 241, 242, 1))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(240, 241, 242, 1))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(240, 241, 242, 1))),
                            fillColor: Color.fromRGBO(240, 241, 242, 1)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text('-',
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Maximum',
                            hintStyle: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(240, 241, 242, 1))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(240, 241, 242, 1))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(240, 241, 242, 1))),
                            fillColor: Color.fromRGBO(240, 241, 242, 1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Categories section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Categories",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter')),
                    Container(
                      height: 30.h,
                      width: 85.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          color: Color.fromRGBO(54, 179, 126, 0.14)),
                      child: TextButton(
                        onPressed: _toggleCheckAll,
                        child: Text(
                          checkAll ? "Uncheck All" : "Check All",
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Inter',
                              color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: categories.map((category) {
                      bool isChecked = selectedCategories.contains(category);
                      return ListTile(
                        title: Text(
                          category,
                          style: TextStyle(
                              color: isChecked
                                  ? AppColors.primaryColor
                                  : Color.fromRGBO(55, 71, 79, 1),
                              fontSize: 18.sp,
                              fontWeight:
                                  isChecked ? FontWeight.w600 : FontWeight.w400,
                              fontFamily: 'Inter'),
                        ),
                        trailing: CustomCheckbox(
                          isChecked: isChecked,
                          onChanged: (bool selected) {
                            _onCategorySelected(selected, category);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16),
                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    minimumSize: Size(240.w, 35.h),
                  ),
                  onPressed: _submitFilters,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
