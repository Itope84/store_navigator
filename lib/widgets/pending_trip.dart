import 'package:flutter/material.dart';
import 'package:store_navigator/utils/icons.dart';

class ShoppingTripCard extends StatelessWidget {
  const ShoppingTripCard({Key? key, this.isMainCard = false}) : super(key: key);

  final bool isMainCard;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A row with two text widgets, the first one is bold
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIcons.store(size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tesco Woolwich Arsenal',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'Morrisons british chicken thighs, Morrisons british chicken thighs,  and 12 more.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 16),

              if (isMainCard)
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => {},
                      child: const Text('Edit List'),
                    ),
                    SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => {},
                      child: const Text('Navigate'),
                    ),
                  ],
                )
            ],
          ),
        ));
  }
}
