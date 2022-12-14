import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  //token for comm. with server, expires!!!
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expiryDate.isAfter(
          DateTime.now(),
        ) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String address, String email, String password) async {
    final url = Uri.parse(address);
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final reponseData = json.decode(response.body);

      if (reponseData['error'] != null) {
        throw HttpException(reponseData['error']['message']);
      }
      _token = reponseData['idToken'];
      _userId = reponseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(reponseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      print(
          '1111111111111111111111111111111111111111111111111111111111111111111111');

      ///async code also
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });

      prefs.setString('userData', userData);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> signUp(String email, String password) {
    return _authenticate(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCn68xEWG9IEpb5QSk0pk-gyX2jWSJweYc",
        email,
        password);
  }

  Future<void> logIn(String email, String password) {
    return _authenticate(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCn68xEWG9IEpb5QSk0pk-gyX2jWSJweYc",
        email,
        password);
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final extExpiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (extExpiryDate.isBefore(DateTime.now())) {
      return false;
    }
    //    {'token': _token, 'userId': _userId, 'expiryDate': _expiryDate});

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = extractedUserData['expiryDate'];
    notifyListeners();
    _autoLogout();
    return true;
  }
}
