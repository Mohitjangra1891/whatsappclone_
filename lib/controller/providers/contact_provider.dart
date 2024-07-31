import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/screens/auth/create_profile.dart';

import '../../model/CGUserModel.dart';
import '../../utils/CGConstant.dart';

class contact_provider extends ChangeNotifier {
  List<Contact> contacts = [];

  void getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        contacts.removeWhere((contact) => contact.phones.isEmpty);
      }
    } catch (e) {
      log("error getting contacts$e");
      debugPrint(e.toString());
    }
    // log(" contacts$contacts");

    notifyListeners();
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          create_profile_screen().launch(context);
        }
      }

      if (!isFound) {
        snackBar(
          context,
          title: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      snackBar(context, title: e.toString());
    }
  }
}
