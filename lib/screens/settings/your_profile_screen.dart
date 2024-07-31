import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/services/firebase_service.dart';
import 'package:whatsappclone/utils/CGColors.dart';

import '../../controller/providers/auth_Provider.dart';
import '../../utils/AppColors.dart';
import '../../utils/CGConstant.dart';
import '../../utils/CGImages.dart';
import '../../utils/common_Widgets.dart';

class YourProfileScreen extends StatefulWidget {
  @override
  State<YourProfileScreen> createState() => _YourProfileScreenState();
}

class _YourProfileScreenState extends State<YourProfileScreen> {
  File? image;

  Future<void> _updateImage(BuildContext context) async {
    bool isUploading = true;

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

    image = await pickImageFromGallery(context);

    // Update Firestore with new image URL
    try {
      if (image != null) {
        // Pick image from gallery and upload to Firebase Storage
        String newImageUrl = await firebase_service.add_userProfileImage_to_Storage(context, image!);

        await firestore.collection('users').doc(auth.currentUser!.uid).update({
          'profilePic': newImageUrl,
        });

        // Update the Provider with new image URL
        Provider.of<auth_Provider>(context, listen: false).set_user_ProfileImage(newImageUrl);
      } else {
        log(" image is null ");
      }
    } catch (e) {
      log(" error $e");
    } finally {
      isUploading = false;
      // Hide loader
      Navigator.pop(context);
    }

    // Navigator.pop(context);

    // Hide loader
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = Provider.of<auth_Provider>(context).user_profileImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        titleSpacing: 0.0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Divider height
          child: Divider(
            color: Colors.white12, // Divider color
            height: 0.0,
            thickness: 0.0,
          ),
        ),
      ),
      body: Consumer<auth_Provider>(
        builder: (BuildContext context, auth_Provider value, Widget? child) {
          return ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  bottom: 16.0,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Stack(children: <Widget>[
                      Hero(
                          tag: 'profile-pic',
                          child: CircleAvatar(
                            radius: 82.0,
                            backgroundImage: CachedNetworkImageProvider(value.user_profileImage ?? placeholder_profile),
                          )),
                      Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        child: FloatingActionButton(
                            mini: true,
                            onPressed: () async {
                              await _updateImage(context);
                            },
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: tabColor,
                            )),
                      )
                    ]),
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: const Icon(
                  Icons.person_outlined,
                  color: iconColorSecondary,
                  size: 24,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Name',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      value.user_name,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'This is not your username or pin. This name will be '
                    'visible to your WhatzApp contacts.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.mode_edit_outline_outlined,
                  color: tabColor,
                ),
                onTap: () {},
              ),
              const Divider(
                height: 0.0,
                thickness: 0.0,
                indent: 72.0,
                color: Colors.white10, // Divider color
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: const Icon(
                  Icons.info_outline,
                  color: iconColorSecondary,
                  size: 24,
                ),
                title: const Text(
                  'About',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                subtitle: const Text(
                  'Hey there!, I am using WhatsApp!',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                trailing: const Icon(
                  Icons.mode_edit_outline_outlined,
                  color: tabColor,
                ),
                onTap: () {},
              ),
              const Divider(
                height: 0.0,
                thickness: 0.0,
                indent: 72.0,
                color: Colors.white10, // Divider color
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: const Icon(Icons.call_outlined, color: iconColorSecondary, size: 24),
                title: const Text(
                  'Phone',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                subtitle: Text(
                  context.read<auth_Provider>().mobileNumber,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                onTap: () {},
              )
            ],
          );
        },
      ),
    );
  }
}
