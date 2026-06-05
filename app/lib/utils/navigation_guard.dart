import 'package:flutter/material.dart';

void popIfPossible(BuildContext context) {
  final navigator = Navigator.of(context);

  if (navigator.canPop()) {
    navigator.pop();
  }
}
