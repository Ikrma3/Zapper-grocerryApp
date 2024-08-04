import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditCategoryComponent extends StatefulWidget {
  final String categoryId;
  final String currentName;
  final String currentImageUrl;

  EditCategoryComponent({
    required this.categoryId,
    required this.currentName,
    required this.currentImageUrl,
  });

  @override
  _EditCategoryComponentState createState() => _EditCategoryComponentState();
}

class _EditCategoryComponentState extends State<EditCategoryComponent> {
  final TextEditingController _nameController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _updateCategory() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a category name.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'category_images/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}');
        final uploadTask = storageRef.putFile(File(_imageFile!.path));
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        imageUrl = widget.currentImageUrl;
      }

      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .update({
        'name': name,
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error updating category: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category: $e')),
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
        title: Text('Edit Category'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                height: 150.h,
                child: _imageFile == null
                    ? (widget.currentImageUrl.isEmpty
                        ? Center(child: Text('Pick an image'))
                        : Image.network(widget.currentImageUrl,
                            fit: BoxFit.cover))
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.h),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateCategory,
                    child: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                      minimumSize: Size(double.infinity, 40.h),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
