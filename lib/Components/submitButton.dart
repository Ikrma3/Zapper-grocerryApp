import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmitButton extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String text;
  final Color textColor;
  final double height;
  final Function onPressed;
  final String? imagePath;

  SubmitButton({
    required this.color,
    required this.borderColor,
    required this.text,
    required this.textColor,
    required this.height,
    required this.onPressed,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 335.w,
      height: height.h,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.07), // Color of the shadow
            spreadRadius: 2, // How much the shadow spreads
            blurRadius: 5, // How blurry the shadow is
            offset: Offset(0, 3), // Position of the shadow (x, y)
          ),
        ],
        borderRadius: BorderRadius.circular(8.0.r),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor, backgroundColor: color,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0, // Remove default elevation
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: 18.h,
                width: 18.h,
              ),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
