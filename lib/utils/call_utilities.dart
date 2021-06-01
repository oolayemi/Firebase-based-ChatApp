import 'dart:math';

import 'package:flutter/material.dart';
import 'package:placeholder/constants/strings.dart';
import 'package:placeholder/models/call.dart';
import 'package:placeholder/models/log.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/resources/call_methods.dart';
import 'package:placeholder/resources/local_db/repository/log_repository.dart';
//import 'package:placeholder/resources/local_db/repository/log_repository.dart';
import 'package:placeholder/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {required FirebaseUser from,
      required FirebaseUser to,
      required bool isVideoCall,
      context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      isVideoCall: isVideoCall,
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
      isVideoCall: isVideoCall.toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call),
        ),
      );
    }
  }
}
