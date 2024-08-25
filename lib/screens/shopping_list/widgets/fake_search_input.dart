import 'package:flutter/material.dart';

class ShoppingListFakeSearch extends StatelessWidget {
  final Function() onTap;
  final Function() onScan;
  const ShoppingListFakeSearch(
      {required this.onTap, required this.onScan, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: const Color(0xFF9095A1),
                strokeAlign: BorderSide.strokeAlignOutside),
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 12),
            // TODO: placeholder search
            const Expanded(child: Text('Search products')),
            SizedBox(
              width: 36.0,
              height: 36.0,
              child: Tooltip(
                message:
                    'Quickly find products by scanning a written or typed list',
                child: IconButton.filled(
                    onPressed: () {
                      onScan();
                    },
                    iconSize: 20,
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Color(0xFF6D31ED)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)))),
                    icon: const Icon(Icons.document_scanner_outlined)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
