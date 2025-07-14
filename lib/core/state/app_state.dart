import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? user_id;
  void set setUserId(String? id) {
    user_id = id;
  }

  void clear() {
    user_id = null;
    notifyListeners();
  }
}
