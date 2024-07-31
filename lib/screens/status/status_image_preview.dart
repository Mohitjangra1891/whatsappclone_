import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/controller/services/status_servicce.dart';
import 'package:whatsappclone/model/CGUserModel.dart';

import '../../utils/CGColors.dart';

class StatusImageConfirmPage extends StatefulWidget {
  final File file;

  const StatusImageConfirmPage({
    super.key,
    required this.file,
  });

  @override
  State<StatusImageConfirmPage> createState() => _StatusImageConfirmPageState();
}

class _StatusImageConfirmPageState extends State<StatusImageConfirmPage> {
  late bool isUploading;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUploading = false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<auth_Provider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm your Status"),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(widget.file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addStatus(context, user!);
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> addStatus(BuildContext context, UserModel userModel) async {
    isUploading = true;

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              return;
            }
            if (!isUploading) {
              Navigator.pop(context);
              return Future.value(false); // Do not switch tab yet
            }
          },
          child: const Center(
              child: CircularProgressIndicator(
            color: tabColor,
          )),
        );
      },
    );

    statusService
        .uploadFileStatus(
      username: userModel.name,
      statusImage: widget.file,
      phoneNumber: userModel.phoneNumber,
      profileImage: userModel.profilePic,
      onError: () => snackBar(context, title: "Failed to upload status. Try again."),
      context: context,
      uID: userModel.uid,
    )
        .then((value) {
      // On success
      isUploading = false;

      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 3; // Return true when the desired number of pops is reached
      });
    }).catchError((error) {
      // On error
      isUploading = false;
      snackBar(context, title: "Failed to upload status. Try again.");
      Navigator.pop(context);
      Navigator.pop(context);

      // Navigator.pushReplacementNamed(context, '/errorPage'); // Navigate to an error page
    });
    // Navigator.pop(context);
  }
}
