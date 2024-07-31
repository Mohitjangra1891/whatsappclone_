import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/controller/services/call_service.dart';
import 'package:whatsappclone/controller/services/chat_service.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/screens/chat/widgets/bottom_chat_field.dart';
import 'package:whatsappclone/screens/chat/widgets/message_box.dart';
import 'package:whatsappclone/utils/CGImages.dart';

import '../../model/CGUserModel.dart';
import '../call/call_pickUP_screen.dart';

class message_screen extends StatelessWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String? profilePic;

  const message_screen(
      {Key? key,
      required this.name,
      required this.uid,
      required this.isGroupChat,
      this.profilePic})
      : super(key: key);

  void makeCall(BuildContext context) {
    call_service.makeCall(
      context,
      name,
      uid,
      profilePic!,
      isGroupChat,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black54,
      ),
      child: CallPickupScreen(
        scaffold: Scaffold(
          appBar: AppBar(
            // backgroundColor: appBarColor,
            // automaticallyImplyLeading: false,
            title: isGroupChat
                ? Text(name)
                : StreamBuilder<UserModel>(
                    stream: chat_service.userDataById(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        NetworkImage(profilePic ?? demoProfile),
                                    fit: BoxFit.cover),
                                shape: BoxShape.circle,
                              ),
                            ),
                            10.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      NetworkImage(profilePic ?? demoProfile),
                                  fit: BoxFit.cover),
                              shape: BoxShape.circle,
                            ),
                          ),
                          10.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                snapshot.data!.isOnline ? 'online' : 'offline',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () => makeCall(context),
                icon: const Icon(Icons.video_call),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.call),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    appStore.isDarkModeOn ? chat_bg_black : chat_bg_white),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: message_box(
                    recieverUserId: uid,
                    isGroupChat: isGroupChat,
                  ),
                ),
                BottomChatField(
                  recieverUserId: uid,
                  isGroupChat: isGroupChat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
