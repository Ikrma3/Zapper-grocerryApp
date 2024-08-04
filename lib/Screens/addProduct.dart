import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _newPriceController = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _previousPriceController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nutritionFactController =
      TextEditingController();
  String? _selectedCategory;
  List<XFile> _imageFiles = [];
  bool _isSpecialOffer = false;
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles = pickedFiles;
        // Print the length of pickedFiles to debug
        print("Selected ${_imageFiles.length} images.");
      });
    }
  }

  Future<List<String>> _loadCategories() async {
    final categoriesSnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return categoriesSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _submitProduct() async {
    final name = _name.text.trim();
    final newPrice = _newPriceController.text.trim();
    final previousPrice = _previousPriceController.text.trim();
    final description = _descriptionController.text.trim();
    final nutritionFact = _nutritionFactController.text.trim();

    if (_selectedCategory == null ||
        name.isEmpty ||
        newPrice.isEmpty ||
        previousPrice.isEmpty ||
        description.isEmpty ||
        nutritionFact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (var file in _imageFiles) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'product_images/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
        final uploadTask = storageRef.putFile(File(file.path));
        final snapshot = await uploadTask;
        final imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Save product details to Firestore
      final productRef =
          FirebaseFirestore.instance.collection('products').doc();
      await productRef.set({
        'category': _selectedCategory,
        'Name': name,
        'newPrice': newPrice,
        'previousPrice': previousPrice,
        'description': description,
        'nutritionFact': nutritionFact,
        'imageUrls': imageUrls,
        'isSpecialOffer': _isSpecialOffer,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully.')),
      );

      // Clear the form
      setState(() {
        _selectedCategory = null;
        _imageFiles = [];
        _name.clear();
        _newPriceController.clear();
        _previousPriceController.clear();
        _descriptionController.clear();
        _nutritionFactController.clear();
        _isSpecialOffer = false;
      });
    } catch (e) {
      print("Error adding product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
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
        title: Text(
          "Add Product",
          style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
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
                  FutureBuilder<List<String>>(
                    future: _loadCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading categories');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No categories available');
                      } else {
                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          hint: Text(
                            'Select a category',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          items: snapshot.data!.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Center(
                        child: Text(
                          _imageFiles.isEmpty
                              ? "Upload images"
                              : "Change images",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _imageFiles.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _imageFiles.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              File(_imageFiles[index].path),
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Container(),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondaryColor)),
                      hintText: 'Name',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _newPriceController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondaryColor)),
                      hintText: 'New Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _previousPriceController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondaryColor)),
                      hintText: 'Previous Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondaryColor)),
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _nutritionFactController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondaryColor)),
                      hintText: 'Nutrition Facts',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Checkbox(
                        value: _isSpecialOffer,
                        onChanged: (value) {
                          setState(() {
                            _isSpecialOffer = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'Special Offer',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'Inter',
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitProduct,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
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
