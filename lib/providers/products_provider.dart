import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String _authToken;
  final String _userId;
  Products(this._authToken, this._userId, this._items);

///////////////////////////////////////////////////////
  ///getters
  ///
  var _showFavorites = false;
  List<Product> get items {
    //copy spread items (brackets means copy)
    if (_showFavorites) {
      return _items.where((item) {
        return item.isFavorite;
      }).toList();
    } else {
      return [..._items];
    }
  }

  List<Product> get favoriteItems {
    return _items.where((item) {
      return item.isFavorite;
    }).toList();
  }

///////////////////////////////////////////////////////
  ///Methods
  ///
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    try {
      String filterString = '';
      if (filterByUser) {
        filterString = '&orderBy="ownerId"&equalTo="$_userId"';
      }
      final url = Uri.parse(
          'https://shop-application-c27b8-default-rtdb.firebaseio.com/products.json?auth=$_authToken$filterString');

      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }

      ///
      final favoritesUrl = Uri.parse(
          'https://shop-application-c27b8-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken');
      final favoritesResponse = await http.get(favoritesUrl);
      final favoritesData = json.decode(favoritesResponse.body);

      ///
      final List<Product> loadedProducts = [];
      print(data);
      print('fataa');

      data.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: double.parse("${prodData['price']}"),
          isFavorite:
              //?? means check if null and put
              favoritesData == null
                  ? false
                  : favoritesData[prodId] as bool ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      print('hereeeeeeeeeeeeeeeeeeeeee');
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
  // void showFavorites() {
  //   _showFavorites = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavorites = false;
  //   notifyListeners();
  // }
//async await
  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-application-c27b8-default-rtdb.firebaseio.com/products.json?auth=$_authToken');
    //return the request which is future to know when it's done
    // return http
    //     .post(
    //   url,
    //   body: json.encode(
    //     {
    //       'title': product.title,
    //       'description': product.description,
    //       'price': product.price,
    //       'imageUrl': product.imageUrl,
    //       'isFavorite': product.isFavorite,
    //     },
    //   ),
    // )
    //     .then((response) {
    //   print("generated id is ${json.decode(response.body)['name']}");
    //   final newProduct = Product(
    //       id: json.decode(response.body)['name'],
    //       title: product.title,
    //       description: product.description,
    //       price: product.price,
    //       imageUrl: product.imageUrl);

    //   _items.insert(0, newProduct);
    //   //or _items.add(newProduct);
    //   notifyListeners();
    // }).catchError((error) {
    //   // ignore: avoid_print
    //   print(error);
    // });
    //catError catches any error in any previous
    //future function, goes immedieately to catch error

////////////////////////other preferred method
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'ownerId': _userId
          },
        ),
      );
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.insert(0, newProduct);
      //or _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // ignore: avoid_print
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product newProduct) async {
    final url = Uri.parse(
        'https://shop-application-c27b8-default-rtdb.firebaseio.com/products/${newProduct.id}.json?auth=$_authToken');

    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price
        }));
    final index = _items.indexWhere((prod) => prod.id == newProduct.id);
    if (index < 0) {
      //safety only
      print('invalid eddition');
      return;
    }
    _items[index] = newProduct;
    notifyListeners();
  }

//   Future<void> removeProduct(String id) {
//     final url = Uri.parse(
//         'https://shop-application-c27b8-default-rtdb.firebaseio.com/products/${id}.json');
//     final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
//     //pointer to elements
//     var existingProduct = _items[existingProductIndex];
//     //remove in list but we still gave a reference to the product above
//     _items.removeAt(existingProductIndex);
//     notifyListeners();
//     //optimistic updating delete doesn't throw errors
//     http.delete(url).then((response) {
//       if (response.statusCode >= 400) {
//         throw HttpException("Couldn't delete product");
//       }
//       //clear object from memory
//       existingProduct = null;
//     }).catchError((error) {
//       //rollback on error
//       _items.insert(existingProductIndex, existingProduct);
//       notifyListeners();
//     });
//   }
// }
//or
  Future<void> removeProduct(String id) async {
    final url = Uri.parse(
        'https://shop-application-c27b8-default-rtdb.firebaseio.com/products/${id}.json?auth=$_authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    //pointer to elements
    var existingProduct = _items[existingProductIndex];
    //remove in list but we still gave a reference to the product above
    _items.removeAt(existingProductIndex);
    notifyListeners();
    //optimistic updating delete doesn't throw errors
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Couldn't delete product");
    }
    //clear object from memory
    existingProduct = null;

    //rollback on error
  }
}
