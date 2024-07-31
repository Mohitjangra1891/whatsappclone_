import 'dart:developer';

import 'package:flutter/material.dart';

import '../utils/CGConstant.dart';

class MessageReply {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReply(this.message, this.isMe, this.messageEnum);
}

class MessageReplyNotifier extends ChangeNotifier {
  MessageReply? _messageReply;

  MessageReply? get messageReply => _messageReply;

  void updateMessageReply(String message, bool isMe, MessageEnum messageEnum) {
    // log("Messagereply notifier update message$message");
    _messageReply = MessageReply(message, isMe, messageEnum);
    notifyListeners();
  }

  void clearMessageReply() {
    _messageReply = null;
    notifyListeners();
  }
}
