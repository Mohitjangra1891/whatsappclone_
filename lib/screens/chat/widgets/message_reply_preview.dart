import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/utils/AppColors.dart';

import '../../../model/message_reply.dart';
import 'display_text_image_gif.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void cancelReply() {
      Provider.of<MessageReplyNotifier>(context, listen: false)
          .clearMessageReply();
    }

    final messageReply =
        Provider.of<MessageReplyNotifier>(context).messageReply;

    return Container(
      width: 350,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: appBackgroundColorDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe ? 'me' : 'Opposite',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
                onTap: () => cancelReply(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DisplayTextImageGIF(
            message: messageReply.message,
            type: messageReply.messageEnum,
            maxlines: 3,
          ),
        ],
      ),
    );
  }
}
