import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';

import '../../model/call_model.dart';
import '../../screens/call/call_screen.dart';
import '../../utils/CGConstant.dart';
import 'firebase_service.dart';

class call_service {
  static Stream<DocumentSnapshot> get callStream => firestore.collection('call').doc(auth.currentUser!.uid).snapshots();

  static Future<void> makeCall(BuildContext context, String receiverName, String receiverUid, String receiverProfilePic,
      bool isGroupChat) async {
    String callId = const Uuid().v1();
    var value = await firebase_service.fetchUserData(auth.currentUser!.uid);
    Call senderCallData = Call(
      callerId: auth.currentUser!.uid,
      callerName: value!.name,
      callerPic: value.profilePic,
      receiverId: receiverUid,
      receiverName: receiverName,
      receiverPic: receiverProfilePic,
      callId: callId,
      hasDialled: true,
    );

    Call recieverCallData = Call(
      callerId: auth.currentUser!.uid,
      callerName: value.name,
      callerPic: value.profilePic,
      receiverId: receiverUid,
      receiverName: receiverName,
      receiverPic: receiverProfilePic,
      callId: callId,
      hasDialled: false,
    );
    if (isGroupChat) {
      // makeGroupCall(senderCallData, context, recieverCallData);
    } else {
      _makeCall(senderCallData, context, recieverCallData);
    }
  }

  static Future<void> endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('call').doc(callerId).delete();
      await firestore.collection('call').doc(receiverId).delete();
    } catch (e) {
      snackBar(context, title: e.toString());
    }
  }

  static void _makeCall(
    Call senderCallData,
    BuildContext context,
    Call receiverCallData,
  ) async {
    try {
      await firestore.collection('call').doc(senderCallData.callerId).set(senderCallData.toMap());
      await firestore.collection('call').doc(senderCallData.receiverId).set(receiverCallData.toMap());

      add_to_call_history(
          context: context,
          callData: call_history(
              callerId: senderCallData.callerId,
              callerName: senderCallData.callerName,
              callerPic: senderCallData.callerPic,
              receiverId: senderCallData.receiverId,
              receiverName: senderCallData.receiverName,
              receiverPic: senderCallData.receiverPic,
              callId: senderCallData.callId,
              hasDialled: true,
              missedOrDeclined: false,
              date: DateTime.now()));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallingScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: false,
          ),
        ),
      );
    } catch (e) {
      snackBar(context, title: e.toString());
    }
  }

  // void makeGroupCall(
  //   Call senderCallData,
  //   BuildContext context,
  //   Call receiverCallData,
  // ) async {
  //   try {
  //     await firestore
  //         .collection('call')
  //         .doc(senderCallData.callerId)
  //         .set(senderCallData.toMap());
  //
  //     var groupSnapshot = await firestore
  //         .collection('groups')
  //         .doc(senderCallData.receiverId)
  //         .get();
  //     Group group = Group.fromMap(groupSnapshot.data()!);
  //
  //     for (var id in group.membersUid) {
  //       await firestore
  //           .collection('call')
  //           .doc(id)
  //           .set(receiverCallData.toMap());
  //     }
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => CallScreen(
  //           channelId: senderCallData.callId,
  //           call: senderCallData,
  //           isGroupChat: true,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     snackBar(context, title: e.toString());
  //   }
  // }

  // void endGroupCall(
  //   String callerId,
  //   String receiverId,
  //   BuildContext context,
  // ) async {
  //   try {
  //     await firestore.collection('call').doc(callerId).delete();
  //     var groupSnapshot =
  //         await firestore.collection('groups').doc(receiverId).get();
  //     Group group = Group.fromMap(groupSnapshot.data()!);
  //     for (var id in group.membersUid) {
  //       await firestore.collection('call').doc(id).delete();
  //     }
  //   } catch (e) {
  //     snackBar(context, title: e.toString());
  //   }
  // }

  static Future<void> add_to_call_history({
    required BuildContext context,
    required call_history callData,
  }) async {
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).collection('calls').doc(callData.receiverId).set(
            callData.toMap(),
          );
    } catch (e) {
      print("exception-- $e");
    }
  }
}
