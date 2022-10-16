import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  Future<void> _refreshProducts(BuildContext context) async {
    return Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Products"), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },
        )
      ]),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Consumer<Products>(
                            builder: (_, productsData, child) {
                          return ListView.builder(
                            itemBuilder: (ctx, index) => Column(
                              children: [
                                UserProductItem(
                                  title: productsData.items[index].title,
                                  imageUrl: productsData.items[index].imageUrl,
                                  id: productsData.items[index].id,
                                ),
                                const Divider(
                                  thickness: 3,
                                ),
                              ],
                            ),
                            itemCount: productsData.items.length,
                          );
                        })),
                  ),
      ),
    );
  }
}
