import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:media_kit_video/media_kit_video.dart';

Widget getMediaControlls(VideoController controller, Widget child,
    List<Widget> topbar, List<Widget> bottomBar, BuildContext context) {
  MaterialDesktopVideoControlsThemeData desktop =
      MaterialDesktopVideoControlsThemeData(
    topButtonBar: topbar,
    bottomButtonBar: [
      const MaterialDesktopPlayOrPauseButton(),
      const MaterialDesktopVolumeButton(),
      const MaterialDesktopPositionIndicator(),
      const Spacer(),
      ...bottomBar,
      const MaterialDesktopFullscreenButton()
    ],
    shiftSubtitlesOnControlsVisibilityChange: true,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    displaySeekBar: true,
    seekBarThumbSize: 12,
    seekBarMargin: const EdgeInsets.only(bottom: 20),
    buttonBarButtonSize: 24.0,
    buttonBarButtonColor: Colors.white,
    bottomButtonBarMargin: const EdgeInsets.only(bottom: 25, left: 10),
    topButtonBarMargin: const EdgeInsets.symmetric(horizontal: 10),
  );
  MaterialVideoControlsThemeData mobile = MaterialVideoControlsThemeData(
      shiftSubtitlesOnControlsVisibilityChange: true,
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
      topButtonBar: topbar,
      bottomButtonBar: [
        const MaterialPlayOrPauseButton(),
        const MaterialPositionIndicator(),
        const Spacer(),
        ...bottomBar
      ]);
  if (Platform.isWindows) {
    return MaterialDesktopVideoControlsTheme(
        fullscreen: desktop, normal: desktop, child: child);
  } else {
    return MaterialVideoControlsTheme(
        normal: mobile, fullscreen: mobile, child: child);
  }
}
