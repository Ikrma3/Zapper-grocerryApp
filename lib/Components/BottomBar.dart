import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.home,
                color: currentIndex == 0 ? Colors.green : Colors.grey),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.favorite_outline,
                color: currentIndex == 1 ? Colors.green : Colors.grey),
          ),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: currentIndex == 2 ? Colors.green : Colors.grey),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.person_outline,
                color: currentIndex == 3 ? Colors.green : Colors.grey),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
