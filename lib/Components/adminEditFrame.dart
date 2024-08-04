import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class AdminProductFrame extends StatelessWidget {
  final String imageUrl;
  final String name;
  final VoidCallback onTap;

  const AdminProductFrame({
    required this.imageUrl,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320.w,
        height: 70.h,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: Color.fromARGB(255, 253, 150, 71),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                imageUrl,
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
