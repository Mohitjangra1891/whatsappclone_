import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/services/chat_service.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/model/message_model.dart';
import 'package:whatsappclone/screens/chat/widgets/sender_message_card.dart';

import '../../../model/message_reply.dart';
import '../../../utils/CGConstant.dart';
import 'my_message_card.dart';

class message_box extends StatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const message_box({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<message_box> createState() => _message_boxState();
}

class _message_boxState extends State<message_box> {
  final ScrollController messageController = ScrollController();
  // final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   messageController.jumpTo(messageController.position.maxScrollExtent);
    // });
  }

  scrollToBottom({bool isDelayed = false}) {
    final int delay = isDelayed ? 400 : 0;
    Future.delayed(Duration(milliseconds: delay), () {
      messageController!.animateTo(messageController!.position.minScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    print("swiped");
    Provider.of<MessageReplyNotifier>(context, listen: false)
        .updateMessageReply(message, isMe, messageEnum);
    // ref.read(messageReplyProvider.state).update(
    //       (state) => MessageReply(
    //         message,
    //         isMe,
    //         messageEnum,
    //       ),
    //     );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
        stream: widget.isGroupChat
            ? chat_service.getGroupChatStream(widget.recieverUserId)
            : chat_service.getChatStream(widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (messageController.hasClients) {
              messageController
                  .jumpTo(messageController.position.minScrollExtent);
            }
          });

          return ListView.builder(
            // padding: EdgeInsets.only(bottom: 74),
            reverse: true,
            shrinkWrap: true,
            controller: messageController,
            itemCount: snapshot.data!.length,
            // dragStartBehavior: ,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              var timeSent = DateFormat.Hm().format(messageData.timeSent);

              if (!messageData.isSeen &&
                  messageData.recieverid ==
                      FirebaseAuth.instance.currentUser!.uid) {
                chat_service.setChatMessageSeen(
                  context,
                  widget.recieverUserId,
                  messageData.messageId,
                );
              }
              if (messageData.senderId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: messageData.text,
                  date: timeSent,
                  type: messageData.type,
                  repliedText: messageData.repliedMessage,
                  username: messageData.repliedTo,
                  repliedMessageType: messageData.repliedMessageType,
                  onLeftSwipe: () => onMessageSwipe(
                    messageData.text,
                    true,
                    messageData.type,
                  ),
                  isSeen: messageData.isSeen,
                );
              }
              return SenderMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                onRightSwipe: () => onMessageSwipe(
                  messageData.text,
                  false,
                  messageData.type,
                ),
                repliedText: messageData.repliedMessage,
              );
            },
          );
        });
  }
}
