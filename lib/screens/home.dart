import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/screens/select_store.dart';
import 'package:store_navigator/utils/api/stores.dart';
import 'package:store_navigator/screens/shopping_list/main.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/widgets/pending_trip.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queryResponse = useShoppingLists();
    final shoppingLists = queryResponse.state.data;

    List<ShoppingList> completedShoppingLists =
        shoppingLists?.where((list) => list.isCompleted).toList() ?? [];
    List<ShoppingList> pendingShoppingLists =
        shoppingLists?.where((list) => !list.isCompleted).toList() ?? [];

    final storesResp = useGetStores();
    final stores = storesResp.state.data;

    useEffect(() {
      if (stores != null && shoppingLists != null) {
        for (var list in shoppingLists) {
          list.store = stores.firstWhere((store) => store.id == list.storeId);
        }
      }
      return;
    }, [shoppingLists, stores]);

    final isLoading = queryResponse.state.status == QueryStatus.fetching ||
        storesResp.state.status == QueryStatus.fetching;

    void editShoppingList(ShoppingList list) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
                builder: (context) =>
                    ShoppingListScreen(id: list.id, store: list.store!)),
          )
          .then((_) => queryResponse.refetch());
    }

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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                                    )
                                    .then((_) => queryResponse.refetch());
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
                      if (shoppingLists != null && shoppingLists.isNotEmpty)
                        TextButton(
                          onPressed: () => {},
                          child: Text(
                            'View all',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  ...(shoppingLists != null && shoppingLists.isNotEmpty
                      ? [
                          const SizedBox(height: 10),
                          if (pendingShoppingLists.isNotEmpty)
                            ShoppingTripCard(
                              store: pendingShoppingLists[0].store!,
                              shoppingList: pendingShoppingLists[0],
                              isMainCard: true,
                              onNavigateComplete: () => queryResponse.refetch(),
                              onEdit: () =>
                                  editShoppingList(pendingShoppingLists[0]),
                            ),

                          // TODO: change this page to the "all lists page"? i.e. show all lists in the isMainCard: true format so there's no need for a separate shopping lists page
                          if (pendingShoppingLists.length > 1)
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                itemCount: pendingShoppingLists.length - 1,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) => SizedBox(
                                  width: 200,
                                  child: ShoppingTripCard(
                                      store: pendingShoppingLists[index + 1]
                                          .store!,
                                      shoppingList:
                                          pendingShoppingLists[index + 1],
                                      onEdit: () => editShoppingList(
                                          pendingShoppingLists[index + 1])),
                                ),
                              ),
                            ),
                          const SizedBox(height: 40),
                          if (completedShoppingLists.isNotEmpty)
                            Text('Past Shopping Trips',
                                style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),

                          Container(
                            height: 160,
                            child: ListView.builder(
                              itemCount: completedShoppingLists.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, index) => SizedBox(
                                width: 200,
                                child: ShoppingTripCard(
                                    store: completedShoppingLists[index].store!,
                                    shoppingList: completedShoppingLists[index],
                                    onEdit: () => editShoppingList(
                                        completedShoppingLists[index])),
                              ),
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
