import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/screens/select_store.dart';
import 'package:store_navigator/utils/api/stores.dart';
import 'package:store_navigator/screens/shopping_list/main.dart';
import 'package:store_navigator/widgets/pending_trip.dart';

// TODO: style as in figma
class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final queryResponse = useShoppingLists();
    final shoppingLists = queryResponse.state.data;

    final storesResp = useGetStores();
    final stores = storesResp.state.data;

    useEffect(() {
      if (stores != null && shoppingLists != null) {
        shoppingLists.forEach((list) {
          list.store = stores.firstWhere((store) => store.id == list.storeId);
        });
      }
      return;
    }, [shoppingLists, stores]);

    final isLoading = queryResponse.state.status == QueryStatus.fetching ||
        storesResp.state.status == QueryStatus.fetching;

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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  FilledButton(
                    onPressed: stores != null
                        ? () => {
                              showSelectStore(context, onStoreSelected:
                                  (storeSelectorContext, store) {
                                Navigator.of(storeSelectorContext)
                                    .pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShoppingListScreen(store: store)),
                                );
                              })
                            }
                        : null,
                    child: const Text('Start New Shopping List'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pending Shopping Trips',
                          style: Theme.of(context).textTheme.titleLarge),
                      // text button with View all text
                      if (shoppingLists != null && !shoppingLists.isEmpty)
                        TextButton(
                          onPressed: () => {},
                          child: Text(
                            'View all',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  ...(shoppingLists != null && shoppingLists.length > 0
                      ? [
                          const SizedBox(height: 10),
                          const ShoppingTripCard(
                            isMainCard: true,
                          ),
                          Container(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Container(
                                  width: 200,
                                  child: ShoppingTripCard(),
                                ),
                                Container(
                                  width: 200,
                                  child: ShoppingTripCard(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text('Past Shopping Trips',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          Container(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Container(
                                  width: 200,
                                  child: ShoppingTripCard(),
                                ),
                                Container(
                                  width: 200,
                                  child: ShoppingTripCard(),
                                ),
                              ],
                            ),
                          ),
                        ]
                      : [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 40),
                            child:
                                Text("You have not created any shopping lists"),
                            // TODO: add a button to create a new shopping list
                          )
                        ]),
                ],
              ),
      ),
      // bottomNavigationBar: BottomNav(activeIndex: 0),
    );
  }
}
