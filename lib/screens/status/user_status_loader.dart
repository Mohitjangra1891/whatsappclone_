import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/screens/status/status_image_preview.dart';

import '../../controller/services/status_servicce.dart';
import '../../model/status_Model.dart';
import '../../utils/AppColors.dart';
import '../../utils/CGColors.dart';
import '../../utils/common_Widgets.dart';
import 'controller/status_controller.dart';
import 'my_status_screen.dart';

class UserStatusLoader extends ConsumerWidget {
  const UserStatusLoader({super.key});

  bool is_before_24(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours <= 24) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusLive = ref.watch(userStatusStreamProvider);
    return statusLive.when(
      data: (maybeStatus) {
        return maybeStatus.match(
          () => UserListTile(
            onTap: () async {
              final image = await pickImageFromGallery(context);
              if (image != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StatusImageConfirmPage(file: image)));
              } else {}
            },
          ),
          (model) {
            // Example usage
            // print(formatTimeAgo(model.createdAt));
            final lastStatus = model.lastStatus;
            final isBefore24 = is_before_24(model.createdAt);
            return isBefore24
                ? UserListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => my_status_screen(
                                    status: model,
                                  )));
                    },
                    leading: _getThumbnail(model.isSeen, model.photoUrl.length, model.photoUrl.last),
                    trailing: PopupMenuButton(
                      splashRadius: 18,
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
                      formatTimeAgo(model.createdAt),
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : UserListTile(
                    onTap: () async {
                      final image = await pickImageFromGallery(context);
                      if (image != null) {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => StatusImageConfirmPage(file: image)));
                      } else {}
                    },
                  );
          },
        );
      },
      error: (err, trace) => UnhandledError(error: err.toString()),
      loading: () => const WorkProgressIndicator(),
    );
  }

  Widget _getThumbnail(bool isSeen, int statusNum, String lastImage) {
    return Container(
      width: 60.0,
      height: 60.0,
      child: CustomPaint(
        painter: StatusBorderPainter(isSeen: isSeen, statusNum: statusNum),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: CachedNetworkImageProvider(lastImage),
                fit: BoxFit.cover,
              ),
              borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
              border: Border.all(
                color: appStore.isDarkModeOn ? appBackgroundColorDark : Colors.white,
                width: 2.0,
              )),
        ),
      ),
    );
  }
}

degreeToRad(double degree) {
  return degree * pi / 180;
}

class StatusBorderPainter extends CustomPainter {
  bool isSeen;
  int statusNum;

  StatusBorderPainter({required this.isSeen, required this.statusNum});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = new Paint()
      ..isAntiAlias = true
      ..strokeWidth = 4.0
      ..color = isSeen ? Colors.grey : tabColor
      ..style = PaintingStyle.stroke;
    drawArc(canvas, paint, size, statusNum);
  }

  void drawArc(Canvas canvas, Paint paint, Size size, int count) {
    if (count == 1) {
      canvas.drawArc(
          new Rect.fromLTWH(0.0, 0.0, size.width, size.height), degreeToRad(0), degreeToRad(360), false, paint);
    } else {
      double degree = -90;
      double arc = 360 / count;
      for (int i = 0; i < count; i++) {
        canvas.drawArc(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), degreeToRad(degree + 4),
            degreeToRad(arc - 8), false, paint);
        degree += arc;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class UserListTile extends ConsumerWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final VoidCallback? onTap;
  const UserListTile({
    super.key,
    this.leading,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = appStore.isDarkModeOn;
    return ListTile(
      onTap: onTap,
      trailing: trailing,
      leading: leading ??
          Stack(
            children: [
              const Icon(
                Icons.account_circle,
                size: 54,
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
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle ?? Text('Tap to add status update'),
    );
  }
}

class UnhandledError extends StatelessWidget {
  final String error;
  const UnhandledError({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        error,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.red,
        ),
      ),
    );
  }
}
// CircleAvatar(
// radius: 30,
// backgroundImage: lastStatus == StatusType.image ? NetworkImage(model.photoUrl.last) : null,
// child: lastStatus == StatusType.text
// ? CircleAvatar(
// radius: 30,
// backgroundColor: Color(model.texts.values.last),
// child: FittedBox(
// fit: BoxFit.scaleDown,
// child: SizedBox(
// width: 100,
// child: Text(
// model.texts.keys.last,
// textAlign: TextAlign.center,
// maxLines: null,
// style:
// const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
// ),
// ),
// ),
// )
//     : null,
// )
