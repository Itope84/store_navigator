import 'package:flutter/material.dart';
import 'package:store_navigator/utils/icons.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;

  const BottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (int index) {
        switch (index) {
          case 0:
            break;
          case 1:
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(
            //     builder: (context) => const ZoomableMap(),
            //   ),
            // );
            break;
          case 2:
            // navigate to account
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIcons.home(color: Theme.of(context).primaryColor),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIcons.list(
            // default color of bottom nav icon
            color:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          ),
          label: 'Shopping Lists',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}
