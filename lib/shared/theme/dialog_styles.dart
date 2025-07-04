import 'package:flutter/material.dart';

class DialogStyles {
  static const EdgeInsets actionsPadding = EdgeInsets.fromLTRB(16, 8, 16, 12);

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonTextStyle = TextStyle(fontSize: 14);

  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.orange,
    fontSize: 13.5,
  );

  static final RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  static final BoxDecoration errorCardDecoration = BoxDecoration(
    color: Colors.orange.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.orange.shade200),
  );
}
