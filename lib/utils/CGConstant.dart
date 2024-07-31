// AppName
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

const CGAppName = 'Mchat';
const CGAppPadding = 18.0;
const CGAppTextSize = 16.0;
const isDarkModeOnPref = "isDarkModeOnPref";

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;

enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif');

  const MessageEnum(this.type);
  final String type;
}

// Using an extension
// Enhanced enums

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;
      case 'video':
        return MessageEnum.video;
      default:
        return MessageEnum.text;
    }
  }
}

//Screen Dimensions
Size? screenSize;

// Spacing Constant
const spacingTiny = 5.0;
const spacingXSmall = 7.5;
const spacingSmall = 10.0;
const spacingMedium = 15.0;
const spacingLarge = 20.0;
const spacingXLarge = 25.0;
const spacingXXLarge = 30.0;
const spacingXXMLarge = 35.0;
const spacingXXXLarge = 40.0;
const spacingXXXSLarge = 50.0;
const spacingXXXXLarge = 75.0;

// Font Size Constant
const labelFontSize = 14.0;
const headerTitleSize = 24.0;
const buttonLabelFontSize = 18.0;
const tabBarTitle = 15.0;

//Local Camera View
const horizontalWidth = 110.0;
const verticalLength = 139.0;

// Font Weight Constant
const fontWeightRegular = FontWeight.w400;

//To Get Dynamic Screen Siz
// Image Size Constant
const imageMTiny = 35.0;
const imageXLarge = 170.0;

//Icon Size Constant
const smallIconSize = 20.0;
