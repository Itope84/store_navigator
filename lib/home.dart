import 'package:flutter/material.dart';
import 'package:store_navigator/utils/icons.dart';
import 'package:store_navigator/widgets/pending_trip.dart';
import 'package:store_navigator/zoomable_map.dart';

// TODO: style as in figma
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // title should be aligned left and have a padding of 8.0 on the top and bottom
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Welcome Back',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: false,
        actions: [
          // A circlular button that has the letter A in it, background is primary and is clickable
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Text('A'),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ListView(
          children: [
            FilledButton(
              child: const Text('Start New Shopping List'),
              onPressed: () => {},
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending Shopping Trips',
                    style: Theme.of(context).textTheme.titleLarge),
                // text button with View all text
                TextButton(
                  onPressed: () => {},
                  child: Text(
                    'View all',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ShoppingTripCard(
              isMainCard: true,
            ),
            // horizontal listview with height of 200
            Container(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: 200,
                    child: ShoppingTripCard(),
                  ),
                  Container(
                    width: 200,
                    child: ShoppingTripCard(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Text('Past Shopping Trips',
                style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 10),

            Container(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: 200,
                    child: ShoppingTripCard(),
                  ),
                  Container(
                    width: 200,
                    child: ShoppingTripCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ZoomableMap(),
                ),
              );
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
              color: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
            ),
            label: 'Shopping Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
