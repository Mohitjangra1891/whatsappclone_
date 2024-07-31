import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/utils/widget_themes.dart';

import 'CGImages.dart';

class common_Widgets {}

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: loading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Text(
              title,
              style: textStyle_black_white.copyWith(fontSize: 16),
            ),
    );
  }
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    snackBar(context, title: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    snackBar(context, title: e.toString());
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
      context: context,
      apiKey: 'pwXu0t7iuNVm8VO5bgND2NzwCpVH9S0F',
    );
  } catch (e) {
    snackBar(context, title: e.toString());
  }
  return gif;
}

class WorkProgressIndicator extends StatelessWidget {
  const WorkProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 64,
        height: 64,
        child: CircularProgressIndicator(
          strokeWidth: 5.0,
        ),
      ),
    );
  }
}

Widget commonCacheImageWidget(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  AlignmentGeometry? alignment,
  double? radius,
}) {
  if (url != null && Uri.parse(url).isAbsolute || url.validate().startsWith('http')) {
    if (isMobile) {
      return CachedNetworkImage(
        imageUrl: url!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        // imageBuilder: (context, imageProvider) => Container(
        //   height: height,
        //   width: width,
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: imageProvider,
        //       fit: fit ?? BoxFit.cover,
        //       // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
        //     ),
        //   ),
        // ),
        alignment: alignment as Alignment? ?? Alignment.center,
        placeholder: (context, url) => Image.asset(
          placeholder_profile,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
        ),
        errorWidget: (context, url, error) {
          print('error loading image from internet');
          return Image.asset(
            placeholder_profile,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            alignment: alignment as Alignment? ?? Alignment.center,
          );
        },
      );
    } else {
      return Image.network(url!, height: height, width: width, fit: fit);
    }
  } else {
    return Image.asset(
      url!,
      height: height,
      width: width,
      fit: fit ?? BoxFit.fill,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        print('error loading asset in commonCacheImageWidget from assets');
        // Handle asset loading error
        return Image.asset(
          placeholder_profile,
          height: height,
          width: width,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

// Function to provide an ImageProvider
ImageProvider<Object> commonCacheImageProvider(String? url) {
  if (url != null && (Uri.parse(url).isAbsolute || url.startsWith('http'))) {
    if (isMobile) {
      return CachedNetworkImageProvider(url);
    } else {
      return NetworkImage(url);
    }
  } else {
    return AssetImage(placeholder_profile); // Use a default asset image
  }
}
