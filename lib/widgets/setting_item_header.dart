import 'package:flutter/material.dart';

import '../utils/CGColors.dart';

class SettingItemHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final padding;

  SettingItemHeader({required this.title, this.subtitle, this.padding});

  @override
  Widget build(BuildContext context) {
    if (subtitle != null) {
      return ListTile(
        title: Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              color: secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: subtitle == null ? null : Text(subtitle!),
        contentPadding: padding,
      );
    }
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.0,
          color: secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
