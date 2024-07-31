import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/screens/status/status_image_preview.dart';

import '../../utils/CGColors.dart';
import '../../utils/common_Widgets.dart';
import '../status/user_status_loader.dart';

class status_screen extends StatefulWidget {
  const status_screen({super.key});

  @override
  State<status_screen> createState() => _status_screenState();
}

class _status_screenState extends State<status_screen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserStatusLoader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Recent updates",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }
}

class user_status extends StatelessWidget {
  const user_status({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Container(
        child: ListTile(
      onTap: () {
        pickStatusImage(context);
      },
      leading: Stack(
        children: [
          const Icon(
            Icons.circle_outlined,
            size: 60,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              shape: CircleBorder(
                side: BorderSide(
                  width: 2,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              color: Colors.black,
              child: const CircleAvatar(
                backgroundColor: kPrimaryColor,
                radius: 11,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      title: const Text(
        'My Status',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Tap to add status update',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade400,
        ),
      ),
    ));
  }
}

void pickStatusImage(BuildContext context) async {
  final image = await pickImageFromGallery(context);
  if (image != null) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StatusImageConfirmPage(file: image)));
  } else {}
}
