import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:whatsappclone/controller/services/otp_service.dart';

import '../../utils/common_Widgets.dart';

class otp_screen extends StatefulWidget {
  const otp_screen({super.key});

  static const int smsCodeLen = 6;

  @override
  State<otp_screen> createState() => _otp_screenState();
}

class _otp_screenState extends State<otp_screen> {
  final otpController =
      List.generate(otp_screen.smsCodeLen, (index) => TextEditingController());

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter the OTP Code"),
        centerTitle: true,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  for (int i = 0; i < otp_screen.smsCodeLen; i++) ...{
                    Flexible(
                      child: TextFormField(
                        controller: otpController[i],
                        keyboardType: TextInputType.number,
                        // style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          if (text.length == 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  }
                ],
              ),
              12.height,
              const Text(
                "Enter 6-digit code",
                style: TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              PrimaryButton(
                title: "Verify",
                onPressed: verifyOTP,
                loading: loading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String get otpCode {
    return otpController.map((e) => e.text).join();
  }

  void verifyOTP() async {
    setState(() {
      loading = true;
    });

    await otp_service.verifyOTp(context: context, otp: otpCode);
    // ref.read(authControllerProvider).verifyOTP(
    //       idSent: widget.idSent,
    //       inputCode: otpCode,
    //       context: context,
    //       createProfileRoute: PageRouter.createProfile,
    //     );
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
