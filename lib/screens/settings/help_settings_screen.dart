import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/setting_item.dart';
import 'future_todo_screen.dart';
import 'help/help_appinfo_settings_screen.dart';

class HelpSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        children: <Widget>[
          SettingItem(
            icon: Icons.help_outline,
            title: 'FAQ',
            onTap: () {
              String url = 'https://faq.whatsapp.com/';
              _launchURL(url);
            },
          ),
          SettingItem(
            icon: Icons.group_outlined,
            title: 'Contact us',
            subtitle: 'Questions? Need help?',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
            },
          ),
          SettingItem(
            icon: Icons.insert_drive_file_outlined,
            title: 'Terms and Privacy Policy',
            onTap: () {
              String url = 'https://whatsapp.com/legal';
              _launchURL(url);
            },
          ),
          SettingItem(
            icon: Icons.info_outline,
            title: 'App info',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HelpAppInfoSettingsScreen()));
            },
          )
        ],
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
