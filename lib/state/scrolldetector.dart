import 'package:flutter/material.dart';

class ScrollDetector extends ChangeNotifier {
  bool _isScrolled = true;
  int _index = 0;

  bool get isScrolled => _isScrolled;

  int get index => _index;

  void setIndex(int value) {
    _index = value;
    notifyListeners();
  }

  void visible(bool scroll) {
    if (!_isScrolled == scroll) {
      _isScrolled = scroll;
      notifyListeners();
    }
  }
}
