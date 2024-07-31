import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/home_page_provider.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/utils/CGImages.dart';

import '../../model/chat_contact.dart';
import '../../utils/CGColors.dart';
import '../../utils/CGConstant.dart';
import '../../widgets/dailogs.dart';
import '../chat/message_screen.dart';

class chat_screen extends StatefulWidget {
  chat_screen({
    super.key,
  });

  @override
  State<chat_screen> createState() => _chat_screenState();
}

class _chat_screenState extends State<chat_screen>
    with AutomaticKeepAliveClientMixin<chat_screen> {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    context.read<homepage_Provider>().initializeGroupsStream();
  }

  void onTapProfileChatItem(BuildContext context, ChatContact chat) {
    Dialog profileDialog = DialogHelpers.getProfileDialog(
      context: context,
      id: chat.contactId,
      imageUrl: chat.profilePic ?? demoProfile,
      name: chat.name,
    );
    showDialog(
        context: context, builder: (BuildContext context) => profileDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Consumer<homepage_Provider>(builder: (context, homepageProvider, _) {
            final chatContacts = homepageProvider.chatContact;
            // final chatContacts_messages = homepageProvider.chat_messages;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: chatContacts.length,
              itemBuilder: (context, index) {
                var chatContactData = chatContacts[index];
                // var chat_messages = chatContacts_messages[index];
                // // int unseenMessagesCount = chat_messages
                // //     .where((message) =>
                // //         !message.isSeen &&
                // //         message.recieverid == auth.currentUser!.uid)
                // //     .length;
                //
                // bool isLastMessageByMe = chat_messages.isNotEmpty &&
                //     chat_messages.first.senderId == auth.currentUser!.uid;
                //
                // bool isLastMessageSeenByOther = chat_messages.isNotEmpty &&
                //     chat_messages.first.senderId == auth.currentUser!.uid &&
                //     chat_messages.first.isSeen;
                //
                // log("isLastMessageSeenByOther$isLastMessageSeenByOther");
                // log("islast message by me$isLastMessageByMe");
                // log("unseenMessagesCount$unseenMessagesCount  ");
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return message_screen(
                            name: chatContactData.name,
                            uid: chatContactData.contactId,
                            isGroupChat: false,
                            profilePic: chatContactData.profilePic,
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            chatContactData.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chatContactData.lastMessage,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          leading: GestureDetector(
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  chatContactData.profilePic ?? demoProfile),
                              radius: 29,
                            ),
                            onTap: () {
                              onTapProfileChatItem(context, chatContactData);
                            },
                          ),
                          trailing: Text(
                            DateFormat.Hm().format(chatContactData.timeSent),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
// const Divider(color: dividerColor, indent: 85),
                  ],
                );
              },
            );
          }),
          const SizedBox(height: 24),
          Divider(
            indent: 8,
            endIndent: 8,
            height: 1,
            color: appStore.isDarkModeOn ? Colors.white10 : Colors.black12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 18,
                  color: appStore.isDarkModeOn ? greyColor : iconPrimaryColor,
                ),
                const SizedBox(width: 4),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: const [
                      TextSpan(
                        text: 'Your personal messages are ',
                        style: TextStyle(color: grey),
                      ),
                      TextSpan(
                        text: 'end-to-end encrypted',
                        style: TextStyle(color: tabColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class EmptyChatList extends StatelessWidget {
  const EmptyChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 84),
          SizedBox(height: 25),
          Text('No chats yet'),
          SizedBox(height: 180),
        ],
      ),
    );
  }
}

// Column(
// children: [
// StreamBuilder<List<Group>>(
// stream: chat_service.getChatGroups(),
// builder: (context, snapshot) {
// if (snapshot.connectionState == ConnectionState.waiting) {
// return Loader();
// }
//
// return ListView.builder(
// shrinkWrap: true,
// itemCount: snapshot.data!.length,
// itemBuilder: (context, index) {
// var groupData = snapshot.data![index];
//
// return Column(
// children: [
// InkWell(
// onTap: () {
// Navigator.push(context,
// MaterialPageRoute(builder: (context) {
// return message_screen(
// name: groupData.name,
// uid: groupData.groupId,
// isGroupChat: true,
// profilePic: groupData.groupPic,
// );
// }));
// },
// child: Padding(
// padding: const EdgeInsets.only(bottom: 8.0),
// child: ListTile(
// title: Text(
// groupData.name,
// style: const TextStyle(
// fontSize: 18,
// ),
// ),
// subtitle: Padding(
// padding: const EdgeInsets.only(top: 6.0),
// child: Text(
// groupData.lastMessage,
// style: const TextStyle(fontSize: 15),
// ),
// ),
// leading: CircleAvatar(
// backgroundImage: NetworkImage(
// groupData.groupPic,
// ),
// radius: 30,
// ),
// trailing: Text(
// DateFormat.Hm().format(groupData.timeSent),
// style: const TextStyle(
// color: Colors.grey,
// fontSize: 13,
// ),
// ),
// ),
// ),
// ),
// const Divider(color: dividerColor, indent: 85),
// ],
// );
// },
// );
// }),
// StreamBuilder<List<ChatContact>>(
// stream: chat_service.getChatContacts(),
// builder: (context, snapshot) {
// if (snapshot.connectionState == ConnectionState.waiting) {
// return CircularProgressIndicator(
// color: appStore.isDarkModeOn
// ? Colors.white70
//     : scaffoldDarkColor,
// );
// }
//
// return ListView.builder(
// shrinkWrap: true,
// itemCount: snapshot.data!.length,
// itemBuilder: (context, index) {
// var chatContactData = snapshot.data![index];
//
// return Column(
// children: [
// InkWell(
// onTap: () {
// // Navigator.pushNamed(
// //   context,
// //   MobileChatScreen.routeName,
// //   arguments: {
// //     'name': chatContactData.name,
// //     'uid': chatContactData.contactId,
// //     'isGroupChat': false,
// //     'profilePic': chatContactData.profilePic,
// //   },
// // );
// Navigator.push(context,
// MaterialPageRoute(builder: (context) {
// return message_screen(
// name: chatContactData.name,
// uid: chatContactData.contactId,
// isGroupChat: false,
// profilePic: chatContactData.profilePic,
// );
// }));
// },
// child: Padding(
// padding: const EdgeInsets.only(bottom: 8.0),
// child: ListTile(
// title: Text(
// chatContactData.name,
// style: const TextStyle(
// fontSize: 18,
// fontWeight: FontWeight.w600),
// ),
// subtitle: Padding(
// padding: const EdgeInsets.only(top: 2.0),
// child: Text(
// chatContactData.lastMessage,
// style: const TextStyle(
// fontSize: 15, color: Colors.white70),
// ),
// ),
// leading: CircleAvatar(
// backgroundImage: NetworkImage(
// chatContactData.profilePic,
// ),
// radius: 28,
// ),
// trailing: Text(
// DateFormat.Hm()
//     .format(chatContactData.timeSent),
// style: const TextStyle(
// color: Colors.grey,
// fontSize: 13,
// ),
// ),
// ),
// ),
// ),
// // const Divider(color: dividerColor, indent: 85),
// ],
// );
// },
// );
// }),
// ],
// ),
