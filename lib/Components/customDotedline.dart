// import 'package:flutter/material.dart';

// class DottedLinePainter extends CustomPainter {
//   final Color color;

//   DottedLinePainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = color
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     double dashWidth = 4, dashSpace = 4, startY = 0;
//     while (startY < size.height) {
//       canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
//       startY += dashWidth + dashSpace;
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
