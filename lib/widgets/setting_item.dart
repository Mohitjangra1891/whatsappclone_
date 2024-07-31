import 'package:flutter/material.dart';

import '../utils/AppColors.dart';

class SettingItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Function onTap;
  final padding;

  SettingItem(
      {this.icon,
      required this.title,
      this.subtitle,
      required this.onTap,
      this.padding});

  @override
  Widget build(BuildContext context) {
    if (subtitle == null) {
      return ListTile(
        contentPadding:
            padding ?? EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: icon == null
            ? null
            : Container(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  color: iconColorSecondary,
                  size: 26,
                ),
              ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          onTap();
        },
      );
    }
    return ListTile(
      contentPadding: padding ?? null,
      leading: icon == null
          ? null
          : Container(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                icon,
                color: iconColorSecondary,
                size: 26,
              ),
            ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle ?? "",
        style: const TextStyle(color: Colors.white54),
      ),
      onTap: () {
        onTap();
      },
    );
  }
}
