// TODO Implement this library.
import 'package:flutter/foundation.dart';

class UserDataProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUser(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    notifyListeners();
  }
}