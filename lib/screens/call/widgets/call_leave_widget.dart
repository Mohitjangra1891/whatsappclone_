import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/utils/AppColors.dart';

class LeaveDialog extends StatefulWidget {
  final String? title;
  final String? yesText;
  final String? noText;
  final Function? onYesAction;

  LeaveDialog(
      {@required this.title,
      @required this.yesText,
      @required this.noText,
      this.onYesAction});

  @override
  _LeaveDialogState createState() => _LeaveDialogState();
}

class _LeaveDialogState extends State<LeaveDialog> {
  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: _getDialogLayout(context),
          ),
        ),
      );

  _getDialogLayout(BuildContext context) => SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: MediaQuery.of(context).size.width * 0.85,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.title ?? "",
                          style: const TextStyle(
                              color: appBackgroundColorDark, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              dismissAlertDialog(context);

                              if (widget.onYesAction != null) {
                                widget.onYesAction!();
                              }
                            },
                            child: Text(
                              widget.yesText ?? "",
                              style: const TextStyle(color: whiteColor),
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            dismissAlertDialog(context);
                          },
                          child: Text(widget.noText ?? ""),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

void dismissAlertDialog(BuildContext context) {
  Navigator.of(context).pop();
}

Future<dynamic> showCallLeaveDialog(BuildContext context, String title,
    String yesText, String noText, Function onYesAction) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return LeaveDialog(
        title: title,
        yesText: yesText,
        noText: noText,
        onYesAction: onYesAction,
      );
    },
  );
}
