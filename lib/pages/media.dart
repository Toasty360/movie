import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:movie/services/vidsrcNet.dart';
import 'package:movie/services/serviceProvider.dart';
import 'package:movie/services/vidlink.dart';
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
        enableHardwareAcceleration: true),
  );

  String currentQuality = "";
  String currentCaption = "";
  double playbackSpeed = 1;
  MediaData data = MediaData(
      provider: SrcProvider.none,
      qualities: [],
      referer: "",
      src: "",
      subtitles: []);

  @override
  void initState() {
    _setSource();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  _setSource() async {
    final List<ServiceProvider> providers = [
      VidsrcPro(),
      VidsrcNet(),
      VidLink(),
    ];

    for (var provider in providers) {
      if (mounted) {
        try {
          if (widget.episode.season == null) {
            data = await provider.getSource(widget.episode.id, true);
          } else {
            data = await provider.getSource(widget.episode.id, false,
                season: widget.episode.season, episode: widget.episode.episode);
          }
          if (mounted) {
            setState(() {
              player.open(
                  Media(data.src, httpHeaders: {"Referer": data.referer}),
                  play: true);
              //     .onError((error, stackTrace) {
              //   print("Error at 74: $error");
              // }).catchError((error) => {print("Error at 75: $error")});
            });
            try {
              if (data.qualities.isEmpty) {
                Dio()
                    .get(data.src,
                        options: Options(headers: {"Referer": data.referer}))
                    .then((value) => extractQualityAndLinks(value.data));
                return;
              }
            } catch (e) {
              print(e);
            }
          }
          return;
        } catch (e) {
          Toast.show("${provider.runtimeType} faild to extract");
          print("Error: $e, trying next source...");
        }
      } else {
        break;
      }
    }
  }

  // fetchM3u8FromProSRC() async {
  //   print("fetchM3u8FromProSRC");
  //   try {
  //     if (kDebugMode) {
  //       print(
  //           "${widget.episode.id},season: ${widget.episode.season}, episode: ${widget.episode.episode}");
  //     }
  //     if (widget.episode.season.runtimeType == Null) {
  //       data = await VidsrcPro().getSource(widget.episode.id, true);
  //     } else {
  //       data = await VidsrcPro().getSource(widget.episode.id, false,
  //           season: widget.episode.season, episode: widget.episode.episode);
  //     }
  //     if (mounted) {
  //       if (data.qualities.isEmpty) {
  //         Dio()
  //             .get(data.src)
  //             .then((value) => extractQualityAndLinks(value.data));
  //         return;
  //       }
  //       setState(() {
  //         player.open(Media(data.src));
  //       });
  //     }
  //     Dio()
  //         .get(
  //       data.src,
  //       options: Options(
  //         headers: {
  //           'Referer': 'https://vidsrc.pro/',
  //           'User-Agent':
  //               'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
  //         },
  //       ),
  //     )
  //         .then((value) {
  //       setState(() {
  //         data.qualities = extractQualityAndLinks(value.data);
  //         // quality = data.qualities;
  //       });
  //     });
  //   } catch (e) {
  //     print("got error $e");
  //     fetchM3u8FromXYZSRC();
  //   }
  // }

  // fetchM3u8FromXYZSRC() async {
  //   print("fetchM3u8FromSrcNet");
  //   try {
  //     if (widget.episode.season.runtimeType == Null) {
  //       data = await VidsrcNet().getSource(widget.episode.id, true);
  //     } else {
  //       data = await VidsrcNet().getSource(widget.episode.id, false,
  //           season: widget.episode.season, episode: widget.episode.episode);
  //     }
  //     if (data.src.runtimeType != Null) {
  //       setState(() {
  //         player.open(Media(data.src, httpHeaders: {"Referer": data.referer}));
  //       });
  //       Dio()
  //           .get(data.src, options: Options(headers: {"Referer": data.referer}))
  //           .then((value) {
  //         setState(() {
  //           extractQualityAndLinks(value.data);
  //           // quality = data.qualities;
  //         });
  //       });
  //     } else {
  //       Toast.show("Media not found");
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return [
      if (hours > 0) hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      seconds.toString().padLeft(2, '0')
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    var vidocontroll = MaterialVideoControlsThemeData(
        brightnessGesture: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        volumeGesture: true,
        displaySeekBar: true,
        gesturesEnabledWhileControlsVisible: true,
        seekGesture: true,
        seekOnDoubleTap: true,
        seekBarThumbSize: 12,
        seekBarMargin: const EdgeInsets.only(bottom: 20),
        buttonBarButtonSize: 24.0,
        buttonBarButtonColor: Colors.white,
        bottomButtonBarMargin: const EdgeInsets.only(bottom: 25, left: 10),
        topButtonBarMargin: const EdgeInsets.symmetric(horizontal: 10),
        topButtonBar: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(
            width: screen.width * 0.6,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: Text(
                data != Null ? data.provider.name : "Unknown",
                style: const TextStyle(fontSize: 10),
              ),
              title: Text(widget.episode.title ?? "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const Spacer(),
          PopupMenuButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: "Quality",
              itemBuilder: (context) => data.runtimeType != Null &&
                      data.qualities.runtimeType != Null
                  ? data.qualities
                      .map((e) => PopupMenuItem(
                            child: Text(e.resolution),
                            onTap: () {
                              var pos = player.state.position;
                              Toast.show(e.resolution);
                              player
                                  .open(Media(e.url,
                                      httpHeaders: {"Referer": data.referer}))
                                  .then((value) {
                                player.state.copyWith(position: pos);
                                Future.delayed(const Duration(
                                        seconds: 1, milliseconds: 5))
                                    .then((value) {
                                  player.seek(pos);
                                });
                              });
                            },
                          ))
                      .toList()
                      .cast<PopupMenuItem>()
                  : []),
          PopupMenuButton(
              icon: const Icon(Icons.closed_caption_rounded),
              tooltip: "Captions",
              itemBuilder: (context) =>
                  data.runtimeType != Null && data.subtitles.runtimeType != Null
                      ? data.subtitles
                          .map((e) => PopupMenuItem(
                                child: Text(
                                  e["label"],
                                  style: TextStyle(
                                      color: e["url"] != ""
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
                                        .setSubtitleTrack(SubtitleTrack.uri(
                                            e["file"],
                                            language: e["label"],
                                            title: e["label"]))
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
                          .cast<PopupMenuItem>()
                      : []),
        ],
        bottomButtonBar: [
          const SizedBox(
            width: 10,
          ),
          StreamBuilder(
              stream: player.stream.position,
              builder: (context, snapshot) {
                final currentPosition =
                    snapshot.hasData ? snapshot.data! : Duration.zero;
                final totalDuration = player.state.duration;

                final currentPositionFormatted =
                    formatDuration(currentPosition);
                final totalDurationFormatted = formatDuration(totalDuration);

                return Text(
                    "$currentPositionFormatted / $totalDurationFormatted");
              }),
          const Spacer(),
          IconButton(
            onPressed: () {
              player.seek(player.state.position - const Duration(seconds: 10));
            },
            icon: const Icon(
              Icons.replay_10_sharp,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              player.seek(player.state.position + const Duration(seconds: 10));
            },
            icon: const Icon(
              Icons.forward_10_rounded,
              color: Colors.white,
            ),
          ),
          PopupMenuButton(
            enableFeedback: true,
            initialValue: playbackSpeed,
            icon: const Icon(Icons.speed_rounded),
            tooltip: "Playback speed",
            iconColor: Colors.blue,
            onSelected: (e) {
              setState(() {
                playbackSpeed = e;
                player.setRate(playbackSpeed);
                Toast.show("${e}x");
              });
            },
            itemBuilder: (context) {
              return <double>[0.5, 1.0, 1.5, 2]
                  .map((e) => PopupMenuItem(
                        value: e,
                        child: Text(
                          "${e}x",
                          style: TextStyle(
                              color: e == playbackSpeed ? Colors.green : null),
                        ),
                      ))
                  .toList()
                  .cast<PopupMenuItem>();
            },
          )
        ]);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.pop(context);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          player.seek(player.state.position - const Duration(seconds: 10));
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          player.seek(player.state.position + const Duration(seconds: 10));
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          player.playOrPause();
        },
      },
      child: Focus(
        autofocus: true,
        child: MaterialVideoControlsTheme(
          normal: vidocontroll,
          fullscreen: vidocontroll,
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
        ),
      ),
    );
  }

  void extractQualityAndLinks(String m3u8Content) {
    String highestQualityUrl = "";
    int highestQuality = 0;
    final results = <Quality>[];

    final lines = m3u8Content.split("\n");

    for (var i = 0; i < lines.length - 1; i++) {
      if (lines[i].startsWith("#EXT-X-STREAM-INF")) {
        final resolution = RegExp(r'RESOLUTION=(\d+x\d+)')
            .firstMatch(lines[i])
            ?.group(1)
            ?.split("x")
            .last;
        String url = lines[i + 1].startsWith("http")
            ? lines[i + 1]
            : Uri.decodeComponent(lines[i + 1]);

        if (!url.startsWith("http")) {
          url =
              "https://${url.split("base=").last}${url.split("viper").last.split(".png")[0]}";
        }

        if (resolution != null && int.parse(resolution) > highestQuality) {
          highestQuality = int.parse(resolution);
          highestQualityUrl = url;
        }

        results.add(Quality(resolution: resolution ?? 'Unknown', url: url));
      }
    }

    Future.delayed(const Duration(seconds: 4)).then((value) {
      print("test $value");
      if (player.state.videoParams.aspect == null &&
          highestQualityUrl.isNotEmpty &&
          player.state.buffering) {
        print(
            "test fixed vidsrc.net playlist error with $highestQualityUrl $highestQuality ");
        player.open(
            Media(highestQualityUrl, httpHeaders: {"Referer": data.referer}));
      }
    });

    setState(() {
      data.qualities = [
        ...results,
        Quality(resolution: "Default", url: data.src)
      ];
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    player.dispose();
    super.dispose();
  }
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
