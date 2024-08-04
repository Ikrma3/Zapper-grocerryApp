import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const CustomTextFormField({
    required this.controller,
    required this.errorText,
    required this.labelText,
    this.obscureText = false,
    required this.keyboardType,
    required this.textInputAction,
    super.key,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      width: 320.w,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        style: const TextStyle(color: Color(0xff404B52)),
        decoration: InputDecoration(
          labelText: widget.errorText ?? widget.labelText,
          labelStyle: TextStyle(
            color: widget.errorText != null ? Colors.red : AppColors.greyColor,
            fontSize: 15.sp,
          ),
          suffixIcon: widget.labelText == "Password"
              ? GestureDetector(
                  onTap: _toggleVisibility,
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.textField,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.textField,
              width: 1.w,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.w,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.w,
            ),
          ),
          fillColor: AppColors.textField,
          filled: true,
          errorText: widget.errorText != null ? '' : null,
          errorStyle: const TextStyle(height: 0),
        ),
      ),
    );
  }
}
