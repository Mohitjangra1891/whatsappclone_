import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:whatsappclone/controller/services/call_service.dart';

import '../../model/call_model.dart';
import '../../utils/CGConstant.dart';
import 'call_screen.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'call_screen_two.dart';

class CallPickupScreen extends StatefulWidget {
  final Widget scaffold;
  const CallPickupScreen({
    Key? key,
    required this.scaffold,
  }) : super(key: key);

  @override
  State<CallPickupScreen> createState() => _CallPickupScreenState();
}

class _CallPickupScreenState extends State<CallPickupScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //To Stop Ringtone
    FlutterRingtonePlayer().stop();

    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: call_service.callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call = Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if (!call.hasDialled) {
            WakelockPlus.enable(); // Turn on wakelock feature till call is running
            //To Play Ringtone
            FlutterRingtonePlayer().play(
                android: AndroidSounds.ringtone, ios: IosSounds.electronic, looping: true, volume: 0.5, asAlarm: false);
            _timer = Timer(const Duration(milliseconds: 33 * 1000), _endCall);
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Incoming Call',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      call.callerName,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            try {
                              await firestore.collection('call').doc(call.callerId).delete();
                              await firestore.collection('call').doc(call.receiverId).delete();
                            } catch (e) {
                              snackBar(context, title: e.toString());
                            }
                          },
                          icon: const Icon(Icons.call_end, color: Colors.redAccent),
                          iconSize: 28,
                        ),
                        const SizedBox(width: 25),
                        IconButton(
                          iconSize: 28,
                          onPressed: () {
                            _timer?.cancel();
                            FlutterRingtonePlayer().stop();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoCallingScreen(
                                  channelId: call.callId,
                                  call: call,
                                  isGroupChat: false,
                                ),
                              ),
                            );
                            // Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        FlutterRingtonePlayer().stop();
        _timer?.cancel();

        return widget.scaffold;
      },
    );
  }

  _endCall() async {
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    FlutterRingtonePlayer().stop(); // To Stop Ringtone
    //Emit Reject Call Event Into Socket
  }
}
