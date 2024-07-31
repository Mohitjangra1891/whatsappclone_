import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/model/CGChatModel.dart';
import 'package:whatsappclone/utils/CGConstant.dart';

import '../../model/CGUserModel.dart';
import '../../model/status_Model.dart';
import '../providers/home_page_provider.dart';
import 'firebase_service.dart';

String getFileType(File file) {
  final extension = _getFileExtension(file);
  if (['jpg', 'jpeg', 'png'].contains(extension)) {
    return 'image';
  } else if (['mp4', 'mov', 'avi'].contains(extension)) {
    return 'video';
  }
  return 'unknown';
}

String _getFileExtension(File file) {
  return file.path.split('.').last.toLowerCase();
}

String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    // Format as HH:mm AM/PM
    final formatter = DateFormat('h:mm a');
    return formatter.format(timestamp);
  } else {
    // Format as HH:mm AM/PM
    final formatter = DateFormat('h:mm a');
    return formatter.format(timestamp);
  }
}

Future<List<Contact>> getAll() async {
  try {
    if (!await FlutterContacts.requestPermission()) return [];
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    contacts.removeWhere((contact) => contact.phones.isEmpty);
    return contacts;
  } catch (e) {
    log(e);
  }
  return [];
}

String removePhoneDecoration(String phone) {
  return phone.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');
}

class statusService {
  static Future<int> getImageFileSize(File file) async {
    int fileSize = file.lengthSync();
    // print("File Size is: $fileSize");
    return fileSize;
  }

  static Future<String> resizeAndUploadImage(File file, String ref) async {
    try {
      String fileType = getFileType(file);

      if (fileType == "image") {
        // Resize the image and get the compressed bytes
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: 1080,
          minHeight: 720,
          quality: 80,
          // rotate: 180,
        );

        if (compressedBytes == null) {
          log("Image compression failedImage compression failedImage compression failedImage compression failedImage compression failedImage compression failed ");

          throw Exception('Image compression failed');
        }

        var originalSize = await getImageFileSize(file);
        var compressedSize = compressedBytes.lengthInBytes;

        print("Original Image Size: $originalSize bytes");
        print("Compressed Image Size: $compressedSize bytes");
        // Get a reference to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(ref);

        // Upload the compressed bytes to Firebase Storage
        final uploadTask = storageRef.putData(Uint8List.fromList(compressedBytes));

        // Await the upload task completion
        final snapshot = await uploadTask.whenComplete(() {});

        // Get the download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();

        print('Upload complete: $downloadUrl');

        return downloadUrl;
      } else if (fileType == "video") {
        final String url = await firebase_service.storeFileToFirebase(
          ref,
          file,
        );
        return url;
      } else {
        throw Exception('Unsupported file type');
      }
    } catch (e) {
      print('Error: $e');
      log("Failed to upload image -- image compression ");

      throw Exception('Failed to upload image ');
    }
  }

  static Future<void> uploadFileStatus({
    required BuildContext context,
    required String username,
    required String uID,
    required File statusImage,
    required String phoneNumber,
    required String profileImage,
    required VoidCallback onError,
  }) async {
    try {
      log("Attempting to upload file status");
      final statusId = const Uuid().v4();
      // final String activeUser = context.read<auth_Provider>().user!.uid;
      // final String url = await _ref.read(storageRepositoryProvider).uploadFile(
      //       path: '/status/$statusId$activeUser',
      //       file: statusImage,
      //     );

      // final String url = await firebase_service.storeFileToFirebase(
      //   'status/$statusId$uID',
      //   statusImage,
      // );
      final String url = await resizeAndUploadImage(statusImage, 'status/$statusId$uID');
      final contacts = await getAll();

      final List<String> whitelist = [];
      for (Contact entry in contacts) {
        // Check if the contact is registered on the app
        final phone = removePhoneDecoration(
            (entry.phones[0].normalizedNumber.isEmpty ? entry.phones[0].number : entry.phones[0].normalizedNumber));

        final userModel = await firestore
            .collection('users')
            .withConverter<UserModel>(
              fromFirestore: (snapshot, _) => UserModel.fromMap(snapshot.data()!),
              toFirestore: (user, _) => user.toMap(),
            )
            .where('phoneNumber', isEqualTo: phone)
            .get();

        if (userModel.docs.isNotEmpty) {
          final UserModel model = userModel.docs[0].data();
          whitelist.add(model.uid);
        }
      }
      final existingStatuses = await firestore
          .collection('status')
          .withConverter<StatusModel>(
            fromFirestore: (snapshot, _) => StatusModel.fromMap(snapshot.data()!),
            toFirestore: (status, _) => status.toMap(),
          )
          .where('uid', isEqualTo: uID)
          .get();

      if (existingStatuses.docs.isNotEmpty) {
        // We have an existing status
        final status = existingStatuses.docs[0].data();
        await firestore
            .collection('status')
            .withConverter<StatusModel>(
              fromFirestore: (snapshot, _) => StatusModel.fromMap(snapshot.data()!),
              toFirestore: (status, _) => status.toMap(),
            )
            .doc(existingStatuses.docs[0].id)
            .update({
          'photoUrl': [...status.photoUrl, url],
          'lastStatus': StatusType.image.name.toString(),
        });
        return;
      }

      final status = StatusModel(
        uid: uID,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: [url],
        createdAt: DateTime.now(),
        profileImage: profileImage,
        statusId: statusId,
        texts: {},
        whitelist: whitelist,
        lastStatus: StatusType.image,
        seenBy: const [],
        isSeen: false,
      );

      await firestore
          .collection('status')
          .withConverter<StatusModel>(
            fromFirestore: (snapshot, _) => StatusModel.fromMap(snapshot.data()!),
            toFirestore: (status, _) => status.toMap(),
          )
          .doc(statusId)
          .set(status)
          .whenComplete(() {
        log("status updated successfully");
        log("status updated successfully");
        log("status updated successfully");
        log("status updated successfully");
        log("status updated successfully");
      });
    } catch (e) {
      log(e);
      onError();
    }
  }
}
