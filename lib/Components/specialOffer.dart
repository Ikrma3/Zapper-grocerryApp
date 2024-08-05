import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class SpecialOffer extends StatelessWidget {
  final List<Map<String, dynamic>> specialOffers;

  SpecialOffer({required this.specialOffers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text(
                'Special Deals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  // Handle View All action
                },
                child: Text(
                  'See More',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: AppColors.secondaryColor),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 13.w.h,
                color: AppColors.primaryColor,
              )
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 200.h, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialOffers.length,
            itemBuilder: (context, index) {
              var offer = specialOffers[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150, // Adjust width as needed
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(offer['imageUrls'][0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      offer['Name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\Rp ${offer['newPrice']}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
