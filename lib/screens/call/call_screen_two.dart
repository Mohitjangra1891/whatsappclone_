import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:whatsappclone/controller/services/call_service.dart';
import 'package:whatsappclone/screens/call/widgets/call_leave_widget.dart';
import 'package:whatsappclone/utils/widget_themes.dart';

import '../../model/call_model.dart';
import '../../utils/AppColors.dart';
import '../../utils/CGColors.dart';
import '../../utils/config/agora_config.dart';
import '../homePage.dart';

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  AgoraClient? client;
  String baseUrl = 'https://whatsapp-agora-server.vercel.app';

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Turn on wakelock feature till call is running

    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appID,
        channelName: widget.channelId,
        tokenUrl: baseUrl,
      ),
    );

    initAgora();
  }

  void initAgora() async {
    log("init agora");
    // await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await client!.initialize();
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Turn on wakelock feature till call is running
    super.dispose();
  }

  Future<bool>? _onBackPressed(BuildContext context) {
    showCallLeaveDialog(
        context, "Are you sure you want to end your call?", "Yes end call now", "No cancel & return to call", () async {
      await client!.engine.leaveChannel();
      await call_service.endCall(
        widget.call.callerId,
        widget.call.receiverId,
        context,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const homePage(),
        ),
        (route) => false,
      );
      // Navigator.pop(context);
    });
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _onBackPressed(context) ?? false;
        if (context.mounted && shouldPop) {
          // Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: client == null
            ? Loader()
            : SafeArea(
                child: Stack(
                  children: [
                    AgoraVideoViewer(
                      client: client!,
                      layoutType: Layout.oneToOne,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 25,
                        padding: EdgeInsets.all(4),
                        width: double.maxFinite,
                        color: Colors.transparent,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: Icon(Icons.arrow_back_ios_rounded)),
                            Center(
                              child: Text(
                                "end-to-end encrypted",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Flexible(
                        child: Expanded(
                          child: Container(
                            height: 100,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                                color: cardBackgroundBlackDark,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                )),
                            child: AgoraVideoButtons(
                              client: client!,
                              buttonAlignment: Alignment.topCenter,
                              verticalButtonPadding: 12,
                              disconnectButtonChild: ClipOval(
                                child: Material(
                                  color: Colors.red,
                                  child: IconButton(
                                    onPressed: () async {
                                      await client!.engine.leaveChannel();
                                      await call_service.endCall(
                                        widget.call.callerId,
                                        widget.call.receiverId,
                                        context,
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const homePage(),
                                        ),
                                        (route) => false,
                                      );
                                      // Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.call_end,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
