import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_sound/flutter_sound.dart';

import 'demo_active_codec.dart';

/// path to remote auido file.
const String exampleAudioFilePath =
    'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';

/// path to remote auido file artwork.
final String albumArtPath =
    'https://file-examples-com.github.io/uploads/2017/10/file_example_PNG_500kB.png';

///
class RemotePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoundPlayerUI.fromLoader(
      _createRemoteTrack,
      showTitle: true,
      audioFocus: AudioFocus.requestFocusAndDuckOthers,
    );
  }

  Future<Track> _createRemoteTrack(BuildContext context) async {
    var track = Track();
    // validate codec for example file
    if (ActiveCodec().codec != Codec.mp3) {
      var error = SnackBar(
          backgroundColor: Colors.red,
          content: Text('You must set the Codec to MP3 to '
              'play the "Remote Example File"'));
      ScaffoldMessenger.of(context).showSnackBar(error);
    } else {
      // We have to play an example audio file loaded via a URL
      track =
          Track(trackPath: exampleAudioFilePath, codec: ActiveCodec().codec!);

      track.trackTitle = 'Remote mpeg playback.';
      track.trackAuthor = 'By flutter_sound';
      track.albumArtUrl = albumArtPath;

      if (kIsWeb) {
        track.albumArtAsset = null;
      } else if (Platform.isIOS) {
        track.albumArtAsset = 'AppIcon';
      } else if (Platform.isAndroid) {
        track.albumArtAsset = 'AppIcon.png';
      }
    }

    return track;
  }
}