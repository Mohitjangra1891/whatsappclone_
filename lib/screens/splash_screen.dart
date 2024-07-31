import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/services/firebase_service.dart';
import 'package:whatsappclone/controller/services/otp_service.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/screens/auth/create_profile.dart';
import 'package:whatsappclone/screens/auth/welcome_Page.dart';
import 'package:whatsappclone/screens/homePage.dart';

import '../controller/providers/auth_Provider.dart';
import '../controller/providers/home_page_provider.dart';
import '../utils/CGConstant.dart';

class splash_screen extends StatefulWidget {
  static String tag = '/CGSplashScreen';

  @override
  CGSplashScreenState createState() => CGSplashScreenState();
}

class CGSplashScreenState extends State<splash_screen> {
  @override
  void initState() {
    super.initState();
    log('splash Screen');

    init();
  }

  init() async {
    checkFirstSeen();
  }

  Future checkFirstSeen() async {
    await Future.delayed(const Duration(seconds: 2));
    finish(context);
    if (otp_service.is_user_authenticated()) {
      bool userAlreadyThere = await firebase_service.checkUser();
      if (userAlreadyThere == true) {
        await context
            .read<auth_Provider>()
            .fetchUserData(auth.currentUser!.uid);
        context.read<homepage_Provider>().initializeGroupsStream();

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const homePage()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const create_profile_screen()));
      }
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const welcome_page()));
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset("images/whatsApp/app_ic_wp.png",
                    height: 150, width: 150)
                .center(),
            Positioned(
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('From',
                      style: secondaryTextStyle(
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : Colors.black)),
                  Text(CGAppName,
                      style: boldTextStyle(
                          size: 25,
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : Colors.black)),
                ],
              ).paddingBottom(16),
            )
          ],
        ),
      ),
    );
  }
}
