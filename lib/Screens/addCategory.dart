import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zapper/Components/background.dart';
import 'package:zapper/Components/colours.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _submitCategory() async {
    print("SUbmit");
    final categoryName = _categoryController.text.trim();
    print("Category Name: $categoryName");
    if (categoryName.isEmpty) {
      print("Category name is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category name cannot be empty.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Upload the image to Firebase Storage
      String? imageUrl;
      if (_imageFile != null) {
        print("Uploading image...");
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('category_images/$categoryName.jpg');
        final uploadTask = storageRef.putFile(File(_imageFile!.path));

        uploadTask.snapshotEvents.listen((event) {
          print('Task state: ${event.state}');
          print(
              'Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
        }).onError((error) {
          print("Error during image upload: $error");
        });

        // Handle upload and timeout
        try {
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
          print("Image URL: $imageUrl");
        } catch (e) {
          print("Error during upload or timeout: $e");
          throw e;
        }
      }

      // Create a reference to the Firestore collection
      final categoryRef =
          FirebaseFirestore.instance.collection('categories').doc(categoryName);

      // Check if the category already exists
      print("Checking if category already exists...");
      final docSnapshot = await categoryRef.get();
      if (!docSnapshot.exists) {
        print("Category does not exist. Adding new category...");
        // If not, add the new category
        await categoryRef.set({
          'name': categoryName,
          'imageUrl': imageUrl, // Save the image URL in Firestore
          'discount': '0',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully.')),
        );
        // Clear the form
        _categoryController.clear();
        setState(() {
          _imageFile = null;
        });
      } else {
        print("Category already exists");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category already exists.')),
        );
      }
    } catch (e) {
      print("Error adding category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding category: $e')),
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
          "Add Category",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
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
                children: [
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
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: 'Category name',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontFamily: 'OpenSans',
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 330.h),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitCategory,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.secondaryColor,
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
