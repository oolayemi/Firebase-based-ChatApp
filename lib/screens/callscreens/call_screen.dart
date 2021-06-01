import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:firebase_auth/firebase_auth.dart' as CurrentUser;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:placeholder/utils/unversal_variables.dart';
import 'package:provider/provider.dart';
import 'package:placeholder/configs/agora_configs.dart';
import 'package:placeholder/models/call.dart';
import 'package:placeholder/provider/user_provider.dart';
import 'package:placeholder/resources/call_methods.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  late UserProvider userProvider;
  late StreamSubscription callStreamSubscription;

  late ClientRole role;
  String currentUser = CurrentUser.FirebaseAuth.instance.currentUser!.uid;

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
    getRole(currentUser);
  }

  ClientRole getRole(String userId) {
    if (widget.call.callerId == userId) {
      setState(() {
        role = ClientRole.Broadcaster;
      });
      return ClientRole.Broadcaster;
    }
    role = ClientRole.Audience;
    return ClientRole.Audience;
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.call.channelId!, null, 0);
  }

  // Future<void> initializeAgora() async {
  //   if (APP_ID.isEmpty) {
  //     setState(() {
  //       _infoStrings.add(
  //         'APP_ID missing, please provide your APP_ID in settings.dart',
  //       );
  //       _infoStrings.add('Agora Engine is not starting');
  //     });
  //     return;
  //   }

  //   await _initAgoraRtcEngine();
  //   _addAgoraEventHandlers();
  //   await _engine.enableWebSdkInteroperability(true);
  //   await _engine.setParameters(
  //       '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
  //   VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
  //   configuration.dimensions = VideoDimensions(1920, 1080);
  //   await _engine.setVideoEncoderConfiguration(configuration);
  //   await _engine.joinChannel(Token, widget.call.channelId, null, 0);
  // }

  addPostFrameCallback() {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser!.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        if (ds.data == null) {
          // snapshot is null which means that call is hanged and documents are deleted
          Navigator.pop(context);
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  // Future<void> _initAgoraRtcEngine() async {
  //   _engine = await RtcEngine.create(APP_ID);
  //   await _engine.enableVideo();
  // }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    widget.call.isVideoCall!
        ? await _engine.enableVideo()
        : await _engine.disableVideo();
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      }, joinChannelSuccess: (String channel, int uid, int elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      }, userJoined: (int uid, int elapsed) {
        setState(() {
          final info = 'onUserJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      }, userInfoUpdated: (int i, UserInfo userInfo) {
        setState(() {
          final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
          _infoStrings.add(info);
        });
      }, rejoinChannelSuccess: (String string, int a, int b) {
        setState(() {
          final info = 'onRejoinChannelSuccess: $string';
          _infoStrings.add(info);
        });
      }, userOffline: (int uid, UserOfflineReason b) {
        callMethods.endCall(call: widget.call).then((value) {
          Navigator.maybePop(context);
        });

        setState(() {
          final info = 'onUserOffline: a: ${uid.toString()}';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      }, localUserRegistered: (int i, String s) {
        setState(() {
          final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
          _infoStrings.add(info);
        });
      }, leaveChannel: (RtcStats stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      }, connectionLost: () {
        setState(() {
          final info = 'onConnectionLost';
          _infoStrings.add(info);
        });
      }, firstRemoteVideoFrame: (int uid, int width, int height, int elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      }),
    );

    // AgoraRtcEngine.onUserOffline = (int uid, int reason) {
    //   // if call was picked

    //   setState(() {
    //     final info = 'userOffline: $uid';
    //     _infoStrings.add(info);
    //     _users.remove(uid);
    //   });
    // };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];

    list.add(RtcLocalView.SurfaceView());

    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar() {
    // if (role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              callMethods.endCall(call: widget.call).then((value) {
                Navigator.pop(context);
              });
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          widget.call.isVideoCall!
              ? RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: Icon(
                    Icons.switch_camera,
                    color: Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
              : SizedBox()
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            widget.call.isVideoCall!
                ? _viewRows()
                : Container(
                    color: UniversalVariables.blackColor,
                    child: Center(
                      child: widget.call.callerId ==
                              CurrentUser.FirebaseAuth.instance.currentUser!.uid
                          ? Image.network(
                              widget.call.receiverPic!,
                              width: MediaQuery.of(context).size.width * 0.9,
                              fit: BoxFit.fill,
                            )
                          : Image.network(
                              widget.call.callerPic!,
                              width: MediaQuery.of(context).size.width * 0.9,
                              fit: BoxFit.fill,
                            ),
                    )),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
