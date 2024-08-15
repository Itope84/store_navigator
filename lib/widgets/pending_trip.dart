import 'package:flutter/material.dart';
import 'package:store_navigator/screens/shopping_list/main.dart';
import 'package:store_navigator/store_map.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/data/store.dart';
import 'package:store_navigator/utils/icons.dart';
import 'package:store_navigator/screens/zoomable_map.dart';

class ShoppingTripCard extends StatelessWidget {
  final Store store;
  final ShoppingList shoppingList;
  final Function onEdit;

  const ShoppingTripCard(
      {required this.store,
      required this.shoppingList,
      required this.onEdit,
      Key? key,
      this.isMainCard = false})
      : super(key: key);

  final bool isMainCard;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
            onTap: !isMainCard ? () => onEdit() : null,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: add updated time
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIcons.store(size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          store.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "${shoppingList.items!.take(2).map((e) => e.product.name).join(', ')} ${shoppingList.items!.length > 2 ? 'and ${shoppingList.items!.length - 2} more' : ''}",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),

                  if (isMainCard)
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => {onEdit()},
                          child: const Text('Edit List'),
                        ),
                        SizedBox(width: 12),
                        FilledButton(
                          onPressed: () => {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => ZoomableMap(
                                      shoppingList: shoppingList,
                                    )))
                          },
                          child: const Text('Navigate'),
                        ),
                      ],
                    )
                ],
              ),
            )));
  }
}
