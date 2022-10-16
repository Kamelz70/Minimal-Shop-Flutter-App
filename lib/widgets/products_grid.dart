import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  //passed from above
  final bool showFavorites;
  ProductsGrid(this.showFavorites);
  @override
  Widget build(BuildContext context) {
    //this is the provider listener, instance of the provider itself
    final productsData = Provider.of<Products>(context);
    //using the getter to get the list of products
    final products =
        showFavorites ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        return ChangeNotifierProvider.value(
          /////................important
          //we must use .value if we use it in builder
          // lists or grids and we don't need to pass context
          value: products[i],
          child: ProductItem(),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
