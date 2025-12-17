import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  void snack(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(msg)));
  }

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
}
