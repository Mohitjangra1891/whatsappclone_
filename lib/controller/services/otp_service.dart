import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/screens/homePage.dart';
import 'package:whatsappclone/screens/splash_screen.dart';

import '../../screens/auth/create_profile.dart';
import '../../screens/auth/otp_screen.dart';
import '../../utils/CGConstant.dart';

class otp_service {
  static bool is_user_authenticated() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      return true;
    }
    return false;
  }

  static recieveOTP({required BuildContext context, required String mobile_no}) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.verifyPhoneNumber(
          phoneNumber: mobile_no,
          verificationCompleted: (PhoneAuthCredential credential) {
            print("verification Completed $credential\n mobile numer --$mobile_no");
            context.read<auth_Provider>().change_isloading(false);
          },
          verificationFailed: (FirebaseAuthException exception) {
            print("verification falied $exception\n mobile numer --$mobile_no");
            snackBar(context, title: "verification falied ${exception.message}");
            context.read<auth_Provider>().change_isloading(false);
          },
          codeSent: (String verificationID, int? resendToken) {
            log("code sent successfully");
            context.read<auth_Provider>().set_verificationID(verificationID);
            snackBar(context, title: "code sent successfully");

            Navigator.push(context, MaterialPageRoute(builder: (context) => const otp_screen()));
            context.read<auth_Provider>().change_isloading(false);
          },
          codeAutoRetrievalTimeout: (String verificationID) {
            print("codeAutoRetrievalTimeout-- $verificationID");
            context.read<auth_Provider>().change_isloading(false);
          });
    } catch (exception) {
      context.read<auth_Provider>().change_isloading(false);

      if (kDebugMode) {
        log(exception.toString());
      }
    }
  }

  static verifyOTp({required BuildContext context, required String otp}) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      AuthCredential credential =
          PhoneAuthProvider.credential(verificationId: context.read<auth_Provider>().verificationID, smsCode: otp);
      await auth.signInWithCredential(credential);

      if (is_user_authenticated()) {
        print("login successful");

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const create_profile_screen()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => splash_screen()), (Route<dynamic> route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'OTP Invalid',
          style: TextStyle(color: Colors.red),
        )),
      );

      print("error  OTP Invalid " + e.toString());
    }
  }
}
