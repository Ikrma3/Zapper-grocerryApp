import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class HomeCard extends StatelessWidget {
  final String id;
  final String image;
  final double discount;
  final String name;

  HomeCard(
      {required this.id,
      required this.image,
      required this.discount,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Uncomment and complete the navigation logic as needed
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => NextScreen(documentId: id),
        //   ),
        // );
      },
      child: Container(
        width: 327.w,
        height: 183.h,
        margin: EdgeInsets.all(8.w.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(244, 111, 46, 1),
              Color.fromRGBO(246, 134, 114, 1)
            ],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 230,
              top: -12,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 224, 130, 1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              'Discount',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                        Container(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                '$discount%',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            Text(
                              '$name',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          width: 95.w,
                          height: 18.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // Uncomment and complete the navigation logic as needed
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => NextScreen(documentId: id),
                              //   ),
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Color.fromRGBO(
                                  255, 224, 130, 1), // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'See Detail',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: 258.w,
                      height: 162.h,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
