import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/setting_item.dart';
import 'account/account_privacy_settings_screen.dart';
import 'account/account_security_settings_screen.dart';
import 'account/account_twostep_settings_screen.dart';
import 'future_todo_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        children: <Widget>[
          SettingItem(
            icon: Icons.security_outlined,
            title: 'Security',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSecuritySettingsScreen()));
            },
          ),
          SettingItem(
            icon: Icons.email_outlined,
            title: 'Email address',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
            },
          ),
          SettingItem(
            icon: Icons.password_outlined,
            title: 'Two-step verification',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountTwoStepSettingsScreen()));
            },
          ),
          SettingItem(
            icon: Icons.phonelink_setup,
            title: 'Change number',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
            },
          ),
          SettingItem(
            icon: Icons.insert_drive_file_outlined,
            title: 'Request account info',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
            },
          ),
          SettingItem(
            icon: Icons.person_add,
            title: 'Add Account',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
            },
          ),
          SettingItem(
            icon: Icons.delete_outline_outlined,
            title: 'Delete  account',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
            },
          ),
        ],
      ),
    );
  }
}
