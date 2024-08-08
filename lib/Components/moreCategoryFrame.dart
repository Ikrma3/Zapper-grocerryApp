import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreCategoryFrame extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const MoreCategoryFrame({
    required this.imageUrl,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 165.w,
            height: 160.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color.fromRGBO(76, 173, 115, 1),
                        blurRadius: 4.r,
                        spreadRadius: 0.r,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 111.h,
                    width: 142.w,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 18.w.h,
              ),
            ),
        ],
      ),
    );
  }
}
