import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/screens/homePage.dart';

import '../../model/CGUserModel.dart';
import '../../utils/CGConstant.dart';

class firebase_service {
  static Future<void> update_userName(String newName, BuildContext context) async {
    log(" name updating to $newName");
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'name': newName,
      }).whenComplete(() {
        context.read<auth_Provider>().set_user_NAME(newName);
      });
    } catch (e) {
      log(" error $e");
    }
  }

  static Future<void> update_user_profileImage(File? newImage, BuildContext context) async {
    log(" profile image updating to $newImage");
    try {
      String photoUrl = context.read<auth_Provider>().user_profileImage!;

      if (newImage == null) {
      } else {
        photoUrl = await add_userProfileImage_to_Storage(context, newImage);
        await firestore.collection('users').doc(auth.currentUser!.uid).update({
          'profilePic': photoUrl,
        }).whenComplete(() {
          context.watch<auth_Provider>().set_user_ProfileImage(photoUrl);
        });
      }
    } catch (e) {
      log(" error $e");
    }
  }

  static Future<void> saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = context.read<auth_Provider>().user_profileImage ??
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      if (profilePic == null) {
      } else {
        photoUrl = await add_userProfileImage_to_Storage(context, profilePic);
      }

      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap()).whenComplete(() {
        log("data added successfully");
        context.read<auth_Provider>().set_user_ProfileImage(photoUrl);
      });
      context.read<auth_Provider>().fetchUserData(auth.currentUser!.uid);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const homePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      snackBar(context, title: e.toString());
    }
  }

  static Future<String> add_userProfileImage_to_Storage(BuildContext context, File image) async {
    String imageName = '${auth.currentUser?.phoneNumber}';
    Reference ref = storage.ref().child('profile_images').child(imageName);
    await ref.putFile(File(image.path));
    String imageURL = await ref.getDownloadURL();
    return imageURL;
  }

  static Future<String> storeFileToFirebase(String ref, File file) async {
    UploadTask uploadTask = storage.ref().child(ref).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<bool> checkUser() async {
    bool userPresent = false;
    try {
      await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: auth.currentUser!.phoneNumber)
          .get()
          .then((value) {
        value.size > 0 ? userPresent = true : userPresent = false;
        log(value.toString());
      });
    } catch (e) {
      log(e.toString());
    }
    log("user present :" + userPresent.toString());
    return userPresent;
  }

  static void setUserState(bool isOnline) async {
    log(" change isonline to $isOnline");
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      log(" error $e");
    }

    log(" change isonline to $isOnline");
  }

  static Future<UserModel?> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  Stream<UserModel> userData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }
  // Future<void> updateUserData(UserModel user) async {
  //   try {
  //     await firestore.collection('users').doc(user.uid).update(user.toMap());
  //   } catch (e) {
  //     print('Error updating user data: $e');
  //   }
  // }
}
