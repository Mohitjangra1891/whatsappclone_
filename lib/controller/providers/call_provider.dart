import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/call_model.dart';
import '../../model/chat_contact.dart';
import '../../utils/CGConstant.dart';

class call_Provider extends ChangeNotifier {
  List<call_history> recent_calls = [];

  // List<List<MessageModel>> chat_messages = [];

  // Initialize the stream and update groups list
  void initializeGroupsStream() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('calls')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .listen((querySnapshot) async {
      List<call_history> history = [];
      for (var document in querySnapshot.docs) {
        var call_data = call_history.fromMap(document.data());

        // get_chat_messages(chatContact.contactId);

        history.add(call_history(
            callerId: call_data.callerId,
            callerName: call_data.callerName,
            callerPic: call_data.callerPic,
            receiverId: call_data.receiverId,
            receiverName: call_data.receiverName,
            receiverPic: call_data.receiverPic,
            callId: call_data.callId,
            hasDialled: call_data.hasDialled,
            missedOrDeclined: call_data.missedOrDeclined,
            date: call_data.date));
      }
      recent_calls = history;
      notifyListeners();
    });
  }
}
