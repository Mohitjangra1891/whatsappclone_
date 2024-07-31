import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:whatsappclone/controller/services/call_service.dart';
import 'package:whatsappclone/screens/call/widgets/call_leave_widget.dart';
import 'package:whatsappclone/utils/widget_themes.dart';

import '../../main.dart';
import '../../model/call_model.dart';
import '../../utils/AppColors.dart';
import '../../utils/CGColors.dart';
import '../../utils/CGConstant.dart';
import '../../utils/config/agora_config.dart';
import '../../widgets/timer_widget.dart';
import '../homePage.dart';

class VideoCallingScreen extends StatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const VideoCallingScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  _VideoCallingScreenState createState() => _VideoCallingScreenState();
}

class _VideoCallingScreenState extends State<VideoCallingScreen> {
  String baseUrl = 'https://whatsapp-agora-server.vercel.app';

  bool _joined = false;
  int? _remoteUid;
  bool _switch = false;
  final _infoStrings = <String>[];
  // late RtcEngine _engine;
  bool _isFront = false;
  bool _reConnectingRemoteView = false;
  final GlobalKey<TimerViewState> _timerKey = GlobalKey();
  bool _mutedAudio = false;
  bool _mutedVideo = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Turn on wakelock feature till call is running
    initializeCalling();
  }

  @override
  void dispose() {
    engine?.leaveChannel();
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    super.dispose();
  }

  //Initialize All The Setup For Agora Video Call
  Future<void> initializeCalling() async {
    // if (AppConstants.agoraAppId.isEmpty) {
    //   setState(() {
    //     _infoStrings.add(
    //       'APP_ID missing, please provide your APP_ID in settings.dart',
    //     );
    //     _infoStrings.add('Agora Engine is not starting');
    //   });
    //   return;
    // }
    Future.delayed(Duration.zero, () async {
      // await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      var configuration = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(
            width: 1920,
            height: 1080,
          ),
          orientationMode: OrientationMode.orientationModeAdaptive);
      await engine?.setVideoEncoderConfiguration(configuration);
      await engine?.joinChannel(channelId: widget.channelId, token: baseUrl, uid: 0, options: ChannelMediaOptions());
    });
  }

  //Initialize Agora RTC Engine
  // Future<void> _initAgoraRtcEngine() async {
  //   _engine = createAgoraRtcEngine();
  //   await _engine?.initialize(RtcEngineContext(
  //       appId: AgoraConfig.appID,
  //       channelProfile: ChannelProfileType.channelProfileCommunication));
  //   await _engine?.enableVideo();
  // }

  //Switch Camera
  _onToggleCamera() {
    engine?.switchCamera().then((value) {
      setState(() {
        _isFront = !_isFront;
      });
    }).catchError((err) {});
  }

  //Audio On / Off
  void _onToggleMuteAudio() {
    setState(() {
      _mutedAudio = !_mutedAudio;
    });
    engine?.muteLocalAudioStream(_mutedAudio);
  }

  //Video On / Off
  void _onToggleMuteVideo() {
    setState(() {
      _mutedVideo = !_mutedVideo;
    });
    engine?.muteLocalVideoStream(_mutedVideo);
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    engine?.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _joined = true;
          final info = 'onJoinChannel: ${connection.channelId}, uid:  ${connection.localUid}';
          log(info.toString());
          _infoStrings.add(info);
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          final info = 'userJoined: $remoteUid';
          log(info.toString());

          _infoStrings.add(info);
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        if (reason == UserOfflineReasonType.userOfflineDropped) {
          WakelockPlus.disable();
        } else {
          setState(() {
            final info = 'userOffline: $remoteUid';
            log(info.toString());

            _infoStrings.add(info);
            _remoteUid = null;
            _timerKey.currentState?.cancelTimer();
          });
        }
      },
      onError: (ErrorCodeType code, String str) {
        setState(() {
          final info = 'onError:$code ${code.index}';
          log(info.toString());

          _infoStrings.add(info);
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
        });
        log("channek lecave e");
      },
      onFirstRemoteAudioFrame: (RtcConnection connection, int width, int height) {
        setState(() {
          final info = 'firstRemoteVideo: ${connection.localUid} ${width}x $height';
          log(info.toString());

          _infoStrings.add(info);
        });
      },
      onConnectionStateChanged:
          (RtcConnection connection, ConnectionStateType type, ConnectionChangedReasonType reason) {
        if (type == ConnectionStateType.connectionStateConnected) {
          setState(() {
            _reConnectingRemoteView = false;
          });
        } else if (type == ConnectionStateType.connectionStateReconnecting) {
          setState(() {
            _reConnectingRemoteView = true;
          });
        }
      },
      onRemoteVideoStats: (RtcConnection connection, RemoteVideoStats stats) {
        if (stats.receivedBitrate == 0) {
          setState(() {
            _reConnectingRemoteView = true;
          });
        } else {
          setState(() {
            _reConnectingRemoteView = false;
          });
        }
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      },
    ));
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _onBackPressed(context)!;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
            ),
            //_logPanelWidget(), //Uncomment It During Development To Ensure Proper Agora Setup
            _timerView(),
            _cameraView(),
            _bottomPortionWidget(context),
            _cancelCallView()
          ],
        ),
      ),
    );
  }

  //Get This Alert Dialog When User Press On Back Button
  Future<bool>? _onBackPressed(BuildContext context) {
    showCallLeaveDialog(
        context, "Are you sure you want to end your call?", "Yes end call now", "No cancel & return to call", () {
      _onCallEnd(context);
    });
    return Future.value(false);
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  // Generate remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine!,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channelId),
            ),
          ),
          _reConnectingRemoteView
              ? Container(
                  color: Colors.black.withAlpha(200),
                  child: const Center(
                      child: Text(
                    "Reconnecting...",
                    style: TextStyle(color: Colors.white, fontSize: labelFontSize),
                  )))
              : SizedBox(),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(spacingXSmall),
        child: Text(
          'Please wait for joining...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: tabBarTitle, color: Colors.white, fontWeight: fontWeightRegular),
        ),
      );
    }
  }

  //Timer Ui
  Widget _timerView() => Positioned(
        top: 45,
        left: spacingXXXSLarge,
        child: Opacity(
          opacity: 1,
          child: Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: Icon(Icons.access_time_filled_rounded),
              ),
              SizedBox(width: 15),
              TimerView(
                key: _timerKey,
              )
            ],
          ),
        ),
      );

  //Local Camera View
  Widget _cameraView() => Container(
        padding: const EdgeInsets.symmetric(vertical: spacingXXXXLarge, horizontal: 20),
        alignment: Alignment.bottomRight,
        child: FractionallySizedBox(
          child: Container(
            width: horizontalWidth,
            height: verticalLength,
            alignment: Alignment.topRight,
            color: Colors.black,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _switch = !_switch;
                });
              },
              child: Center(
                child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
              ),
            ),
          ),
        ),
      );

  //Only For Development Purpose (Please Comment It For Release)
  Widget _logPanelWidget() => Container(
        padding: const EdgeInsets.symmetric(vertical: spacingXXXSLarge),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: spacingXXXSLarge),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (context, index) {
                if (_infoStrings.isEmpty) {
                  return null;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: spacingTiny,
                    horizontal: spacingSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: spacingTiny,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(spacingTiny),
                          ),
                          child: Text(
                            _infoStrings[index],
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

  // Ui & UX For Bottom Portion (Switch Camera,Video On/Off,Mic On/Off)
  Widget _bottomPortionWidget(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 20, left: spacingXXMLarge, right: spacingXLarge),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _onToggleCamera,
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _isFront ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(15),
              child: Icon(
                _isFront ? Icons.camera_front : Icons.camera_rear,
                color: Colors.white,
                size: smallIconSize,
              ),
            ),
            RawMaterialButton(
              onPressed: _onToggleMuteVideo,
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _mutedVideo ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(15),
              child: Icon(
                _mutedVideo ? Icons.videocam_off : Icons.videocam,
                color: Colors.white,
                size: smallIconSize,
              ),
            ),
            RawMaterialButton(
              onPressed: _onToggleMuteAudio,
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _mutedAudio ? Colors.white.withAlpha(100) : Colors.transparent,
              padding: const EdgeInsets.all(15),
              child: Icon(
                _mutedAudio ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: smallIconSize,
              ),
            ),
          ],
        ),
      );

  //Cancel Button Ui/Ux
  Widget _cancelCallView() => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: spacingXXXLarge, right: spacingXLarge),
          child: InkWell(
            onTap: () {
              showCallLeaveDialog(
                  context, "Are you sure you want to end your call?", "Yes end call now", "No cancel & return to call",
                  () {
                _onCallEnd(context);
              });
            },
            child: const Icon(
              Icons.cancel,
              color: Colors.white,
              size: imageMTiny,
            ),
          ),
        ),
      );

  //Use This Method To End Call
  void _onCallEnd(BuildContext context) async {
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    //Emit Reject Call Event Into Socket
    await engine?.leaveChannel();
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
  }
}
