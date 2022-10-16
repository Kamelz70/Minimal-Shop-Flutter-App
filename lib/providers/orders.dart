import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.date,
      @required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String _authToken;
  final String _userId;
  Orders(this._authToken, this._userId, this._orders);

  ////////////////////////////////////////////////////////////////////
  ///  getters
  ///
  List<OrderItem> get orders {
    return [..._orders];
  }

  ////////////////////////////////////////////////////////////////////
  ///  methods
  ///
  Future<void> fetchAndSetOrderss() async {
    var url = Uri.parse(
        'https://shop-application-c27b8-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];
      data.forEach((orderId, orderData) {
        loadedOrders.insert(
          0,
          OrderItem(
            id: orderId,
            amount: double.parse("${orderData['amount']}"),
            date: DateTime.parse(orderData['date']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      price: double.parse("${item['price']}"),
                      title: item['title'],
                      quantity: int.parse("${item['quantity']}"),
                    ))
                .toList(),
          ),
        );
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-application-c27b8-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'date': DateTime.now().toIso8601String(),
            'products': cartProducts
                .map(
                  (cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.quantity
                  },
                )
                .toList(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          date: DateTime.now(),
          products: cartProducts,
        ),
      );
      //or _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // ignore: avoid_print
      print(error);
      throw error;
    }
  }
}
