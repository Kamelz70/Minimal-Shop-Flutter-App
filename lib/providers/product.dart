import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  void toggleFavorite(String token, String userId) async {
    //optimistc updating
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://shop-application-c27b8-default-rtdb.firebaseio.com/userFavorites/$userId/${id}.json?auth=$token');
    try {
      //http only throws on get and post
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );

      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
        print('error toggling favorites');
      }
    } catch (error) {
      isFavorite = oldStatus;
      print(error);
      notifyListeners();
    }
  }
}
