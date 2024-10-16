import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:movie/components/mediaControlls.dart';
import 'package:movie/components/task.dart';
import 'package:movie/model/service_provider.dart';
import 'package:movie/services/open_subs.dart';
import 'package:movie/services/tmdb.dart';
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
      provider: SrcProvider.VidsrcNet,
      qualities: [],
      headers: {},
      src: "",
      subtitles: []);

  @override
  void initState() {
    super.initState();

    player.stream.log.listen((event) {
      print("listen: ${event.text}");
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showTaskDialog(widget.episode, context).then((value) {
        print(value.src);
        if (value.subtitles.isEmpty) {
          TMDB
              .fetchImdbId(widget.episode.id, widget.episode.season == null)
              .then((value) => loadSubtitles(
                      value, widget.episode.season == null,
                      e: widget.episode.episode, s: widget.episode.season)
                  .then((sub) => player
                          .setSubtitleTrack(SubtitleTrack.data(sub))
                          .then((value) {
                        print("test: $sub");
                        Toast.show("Added Subtitle");
                      })));
        }
        player.open(
          Media(value.src, httpHeaders: !kIsWeb ? value.headers : {}),
          play: true,
        );
        extractQualityAndLinks(value);
        setState(() => data = value);
      });
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  Future<void> _setSource({ServiceProvider? selectedProvider}) async {
    List<ServiceProvider> providersToUse =
        selectedProvider != null ? [selectedProvider] : providers;

    for (ServiceProvider provider in providersToUse) {
      if (!mounted) break;
      try {
        data = widget.episode.season == null
            ? await provider.getSource(widget.episode.id, true,
                title: widget.episode.title)
            : await provider.getSource(widget.episode.id, false,
                season: widget.episode.season,
                episode: widget.episode.episode,
                title: widget.episode.title);

        if (!mounted) break;
        print(data.src.split(":").last);
        player.open(
          Media(data.src, httpHeaders: data.headers),
          play: true,
        );

        if (data.qualities.isEmpty) {
          try {
            extractQualityAndLinks(data);
          } catch (e) {
            print("Failed to extract quality and links: $e");
          }
        }

        // Break out of the loop after a successful source is set
        break;
      } catch (e) {
        Toast.show("${provider.runtimeType} failed to extract");
        print("Error: $e, trying next source...");
      }
    }
    if (data.src.isEmpty) {
      Toast.show("No sources available");
      _close();
    }
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            child: kIsWeb
                ? videobody()
                : getMediaControlls(controller, videobody(), topBar(),
                    movementControl(), context)));
  }

  void extractQualityAndLinks(MediaData data) async {
    final m3u8Content = (await Dio().get(data.src,
            options: Options(
              headers: data.headers,
              validateStatus: (status) => true,
            )))
        .data;

    String highestQualityUrl = "";
    int highestQuality = 0;
    final results = <Quality>[];

    print(m3u8Content);
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
        if (url.startsWith("?url=")) {
          url = Uri.parse(url.split("?url=").last).toString();
        } else if (url.startsWith("/")) {
          url = data.headers["referer"].toString() + url;
        }
        if (resolution != null && int.parse(resolution) > highestQuality) {
          highestQuality = int.parse(resolution);
          highestQualityUrl = url;
        }

        results.add(Quality(resolution: resolution ?? 'Unknown', url: url));
      }
    }
    if (mounted) {
      Future.delayed(const Duration(seconds: 6)).then((value) {
        print("test $value");
        if (player.state.videoParams.aspect == null &&
            highestQualityUrl.isNotEmpty &&
            player.state.buffering) {
          print(
              "test fixed ${data.provider} playlist error with ${highestQualityUrl.split(":").last} $highestQuality ");
          player.open(Media(highestQualityUrl, httpHeaders: data.headers));
        }
      });

      setState(() {
        data.qualities = [
          ...results,
          Quality(resolution: "Default", url: data.src)
        ];
      });
    }
  }

  List<Widget> topBar() {
    return [
      IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          _close();
        },
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListTile(
          key: ValueKey(data.provider.name),
          contentPadding: EdgeInsets.zero,
          subtitle: Text(
            data.provider.name,
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
                              .open(Media(e.url, httpHeaders: data.headers))
                              .then((value) {
                            player.state.copyWith(position: pos);
                            Future.delayed(
                                    const Duration(seconds: 1, milliseconds: 5))
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
          icon: const Icon(Icons.closed_caption),
          tooltip: "Captions",
          itemBuilder: (context) => data.runtimeType != Null &&
                  data.subtitles.runtimeType != Null
              ? data.subtitles
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
                          if (e["label"] == currentCaption || e["file"] == "") {
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
                  .cast<PopupMenuItem>()
              : []),
      PopupMenuButton(
        icon: const Icon(Icons.more_vert_outlined),
        itemBuilder: (context) => providers
            .map((e) => PopupMenuItem(
                  child: Text(e.getProviderName()),
                  onTap: () async {
                    _setSource(selectedProvider: e);
                  },
                ))
            .toList()
            .cast<PopupMenuItem>(),
      ),
    ];
  }

  List<Widget> movementControl() {
    return [
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
      IconButton(
        onPressed: () {
          player.seek(player.state.position + const Duration(seconds: 90));
        },
        icon: const Icon(
          Icons.air_rounded,
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
      ),
    ];
  }

  Widget videobody() {
    return Scaffold(
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




