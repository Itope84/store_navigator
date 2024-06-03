// PendingTrip widget

import 'package:flutter/material.dart';

class PendingTrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          // TODO: deoends on whether or not it;s the main or smaller card
          // height: 160,
          // TODO: width: ,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // A row with two text widgets, the first one is bold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shopping trip to Walmart',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // A text widget with the text 'Today'
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // A row with two text widgets, the first one is bold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total items: 10',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // A text widget with the text 'View'
                  Text(
                    'View',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
