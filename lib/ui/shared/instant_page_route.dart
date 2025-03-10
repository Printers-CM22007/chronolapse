import 'package:flutter/material.dart';

/// Page route with no animation
class InstantPageRoute<T> extends MaterialPageRoute<T> {
  InstantPageRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
