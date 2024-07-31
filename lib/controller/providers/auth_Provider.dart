import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../model/CGUserModel.dart';
import '../services/firebase_service.dart';

class auth_Provider extends ChangeNotifier {
  String country_code_Controller = '+91';
  bool isloading = false;
  String verificationID = "";

  String mobileNumber = "";
  String user_name = "";
  String? user_profileImage =
      'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
  late UserModel? user;

  Future<void> fetchUserData(String uid) async {
    user = await firebase_service.fetchUserData(uid);
    if (user != null) {
      user_profileImage = user?.profilePic;
      user_name = user!.name;
      mobileNumber = user!.phoneNumber;
    }
    notifyListeners();
  }

  // Future<void> updateUserData(UserModel user) async {
  //   await _userService.updateUserData(user);
  //   _user = user;
  //   notifyListeners();
  // }
  void set_user_NAME(String name) {
    user_name = name;
    notifyListeners();
  }

  void set_user_ProfileImage(String? img) {
    user_profileImage = img;
    notifyListeners();
  }

  void set_mobileNumber(String num) {
    // mobileNumber = "+91$num";
    mobileNumber =
        '$country_code_Controller ${num.substring(0, 5)} ${num.substring(5)}';
    print("mobile is $mobileNumber");
    notifyListeners();
  }

  void set_verificationID(String verID) {
    verificationID = verID;
    notifyListeners();
  }

  void change_CountryCode(String country_code) {
    log("changed country code to ${country_code}");
    country_code_Controller = country_code;
    notifyListeners();
  }

  void change_isloading(bool loading) {
    log("changed isloading  to ${loading}");
    isloading = loading;
    notifyListeners();
  }
}
