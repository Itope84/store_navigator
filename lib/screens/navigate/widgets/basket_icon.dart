import 'package:flutter/material.dart';

class BasketIcon extends StatelessWidget {
  final int itemCount;

  const BasketIcon({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      padding: const EdgeInsets.all(1),
      child: Stack(
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
                    itemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
