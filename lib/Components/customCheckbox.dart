import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({required this.isChecked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!isChecked);
      },
      child: Container(
        width: 20.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primaryColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked ? AppColors.primaryColor : Colors.grey,
            width: 2.w,
          ),
        ),
        child: isChecked
            ? Icon(
                Icons.check,
                size: 16.sp,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
