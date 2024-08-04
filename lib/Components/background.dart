import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Background extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;

  Background({
    required this.topColor,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bottom section covering the entire screen
        Positioned.fill(
          child: Container(
            color: bottomColor,
          ),
        ),
        // Top section with hardcoded height and curves
        Positioned(
          top: -10, // Adjust this value to move the top section up or down
          left: -20,
          right: -10,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: 400.h, // Height of the top section
              color: topColor,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom clipper to create the desired curve at the bottom of the top section
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Move to the starting point
    path.lineTo(0, size.height - 70.h); // Adjust the height as needed

    // Draw the curve to make the bottom right corner more rounded
    path.quadraticBezierTo(
      size.width * 0.75, // X control point to make the curve more gradual
      size.height, // Y control point to increase the roundness
      size.width,
      size.height - 130.h, // Adjust as needed for a smoother transition
    );

    // Draw the remaining part of the top section
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
