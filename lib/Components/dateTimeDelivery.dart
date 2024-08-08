import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapper/Components/colours.dart';

class DateTimeDelivery extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;

  DateTimeDelivery(
      {required this.onDateSelected, required this.onTimeSelected});

  @override
  _DateTimeDeliveryState createState() => _DateTimeDeliveryState();
}

class _DateTimeDeliveryState extends State<DateTimeDelivery> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    DateTime now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      // Changed from 6 to 9 to fit three slots per row
      int hour = now.hour + i;
      String start = DateFormat('h a')
          .format(DateTime(now.year, now.month, now.day, hour));
      String end = DateFormat('h a')
          .format(DateTime(now.year, now.month, now.day, hour + 1));
      _timeSlots.add('$start - $end');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expected Date & Time',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppin',
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 241, 242, 1),
                border: Border.all(
                  color: Color.fromRGBO(240, 241, 242, 1),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text(_selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMd().format(_selectedDate!)),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _timeSlots[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = timeSlot;
                    widget.onTimeSelected(timeSlot);
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 241, 242, 1),
                    border: Border.all(
                      color: _selectedTime == timeSlot
                          ? Colors.green
                          : Color.fromRGBO(240, 241, 242, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(timeSlot)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
