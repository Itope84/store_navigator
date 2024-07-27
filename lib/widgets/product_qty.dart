import 'package:flutter/material.dart';

class TinyFab extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final bool isFilled;
  const TinyFab(
      {required this.icon,
      required this.onPressed,
      this.isFilled = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: FittedBox(
        child: IconButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: isFilled
                ? WidgetStateProperty.all(
                    Theme.of(context).primaryColor.withAlpha(30))
                : WidgetStateProperty.all(
                    Theme.of(context).scaffoldBackgroundColor),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                side: isFilled
                    ? BorderSide.none
                    : BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.circular(100.0))),
          ),
          padding: EdgeInsets.zero,
          icon: Icon(
            color: Theme.of(context).primaryColor,
            icon,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class ProductQtyController extends StatelessWidget {
  final int qty;
  final Function() onAddProduct, onRemoveProduct;
  const ProductQtyController(
      {required this.qty,
      required this.onAddProduct,
      required this.onRemoveProduct,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          TinyFab(
              icon: Icons.remove_rounded,
              isFilled: true,
              onPressed: onRemoveProduct),
          Expanded(
              child: Center(
            child: Text(qty.toString(),
                style: Theme.of(context).textTheme.titleMedium),
          )),
          TinyFab(icon: Icons.add, onPressed: onAddProduct),
        ],
      ),
    );
  }
}
