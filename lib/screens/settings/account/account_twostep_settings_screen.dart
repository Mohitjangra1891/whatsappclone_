import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/CGColors.dart';
import '../future_todo_screen.dart';

class AccountTwoStepSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String text = 'For added security, enable two-step '
        'verfication, which will require a PIN when '
        'registering your phone number with '
        'WhatzApp again.';

    return Scaffold(
      appBar: AppBar(
        title: Text('Two-step verification'),
      ),
      body: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 28.0),
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60.0),
                      color: secondaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    height: 1.1,
                  ),
                ),
              )
            ],
          ),
          60.height,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: tabColor),
              child: Text(
                'ENABLE',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FutureTodoScreen()));
              },
            ),
          )
        ],
      ),
    );
  }
}
