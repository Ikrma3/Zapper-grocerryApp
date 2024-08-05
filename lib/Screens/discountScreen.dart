import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';

class AddDiscountScreen extends StatefulWidget {
  @override
  _AddDiscountScreenState createState() => _AddDiscountScreenState();
}

class _AddDiscountScreenState extends State<AddDiscountScreen> {
  String? _selectedCategory;
  final TextEditingController _discountController = TextEditingController();
  List<String> _categories = [];
  bool _isLoading = false;
  String _discountAction = 'Add Discount';
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoriesSnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = categoriesSnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _applyDiscount() async {
    final discountStr = _discountController.text.trim();
    final discount = double.tryParse(discountStr) ?? 0;

    if (_selectedCategory == null || discount < 0 || discount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select a category and enter a valid discount percentage.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: _selectedCategory)
          .get();

      for (var doc in productsSnapshot.docs) {
        final productData = doc.data();
        final previousPrice =
            double.tryParse(productData['previousPrice'] ?? '0') ?? 0;
        final newPrice = double.tryParse(productData['newPrice'] ?? '0') ?? 0;

        double updatedNewPrice = newPrice;
        double updatedPreviousPrice = previousPrice;

        if (_discountAction == 'Add Discount') {
          updatedNewPrice = newPrice * (1 - discount / 100);
          updatedPreviousPrice = newPrice;
        } else {
          updatedNewPrice = newPrice * (1 + discount / 100);
          if (updatedNewPrice == previousPrice) {
            updatedPreviousPrice = 0;
          } else {
            updatedPreviousPrice = newPrice;
          }
        }

        if (updatedPreviousPrice < updatedNewPrice) {
          updatedPreviousPrice = 0;
        }

        await doc.reference.update({
          'newPrice': updatedNewPrice.toStringAsFixed(2),
          'previousPrice': updatedPreviousPrice.toStringAsFixed(2),
        });
      }

      // Update the discount value in the selected category
      final categoryDoc = FirebaseFirestore.instance
          .collection('categories')
          .doc(_selectedCategory);
      final categoryData = (await categoryDoc.get()).data();
      final currentCategoryDiscount =
          double.tryParse(categoryData?['discount']?.toString() ?? '0') ?? 0;
      final updatedCategoryDiscount = _discountAction == 'Add Discount'
          ? discount
          : (currentCategoryDiscount - discount).clamp(0, 100);

      await categoryDoc.update({'discount': updatedCategoryDiscount});

      // Handle image upload if "Add Discount" is selected
      if (_discountAction == 'Add Discount' && _imageFile != null) {
        print("Uploading discount image...");
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('discount_images/$_selectedCategory.jpg');
        final uploadTask = storageRef.putFile(File(_imageFile!.path));

        uploadTask.snapshotEvents.listen((event) {
          print('Task state: ${event.state}');
          print(
              'Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
        }).onError((error) {
          print("Error during image upload: $error");
        });

        try {
          final snapshot = await uploadTask;
          final imageUrl = await snapshot.ref.getDownloadURL();
          print("Discount image URL: $imageUrl");

          await categoryDoc.update({'discountImage': imageUrl});
        } catch (e) {
          print("Error during upload or timeout: $e");
          throw e;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discount applied successfully.')),
      );

      // Clear the input
      setState(() {
        _selectedCategory = null;
        _discountController.clear();
        _imageFile = null;
      });
    } catch (e) {
      print("Error applying discount: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying discount: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Discount',
            style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: Stack(children: [
          Background(
            topColor: AppColors.primaryColor,
            bottomColor: AppColors.whiteColor,
            // Adjust this value as needed
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text('Select a category',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category,
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  DropdownButtonFormField<String>(
                    value: _discountAction,
                    hint: Text('Select action',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    items: ['Add Discount', 'Deduct Discount'].map((action) {
                      return DropdownMenuItem<String>(
                        value: action,
                        child: Text(action,
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _discountAction = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  if (_discountAction == 'Add Discount') ...[
                    _imageFile == null
                        ? GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 150.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                color: AppColors.secondaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  "Upload an image",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Image.file(
                            File(_imageFile!.path),
                            width: double.infinity,
                            height: 150.h,
                            fit: BoxFit.cover,
                          ),
                    SizedBox(height: 20.h),
                  ],
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      hintText: 'Enter discount percentage',
                      hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                  SizedBox(height: 420.h),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _applyDiscount,
                          child: Text('Apply Discount',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: Size(double.infinity, 40.h),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
