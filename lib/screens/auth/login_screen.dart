import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/controller/services/otp_service.dart';
import 'package:whatsappclone/utils/CGConstant.dart';
import 'package:whatsappclone/utils/widget_themes.dart';
import 'package:country_picker/country_picker.dart';

import '../../utils/CGColors.dart';
import '../../utils/common_Widgets.dart';

class login_screen extends StatefulWidget {
  const login_screen({super.key});

  @override
  State<login_screen> createState() => _login_screenState();
}

class _login_screenState extends State<login_screen> {
  // Country country = Country.worldWide;
  TextEditingController _extController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _extController.text = context.read<auth_Provider>().country_code_Controller;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<auth_Provider>().change_isloading(false);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // context.read<auth_Provider>().change_isloading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enter your phone number",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text:
                          "$CGAppName will need to verify your phone number. ",
                      style: textStyle_black_white),
                  const TextSpan(
                    text: "What's my number?",
                    style: TextStyle(color: textHighlightColor),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: pickCountry,
              style: TextButton.styleFrom(foregroundColor: textHighlightColor),
              child: const Text(
                "Pick Country",
                style: TextStyle(
                  color: textHighlightColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      readOnly: true,
                      // initialValue:
                      //     context.read<auth_Provider>().country_code_Controller,
                      controller: _extController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        hintText: "Ext.",
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    flex: 4,
                    child: TextField(
                      controller: _phoneController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(hintText: "Phone Number"),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: ElevatedButton(
                  onPressed: goToOTPVerification,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: context.watch<auth_Provider>().isloading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
                          "NEXT",
                          style: textStyle_black_white.copyWith(fontSize: 16),
                        ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _extController.dispose();
    _phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      showPhoneCode: true,
      useSafeArea: true,
      context: context,
      favorite: <String>['IN', 'KN', 'MF'],
      onSelect: (country) {
        context
            .read<auth_Provider>()
            .change_CountryCode("+${country.phoneCode.toString()}");
        _extController.text =
            context.read<auth_Provider>().country_code_Controller;
      },
    );
  }

  void goToOTPVerification() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      snackBar(context, title: "Fill in phone number .");
      return;
    } else if (_extController.text.isEmpty) {
      snackBar(context, title: "Fill in the Country Code.");
      return;
    }
    context.read<auth_Provider>().change_isloading(true);
    context
        .read<auth_Provider>()
        .set_mobileNumber(_phoneController.text.trim());
    await otp_service.recieveOTP(
        context: context,
        mobile_no: context.read<auth_Provider>().mobileNumber);
    // context.read<auth_Provider>().change_isloading(false);

    // ref.read(authControllerProvider).sendOTP(
    //       context: context,
    //       phoneNumber: '+${country.phoneCode}${_phoneController.text.trim()}',
    //       otpVerificationPage: PageRouter.otpVerification,
    //     );
    // await Future.delayed(const Duration(milliseconds: 300));
  }
}
