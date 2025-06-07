// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), backgroundColor: Colors.brown[900]);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
