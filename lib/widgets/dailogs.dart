import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/main.dart';

import '../screens/chat/message_screen.dart';
import '../utils/CGColors.dart';

class DialogHelpers {
  static Dialog getProfileDialog({
    required BuildContext context,
    required String id,
    required String imageUrl,
    required String name,
    bool? isGRoup,
    GestureTapCallback? onTapMessage,
    GestureTapCallback? onTapCall,
    GestureTapCallback? onTapVideoCall,
    GestureTapCallback? onTapInfo,
  }) {
    Widget image = imageUrl == null
        ? SizedBox(
            child: Container(
            decoration: BoxDecoration(
              color: appStore.scaffoldBackground,
            ),
            height: MediaQuery.of(context).size.height * 0.45,
            child: Center(
              child: Icon(
                Icons.account_circle,
                color: appStore.iconColor,
                size: 120.0,
              ),
            ),
          ))
        : Image(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.maxFinite - 40,
            image: CachedNetworkImageProvider(imageUrl),
            alignment: Alignment.center,
            fit: BoxFit.cover,
          );
    return new Dialog(
      shape: const RoundedRectangleBorder(),
      child: Container(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                child: Stack(
                  children: <Widget>[
                    image,
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              name,
                              style: TextStyle(
                                color: appStore.textPrimaryColor,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.message),
                    onPressed: onTapMessage ??
                        () => _defOnTapMessage(
                            context, id, name, imageUrl, isGRoup),
                    color: appStore.iconColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: onTapCall ?? () => _defOnTapCall(context),
                    color: appStore.iconColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam),
                    onPressed:
                        onTapVideoCall ?? () => _defOnTapVideoCall(context),
                    color: appStore.iconColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: onTapInfo ?? () => _defOnTapInfo(context, id),
                    color: appStore.iconColor,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  static _defOnTapMessage(BuildContext context, String id, String user_name,
      String profile_pic, bool? isgroup) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return message_screen(
        name: user_name,
        uid: id,
        isGroupChat: isgroup ?? false,
        profilePic: profile_pic,
      );
    })).then((result) {
      Navigator.of(context).pop();
    });
  }

  static _defOnTapCall(BuildContext context) {
    snackBar(context,
        title: "Audio call button pressed",
        duration: const Duration(seconds: 1));
  }

  static _defOnTapVideoCall(BuildContext context) {
    snackBar(context,
        title: "Video call button pressed",
        duration: const Duration(seconds: 1));
  }

  static _defOnTapInfo(BuildContext context, String id) {
    log("pressed on info");
    // Application.router
    //     .navigateTo(
    //   context,
    //   //"/profile?id=$id",
    //   Routes.futureTodo,
    //   transition: TransitionType.inFromRight,
    // )
    //     .then((result) {
    //   Navigator.of(context).pop();
    // });
  }

  static showRadioDialog(List allOptions, String title, Function getText,
      BuildContext context, option, bool isActions, onChanged) {
    showDialog(
        barrierDismissible: !isActions,
        context: context,
        builder: (context) {
          List<Widget> widgets = [];
          for (dynamic opt in allOptions) {
            widgets.add(
              ListTileTheme(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RadioListTile(
                  value: opt,
                  title: Text(
                    getText(opt),
                    style: TextStyle(fontSize: 18.0),
                  ),
                  groupValue: option,
                  onChanged: (value) {
                    onChanged(value);
                    Navigator.of(context).pop();
                  },
                  activeColor: secondaryColor,
                ),
              ),
            );
          }

          return AlertDialog(
            contentPadding: EdgeInsets.only(bottom: 8.0),
            title: Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widgets,
                    ),
                  ),
                ),
              ],
            ),
            actions: !isActions
                ? null
                : <Widget>[
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
          );
        });
  }
}
