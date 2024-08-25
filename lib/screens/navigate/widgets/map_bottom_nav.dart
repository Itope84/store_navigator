import 'package:flutter/material.dart';
import 'package:store_navigator/screens/home.dart';
import 'package:store_navigator/utils/icons.dart';

class MapBottomNav extends StatelessWidget {
  final bool isLocating;
  final void Function() onLocateClick;
  const MapBottomNav(
      {super.key, this.isLocating = false, required this.onLocateClick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2.0,
            // full width container
            margin: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 12, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    onTap: () {
                      print("Tapping onlocate");
                      onLocateClick();
                      if (!isLocating) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              "Select your new location to recalculate route"),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Theme.of(context).primaryColor,
                        ));
                      }
                    },
                    child: Column(
                      children: [
                        Card(
                            elevation: isLocating ? 10 : 0,
                            color: isLocating
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: CustomIcons.locationPin(
                                color:
                                    isLocating ? Colors.white : Colors.black87,
                              ),
                            )),
                        Text(
                          'Locate Me',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocating
                                      ? Theme.of(context).primaryColor
                                      : Colors.black54),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Card(
                          elevation: 0,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: CustomIcons.list(
                                size: 24, color: Colors.black87),
                          )),
                      Text(
                        'Shopping List',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (ctx) => const HomeScreen()),
                  (_) => false);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0))),
              textStyle: WidgetStateProperty.all(
                  const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            child: const Text('Exit')),
        const SizedBox(width: 16),
      ],
    );
  }
}
