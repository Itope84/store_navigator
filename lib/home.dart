import 'package:flutter/material.dart';

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
          ],
        ),
      ),
    );
  }
}
