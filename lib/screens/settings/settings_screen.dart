import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/screens/settings/account_settings_screen.dart';
import 'package:whatsappclone/screens/settings/your_profile_screen.dart';
import 'package:whatsappclone/utils/CGImages.dart';
import '../../utils/CGColors.dart';
import '../../widgets/setting_item.dart';
import 'account/account_privacy_settings_screen.dart';
import 'chats_settings_screen.dart';
import 'future_todo_screen.dart';
import 'help/android_intent_helpers.dart';
import 'help_settings_screen.dart';
import 'notifications_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          titleSpacing: 0.0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Divider height
            child: Divider(
              color: Colors.white30, // Divider color
              height: 0.0,
              thickness: 0.0,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              leading: Hero(
                tag: 'profile-pic',
                child: Container(
                  // color: Colors.grey.shade400,
                  // height: 70,
                  child: CircleAvatar(
                    radius: 32.0,
                    backgroundImage: CachedNetworkImageProvider(
                        context.watch<auth_Provider>().user_profileImage ?? placeholder_profile),
                  ),
                ),
              ),
              title: Text(
                context.watch<auth_Provider>().user_name,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Hey there! I am using whatsapp...',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              trailing: const Icon(
                Icons.qr_code,
                color: tabColor,
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => YourProfileScreen()));
              },
            ),
            const Divider(
              height: 0.0,
              thickness: 0.0,
              color: Colors.white24, // Divider color
            ),
            SettingItem(
                icon: Icons.vpn_key_outlined,
                title: 'Account',
                subtitle: 'Privacy, security, change number',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingsScreen()));
                }),
            SettingItem(
              icon: Icons.lock_outline,
              title: 'Privacy',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPrivacySettingsScreen()));
              },
            ),
            SettingItem(
                icon: Icons.favorite_outline,
                title: 'Favorites',
                subtitle: 'Add, reorder, remove',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
                }),
            SettingItem(
                icon: Icons.chat_outlined,
                title: 'Chats',
                subtitle: 'Backup, history, wallpaper',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsSettingsScreen()));
                }),
            SettingItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Message, group & call tones',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsSettingsScreen()));
                }),
            SettingItem(
                icon: Icons.data_usage,
                title: 'Data and storage usage',
                subtitle: 'Network usage, auto-download',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
                }),
            SettingItem(
                icon: Icons.language_outlined,
                title: 'App language',
                subtitle: 'English (device\'s language)',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
                }),
            SettingItem(
                icon: Icons.help_outline,
                title: 'Help',
                subtitle: 'FAQ, contact us, privacy policy',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSettingsScreen()));
                }),
            Builder(builder: (context) {
              return SettingItem(
                icon: Icons.group_outlined,
                title: 'Invite a friend',
                onTap: () {
                  AndroidIntentHelpers.inviteFriend(context);
                },
              );
            }),
          ],
        ));
  }
}
