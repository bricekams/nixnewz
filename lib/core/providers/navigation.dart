import 'package:flutter/cupertino.dart';

class ShellProvider with ChangeNotifier {
  int _current = 0;
  int get current => _current;

  set setCurrent (index) {
    _current = index;
    notifyListeners();
  }
}