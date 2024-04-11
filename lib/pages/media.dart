import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:movie/services/extractor.dart';
import 'package:toast/toast.dart';

import '../model/model.dart';

class MediaPlayer extends StatefulWidget {
  final Episode episode;

  const MediaPlayer({super.key, required this.episode});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  late final player = Player(
      configuration: const PlayerConfiguration(
    vo: 'gpu',
  ));
  late final controller = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      hwdec: 'auto-safe',
      androidAttachSurfaceAfterVideoParameters: false,
    ),
  );

  String currentQuality = "";
  Map quality = {};

  @override
  void initState() {
    readym3u8();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  readym3u8() async {
    String url = widget.episode.season.runtimeType == Null
        ? "movie?tmdb=${widget.episode.id}"
        : "tv?tmdb=${widget.episode.id}&season=${widget.episode.season}&episode=${widget.episode.episode}";
    print("test : $url");
    videosrc(url).then((data) {
      if (data["src"] != "Not found!") {
        setState(() {
          player.open(Media(data["src"],
              httpHeaders: {"Referer": "http://vidsrc.stream"}));
        });
      } else {
        print("not found");
        Toast.show("Media not found");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
          brightnessGesture: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          volumeGesture: true,
          displaySeekBar: true,
          seekOnDoubleTap: true,
          seekBarThumbSize: 12,
          seekBarMargin: const EdgeInsets.only(bottom: 20),
          buttonBarButtonSize: 24.0,
          buttonBarButtonColor: Colors.white,
          bottomButtonBarMargin: const EdgeInsets.only(bottom: 25),
          topButtonBarMargin: const EdgeInsets.symmetric(horizontal: 0),
          topButtonBar: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                player.dispose();
              },
            ),
            Text(widget.episode.title ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
          bottomButtonBar: [
            const Spacer(),
            IconButton(
              onPressed: () {
                player
                    .seek(player.state.position - const Duration(seconds: 10));
              },
              icon: const Icon(
                Icons.replay_10_sharp,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                player
                    .seek(player.state.position + const Duration(seconds: 10));
              },
              icon: const Icon(
                Icons.forward_10_rounded,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                player.seek(player.state.position +
                    const Duration(minutes: 1, seconds: 30));
              },
              icon: const Icon(
                Icons.double_arrow_rounded,
                color: Colors.white,
              ),
            ),
          ]),
      fullscreen: const MaterialVideoControlsThemeData(
        displaySeekBar: true,
        automaticallyImplySkipNextButton: false,
        automaticallyImplySkipPreviousButton: false,
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        body: Video(
          fit: kIsWeb ? BoxFit.fitWidth : BoxFit.fill,
          controller: controller,
          wakelock: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    player.dispose();
    super.dispose();
  }
}
