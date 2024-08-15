import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:store_navigator/utils/api/stores.dart';
import 'package:store_navigator/utils/data/store.dart' as st;
import 'package:store_navigator/widgets/store_tile.dart';

void showSelectStore(BuildContext context,
    {st.Store? selected,
    required Function(BuildContext context, st.Store selectedStore)
        onStoreSelected}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SelectStore(
        selected: selected,
        onStoreSelected: onStoreSelected,
      );
    },
  );
}

class SelectStore extends HookWidget {
  final st.Store? selected;
  final Function(BuildContext context, st.Store selectedStore) onStoreSelected;

  const SelectStore({this.selected, required this.onStoreSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final storesResp = useGetStores();
    final stores = storesResp.state.data;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 86,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: null,
          leading: Container(),
          actions: [
            // TODO: fix padding so it leaves some gap at the top
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
          // TODO: heading style
          child: stores != null
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Select Store',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ...stores.map(
                            (store) => StoreTile(
                                store: store,
                                isSelected: selected?.id == store.id,
                                onTap: () {
                                  onStoreSelected(context, store);
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}
