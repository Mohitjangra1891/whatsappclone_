import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/utils/CGConstant.dart';

import '../../model/chat_contact.dart';
import '../../model/message_model.dart';
import '../../utils/CGImages.dart';

class homepage_Provider extends ChangeNotifier {
  int tabIndex = 1;
  List<ChatContact> chatContact = [];
  // List<List<MessageModel>> chat_messages = [];

  // Initialize the stream and update groups list
  void initializeGroupsStream() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .listen((querySnapshot) async {
      List<ChatContact> contacts = [];
      for (var document in querySnapshot.docs) {
        var chatContact = ChatContact.fromMap(document.data());

        // get_chat_messages(chatContact.contactId);

        contacts.add(
          ChatContact(
            name: chatContact.name,
            profilePic: chatContact.profilePic!.length != 0
                ? chatContact.profilePic
                : demoProfile,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }

      chatContact = contacts;
      notifyListeners();
    });
  }

  // void get_chat_messages(String ID) async {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(auth.currentUser!.uid)
  //       .collection('chats')
  //       .doc(ID)
  //       .collection('messages')
  //       .orderBy('timeSent', descending: true)
  //       .snapshots()
  //       .asyncMap((querySnapshot) {
  //     List<MessageModel> messages = [];
  //     for (var document in querySnapshot.docs) {
  //       messages.add(MessageModel.fromMap(document.data()));
  //     }
  //     chat_messages.add(messages);
  //     notifyListeners();
  //   }).listen((messages) async {});
  // }

  void change_tabIndex(int index) {
    tabIndex = index;
    notifyListeners();
  }
}
