import 'package:flutter/material.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/shelves.dart';

class BasketIcon extends StatelessWidget {
  final ShelfNode shelfNode;
  final double initialScale;
  final bool showDetails;
  final GlobalKey buttonKey;
  final void Function() onTap;
  final void Function(ShoppingListItem item) onItemFound;

  const BasketIcon(
      {super.key,
      required this.buttonKey,
      required this.shelfNode,
      required this.initialScale,
      this.showDetails = false,
      required this.onItemFound,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    const cardWidth = 150.0;

    return Positioned(
        // The -12 is a hack, for some reason, the item gets position slightly off, this is to place them directly within the route
        left: (shelfNode.routeEnd.dx * initialScale) - (cardWidth / 2),
        top: (shelfNode.routeEnd.dy * initialScale) - 12,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              child: Container(
                width: cardWidth,
                margin: const EdgeInsets.only(top: 12),
                child: showDetails
                    ? Card(
                        elevation: 2.0,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                shelfNode.shelf.name!,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Divider(),
                              ...shelfNode.items.map(
                                (item) => InkWell(
                                  key: shelfNode.getItemKey(item),
                                  onTap: () {
                                    onItemFound(item);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    // checkbox with item name
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: item.found,
                                            onChanged: (value) {
                                              onItemFound(item);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "${item.product.name ?? ''} (x${item.qty})",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            InkWell(
              key: buttonKey,
              onTap: () {
                onTap();
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        shelfNode.allItemsFound ? Colors.green : Colors.white),
                padding: const EdgeInsets.all(1),
                child: shelfNode.allItemsFound
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                    : Stack(
                        children: <Widget>[
                          const Icon(
                            Icons.shopping_basket,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 14,
                              height: 14,
                              child: Center(
                                child: Text(
                                  shelfNode.items.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ));
  }
}
