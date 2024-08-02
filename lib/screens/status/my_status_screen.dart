import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/model/status_Model.dart';
import 'package:whatsappclone/screens/status/widgets/status_camera_screen.dart';

import '../../controller/services/status_servicce.dart';
import '../../main.dart';
import '../../utils/CGColors.dart';

class my_status_screen extends StatelessWidget {
  final StatusModel status;

  const my_status_screen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My status'),
        titleSpacing: 0.0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Divider height
          child: Divider(
            color: Colors.white30, // Divider color
            height: 0.0,
            thickness: 0.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: status.photoUrl.length,
              itemBuilder: (context, index) {
                final isDark = appStore.isDarkModeOn;
                final lastStatus = status.lastStatus;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    onTap: () {},
                    trailing: PopupMenuButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      iconColor: tabColor,
                      color: Colors.transparent,
                      position: PopupMenuPosition.under,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: () {
                              // ref.read(statusControllerProvider).deleteUserStatus(
                              //   model.statusId,
                              //   context,
                              // );
                            },
                            child: const ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
                            ),
                          ),
                        ];
                      },
                    ),
                    subtitle: Text(
                      formatTimeAgo(status.createdAt),
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: lastStatus == StatusType.image ? NetworkImage(status.photoUrl[index]) : null,
                      child: lastStatus == StatusType.text
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: Color(status.texts.values.last),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                 child: SizedBox(
                                  width: 90,
                                  child: Text(
                                    status.texts.keys.last,
                                    textAlign: TextAlign.center,
                                    maxLines: null,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      '${status.seenBy.length} views',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  indent: MediaQuery.of(context).size.width * 0.15,
                  endIndent: 0,
                  height: 1,
                  color: appStore.isDarkModeOn ? Colors.white10 : Colors.black12,
                );
              },
            ),
            const SizedBox(height: 1),
            Divider(
              indent: 8,
              endIndent: 8,
              height: 1,
              color: appStore.isDarkModeOn ? Colors.white10 : Colors.black12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 18,
                    color: appStore.isDarkModeOn ? greyColor : iconPrimaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: const [
                          TextSpan(
                            text: 'Your status updates are  ',
                            style: TextStyle(color: grey),
                          ),
                          TextSpan(
                            text: 'end-to-end encrypted. ',
                            style: TextStyle(color: tabColor),
                          ),
                          TextSpan(
                            text: 'They will disappear after 24 hours.',
                            style: TextStyle(color: grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 1,
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              // const selectContactsScreen().launch(context);
            },
            child: const Icon(Icons.create, color: secondaryColor),
          ),
          8.height,
          FloatingActionButton(
            heroTag: 2,
            backgroundColor: buttonColor,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => status_CameraScreen(),
                ),
              );
            },
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
