import 'dart:developer';
import 'package:provider/provider.dart' as provider;
// import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:whatsappclone/controller/providers/contact_provider.dart';
import 'package:whatsappclone/controller/providers/home_page_provider.dart';
import 'package:whatsappclone/screens/auth/welcome_Page.dart';
import 'package:whatsappclone/screens/camera/camera_screen.dart';
import 'package:whatsappclone/screens/splash_screen.dart';
import 'package:whatsappclone/utils/config/agora_config.dart';
import 'package:whatsappclone/utils/store/AppStore.dart';
import 'package:whatsappclone/utils/AppTheme.dart';
import 'package:provider/provider.dart';
import 'controller/providers/auth_Provider.dart';
import 'controller/services/media_service.dart';
import 'firebase_options.dart';
import 'model/message_reply.dart';

late RtcEngine? engine;

AppStore appStore = AppStore();
//Initialize Agora RTC Engine
Future<void> _initAgoraRtcEngine() async {
  engine = createAgoraRtcEngine();
  engine
      ?.initialize(
          RtcEngineContext(appId: AgoraConfig.appID, channelProfile: ChannelProfileType.channelProfileCommunication))
      .whenComplete(() {
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
    log("agora sdk initialized");
  });
  await engine?.enableVideo();
  // await engine?.enableWebSdkInteroperability(true);
}

late List<CameraDescription> cameras;
final PanelController panel_Controller = PanelController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization failed: ${e.toString()}");
  }
  await _initAgoraRtcEngine();
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
    // qrCameras = await qr.availableCameras();
  } on CameraException catch (e) {
    log('${e.code}\n${e.description}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (context) => homepage_Provider()),
        provider.ChangeNotifierProvider(create: (context) => auth_Provider()),
        provider.ChangeNotifierProvider(create: (context) => contact_provider()),
        provider.ChangeNotifierProvider(create: (_) => MessageReplyNotifier()),
        provider.ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Whatsapp Clone',
          theme: !appStore.isDarkModeOn ? AppThemeData.lightTheme : AppThemeData.darkTheme,
          home: splash_screen(),
        ),
      ),
    );
  }
}
