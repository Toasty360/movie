// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'package:movie/model/model.dart';
// import 'package:movie/services/serviceProvider.dart';
// import 'package:movie/services/vidlink.dart';
// import 'package:movie/services/vidsrcNet.dart';
// import 'package:movie/services/vidsrcPro.dart';
// import 'package:toast/toast.dart';

// class Viewer extends StatefulWidget {
//   final Episode episode;

//   const Viewer({super.key, required this.episode});
//   @override
//   State<Viewer> createState() => _ViewerState();
// }

// class _ViewerState extends State<Viewer> {
//   late final player = Player(
//       configuration: const PlayerConfiguration(
//     vo: 'gpu',
//   ));

//   late final controller = VideoController(
//     player,
//     configuration: const VideoControllerConfiguration(
//         hwdec: 'auto-safe',
//         androidAttachSurfaceAfterVideoParameters: false,
//         enableHardwareAcceleration: true),
//   );
//   final List<ServiceProvider> providers = [
//     VidsrcNet(),
//     VidsrcPro(),
//     VidLink(),
//   ];
//   String currentQuality = "";
//   String currentCaption = "";
//   double playbackSpeed = 1;
//   MediaData data = MediaData(
//       provider: SrcProvider.none,
//       qualities: [],
//       referer: "",
//       src: "",
//       subtitles: []);
//   void _close() {
//     Navigator.pop(context);
//   }

//   List<Widget> topBar(Size screen) {
//     return [
//       IconButton(
//         icon: const Icon(
//           Icons.arrow_back,
//           color: Colors.white,
//         ),
//         onPressed: () {
//           _close();
//         },
//       ),
//       SizedBox(
//         width: screen.width * 0.6,
//         child: ListTile(
//           key: ValueKey(data.provider.name),
//           contentPadding: EdgeInsets.zero,
//           subtitle: Text(
//             data.provider.name,
//             style: const TextStyle(fontSize: 10),
//           ),
//           title: Text(widget.episode.title ?? "",
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16)),
//         ),
//       ),
//       const Spacer(),
//       PopupMenuButton(
//           icon: const Icon(Icons.bar_chart_rounded),
//           tooltip: "Quality",
//           itemBuilder: (context) => data.runtimeType != Null &&
//                   data.qualities.runtimeType != Null
//               ? data.qualities
//                   .map((e) => PopupMenuItem(
//                         child: Text(e.resolution),
//                         onTap: () {
//                           var pos = player.state.position;
//                           Toast.show(e.resolution);
//                           player
//                               .open(Media(e.url,
//                                   httpHeaders: {"Referer": data.referer}))
//                               .then((value) {
//                             player.state.copyWith(position: pos);
//                             Future.delayed(
//                                     const Duration(seconds: 1, milliseconds: 5))
//                                 .then((value) {
//                               player.seek(pos);
//                             });
//                           });
//                         },
//                       ))
//                   .toList()
//                   .cast<PopupMenuItem>()
//               : []),
//       PopupMenuButton(
//           icon: const Icon(Icons.closed_caption_rounded),
//           tooltip: "Captions",
//           itemBuilder: (context) => data.runtimeType != Null &&
//                   data.subtitles.runtimeType != Null
//               ? data.subtitles
//                   .map((e) => PopupMenuItem(
//                         child: Text(
//                           e["label"],
//                           style: TextStyle(
//                               color: e["file"] != ""
//                                   ? (e["label"] == currentCaption
//                                       ? Colors.green
//                                       : Colors.white)
//                                   : Colors.blue),
//                         ),
//                         onTap: () {
//                           if (e["label"] == currentCaption || e["file"] == "") {
//                             player.setSubtitleTrack(SubtitleTrack.no());
//                             currentCaption = "";
//                             Toast.show("Captions removed");
//                             setState(() {});
//                           } else {
//                             player
//                                 .setSubtitleTrack(SubtitleTrack.uri(e["file"],
//                                     language: e["label"], title: e["label"]))
//                                 .then((value) {
//                               setState(() {
//                                 Toast.show(e["label"]);
//                                 currentCaption = e["label"];
//                               });
//                             });
//                           }
//                         },
//                       ))
//                   .toList()
//                   .cast<PopupMenuItem>()
//               : []),
//       PopupMenuButton(
//         icon: const Icon(Icons.more_vert_outlined),
//         itemBuilder: (context) => providers
//             .map((e) => PopupMenuItem(
//                   child: Text(e.getProviderName()),
//                   onTap: () async {
//                     _setSource(selectedProvider: e);
//                   },
//                 ))
//             .toList()
//             .cast<PopupMenuItem>(),
//       ),
//     ];
//   }

//   void extractQualityAndLinks(String m3u8Content) {
//     String highestQualityUrl = "";
//     int highestQuality = 0;
//     final results = <Quality>[];

//     final lines = m3u8Content.split("\n");

//     for (var i = 0; i < lines.length - 1; i++) {
//       if (lines[i].startsWith("#EXT-X-STREAM-INF")) {
//         final resolution = RegExp(r'RESOLUTION=(\d+x\d+)')
//             .firstMatch(lines[i])
//             ?.group(1)
//             ?.split("x")
//             .last;
//         String url = lines[i + 1].startsWith("http")
//             ? lines[i + 1]
//             : Uri.decodeComponent(lines[i + 1]);
//         if (url.startsWith("?url=")) {
//           url = Uri.parse(url.split("?url=").last).toString();
//         } else if (!url.startsWith("http")) {
//           url =
//               "https://${url.split("base=").last}${url.split("viper").last.split(".png")[0]}";
//         }
//         if (resolution != null && int.parse(resolution) > highestQuality) {
//           highestQuality = int.parse(resolution);
//           highestQualityUrl = url;
//         }

//         results.add(Quality(resolution: resolution ?? 'Unknown', url: url));
//       }
//     }
//     if (mounted) {
//       Future.delayed(const Duration(seconds: 6)).then((value) {
//         print("test $value");
//         if (player.state.videoParams.aspect == null &&
//             highestQualityUrl.isNotEmpty &&
//             player.state.buffering) {
//           print(
//               "test fixed vidsrc.net playlist error with $highestQualityUrl $highestQuality ");
//           player.open(
//               Media(highestQualityUrl, httpHeaders: {"Referer": data.referer}));
//         }
//       });

//       setState(() {
//         data.qualities = [
//           ...results,
//           Quality(resolution: "Default", url: data.src)
//         ];
//       });
//     }
//   }

//   Future<void> _setSource({ServiceProvider? selectedProvider}) async {
//     List<ServiceProvider> providersToUse =
//         selectedProvider != null ? [selectedProvider] : providers;

//     for (ServiceProvider provider in providersToUse) {
//       if (!mounted) break;
//       try {
//         data = widget.episode.season == null
//             ? await provider.getSource(widget.episode.id, true)
//             : await provider.getSource(widget.episode.id, false,
//                 season: widget.episode.season, episode: widget.episode.episode);

//         if (!mounted) break;
//         player
//             .open(
//               Media(data.src, httpHeaders: {"Referer": data.referer}),
//               play: true,
//             )
//             .then((value) => setState(() {}));
//         print(data.provider.name);
//         if (data.qualities.isEmpty) {
//           try {
//             final response = await Dio().get(data.src,
//                 options: Options(headers: {"Referer": data.referer}));
//             extractQualityAndLinks(response.data);
//           } catch (e) {
//             print("Failed to extract quality and links: $e");
//           }
//         }

//         // Break out of the loop after a successful source is set
//         break;
//       } catch (e) {
//         Toast.show("${provider.runtimeType} failed to extract");
//         print("Error: $e, trying next source...");
//       }
//     }

//     // Check if no source was found
//     if (data.src.isEmpty) {
//       Toast.show("No sources available");
//       _close();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size screen = MediaQuery.of(context).size;
//     final isDesktop = !kIsWeb &&
//         (defaultTargetPlatform == TargetPlatform.windows ||
//             defaultTargetPlatform == TargetPlatform.macOS);
//     return CallbackShortcuts(
//         bindings: <ShortcutActivator, VoidCallback>{
//           const SingleActivator(LogicalKeyboardKey.escape): () {
//             Navigator.pop(context);
//           },
//           const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
//             player.seek(player.state.position - const Duration(seconds: 10));
//           },
//           const SingleActivator(LogicalKeyboardKey.arrowRight): () {
//             player.seek(player.state.position + const Duration(seconds: 10));
//           },
//           const SingleActivator(LogicalKeyboardKey.space): () {
//             player.playOrPause();
//           },
//         },
//         child: Focus(
//             autofocus: true, child: getThemeDataWidget(isDesktop, controller)));
//   }
// }

// Widget getThemeDataWidget(bool isDesktop, VideoController controller) {
//   return isDesktop
//       ? MaterialDesktopVideoControlsTheme(
//           normal: myDesktopThemeData,
//           fullscreen: myDesktopThemeData,
//           child: videoChild(controller))
//       : MaterialVideoControlsTheme(
//           normal: myMobileThemeData,
//           fullscreen: myMobileThemeData,
//           child: videoChild(controller),
//         );
// }

// MaterialVideoControlsThemeData myMobileThemeData =
//     const MaterialVideoControlsThemeData(
//         shiftSubtitlesOnControlsVisibilityChange: true,
//         brightnessGesture: true,
//         padding: EdgeInsets.symmetric(horizontal: 10),
//         volumeGesture: true,
//         displaySeekBar: true,
//         gesturesEnabledWhileControlsVisible: true,
//         seekGesture: true,
//         seekOnDoubleTap: true,
//         seekBarThumbSize: 12,
//         seekBarMargin: EdgeInsets.only(bottom: 20),
//         buttonBarButtonSize: 24.0,
//         buttonBarButtonColor: Colors.white,
//         bottomButtonBarMargin: EdgeInsets.only(bottom: 25, left: 10),
//         topButtonBarMargin: EdgeInsets.symmetric(horizontal: 10));

// MaterialDesktopVideoControlsThemeData myDesktopThemeData =
//     const MaterialDesktopVideoControlsThemeData(
//   shiftSubtitlesOnControlsVisibilityChange: true,
//   padding: EdgeInsets.symmetric(horizontal: 10),
//   displaySeekBar: true,
//   seekBarThumbSize: 12,
//   seekBarMargin: EdgeInsets.only(bottom: 20),
//   buttonBarButtonSize: 24.0,
//   buttonBarButtonColor: Colors.white,
//   bottomButtonBarMargin: EdgeInsets.only(bottom: 25, left: 10),
//   topButtonBarMargin: EdgeInsets.symmetric(horizontal: 10),
// );

// Widget videoChild(VideoController controller) => Scaffold(
//       backgroundColor: const Color.fromARGB(0, 0, 0, 0),
//       body: Video(
//         fit: kIsWeb ? BoxFit.fitWidth : BoxFit.fill,
//         controller: controller,
//         wakelock: true,
//         subtitleViewConfiguration: const SubtitleViewConfiguration(
//           style: TextStyle(
//             height: 1.4,
//             fontSize: 45.0,
//             letterSpacing: 0.0,
//             wordSpacing: 0.0,
//             color: Colors.yellow,
//             fontWeight: FontWeight.normal,
//           ),
//           textAlign: TextAlign.center,
//           padding: EdgeInsets.all(24.0),
//         ),
//       ),
//     );
