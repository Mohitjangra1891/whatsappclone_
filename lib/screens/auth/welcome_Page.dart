import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/utils/CGConstant.dart';

import '../../main.dart';
import '../../utils/AppColors.dart';
import '../../utils/CGColors.dart';
import 'login_screen.dart';

class welcome_page extends StatelessWidget {
  const welcome_page({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = appStore.isDarkModeOn;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome to $CGAppName",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? appBackgroundColorDark : whiteColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  "images/whatsApp/welcome_bg.png",
                  width: 240,
                  height: 240,
                  color: secondaryColor,
                ),
                const SizedBox(height: 50),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Read our "),
                      TextSpan(
                        text: "Privacy Policy. ",
                        style: TextStyle(color: textSecondaryColors),
                      ),
                      TextSpan(
                          text: "Tap \"Agree and continue\" to accept the "),
                      TextSpan(
                        text: "Terms of Service.",
                        style: TextStyle(color: textSecondaryColors),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    onPressed: () {
                      const login_screen().launch(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    child: Text("AGREE AND CONTINUE",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
