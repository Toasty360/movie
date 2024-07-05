import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:movie/services/extractor.dart';
// import 'package:movie/services/hdrezka.dart';
import 'package:movie/services/vidsrcPro.dart';
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
  String currentCaption = "";
  List quality = [];
  List captions = [];

  @override
  void initState() {
    fetchM3u8();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  fetchM3u8() async {
    print(
        "${widget.episode.id},season: ${widget.episode.season}, episode: ${widget.episode.episode}");
    Future<Map<dynamic, dynamic>> temp;
    if (widget.episode.season.runtimeType == Null) {
      temp = VidsrcPro().getSource(widget.episode.id, true);
    } else {
      temp = VidsrcPro().getSource(widget.episode.id, false,
          season: widget.episode.season, episode: widget.episode.episode);
    }
    temp.then((data) {
      setState(() {
        player.open(Media(data["default"],
            httpHeaders: {"Referer": "https://vidsrc.pro/"}));
      });
      quality = data["qualities"];
      captions = [
        {"label": "~ No Captions ~", "file": ""},
        ...data["subtitles"]
      ];
    });
  }

  // callRezka() async {
  //   print(widget.episode.id);
  //   widget.episode.id == ""
  //       ? fetchByBruteForce(widget.episode.image!).then((value) {
  //           print(value);
  //           // player.open(Media(
  //           //     data["Sources"]["720p"] ?? data["Sources"]["480p"],
  //           //     httpHeaders: {"Referer": "https://hdrezka.me/"}));
  //         })
  //       : hdrezka(widget.episode).then((data) => setState(() {
  //             if (data.isNotEmpty) {
  //               setState(() {
  //                 quality = data;
  //               });
  //               player.open(Media(
  //                   data["Sources"]["720p"] ?? data["Sources"]["480p"],
  //                   httpHeaders: {"Referer": "https://hdrezka.me/"}));
  //             } else {
  //               fetchByBruteForce(widget.episode.image!).then((value) {
  //                 print(value.keys);
  //                 player.open(Media(value["720p"] ?? value["480p"],
  //                     httpHeaders: {"Referer": "https://hdrezka.me/"}));
  //               });
  //               Toast.show("fetching brute force");
  //             }
  //           }));
  // }

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
            const Spacer(),
            PopupMenuButton(
                icon: const Icon(Icons.bar_chart_rounded),
                tooltip: "Quality",
                itemBuilder: (context) => quality
                    .map((e) => PopupMenuItem(
                          child: Text(e["resolution"]),
                          onTap: () {
                            var pos = player.state.position;
                            Toast.show(e["resolution"]);
                            player.open(Media(e["url"])).then((value) {
                              player.state.copyWith(position: pos);
                              Future.delayed(const Duration(seconds: 1))
                                  .then((value) {
                                player.seek(pos);
                              });
                            });
                          },
                        ))
                    .toList()
                    .cast<PopupMenuItem>()),
            PopupMenuButton(
                icon: const Icon(Icons.closed_caption_rounded),
                tooltip: "Captions",
                itemBuilder: (context) => captions
                    .map((e) => PopupMenuItem(
                          child: Text(
                            e["label"],
                            style: TextStyle(
                                color: e["file"] != ""
                                    ? (e["label"] == currentCaption
                                        ? Colors.green
                                        : Colors.white)
                                    : Colors.blue),
                          ),
                          onTap: () {
                            if (e["label"] == currentCaption ||
                                e["file"] == "") {
                              player.setSubtitleTrack(SubtitleTrack.no());
                              currentCaption = "";
                              Toast.show("Captions removed");
                              setState(() {});
                            } else {
                              player
                                  .setSubtitleTrack(SubtitleTrack.uri(e["file"],
                                      language: e["label"], title: e["label"]))
                                  .then((value) {
                                setState(() {
                                  Toast.show(e["label"]);
                                  currentCaption = e["label"];
                                });
                              });
                            }
                          },
                        ))
                    .toList()
                    .cast<PopupMenuItem>()),
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
          subtitleViewConfiguration: const SubtitleViewConfiguration(
            style: TextStyle(
              height: 1.4,
              fontSize: 45.0,
              letterSpacing: 0.0,
              wordSpacing: 0.0,
              color: Colors.yellow,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            padding: EdgeInsets.all(24.0),
          ),
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
