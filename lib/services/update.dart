import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> checkForUpdates() async {
  const currentVersion = 'v1.0.0';

  // GitHub API request to get the latest release
  final response = await Dio()
      .get('https://api.github.com/repos/Toasty360/movie/releases/latest');

  if (response.statusCode == 200) {
    final release = response.data;
    final latestVersion = release['tag_name'];
    if (latestVersion != currentVersion) {
      final downloadUrl = release['assets'][0]['browser_download_url'];
      print('New version available: $latestVersion');
      print('Download here: $downloadUrl');
      // You can now prompt the user to download and install the new version
    } else {
      print('App is up-to-date');
    }
  } else {
    print('Failed to check for updates');
  }
}

downloadAndInstallUpdate(
    String url, String fileName, BuildContext context) async {
  final response = await Dio().get<Uint8List>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  final directory =
      await getApplicationDocumentsDirectory(); // or a temp directory
  final filePath = '${directory.path}/$fileName';

  // Write the downloaded file to disk
  final file = File(filePath);
  await file.writeAsBytes(response.data!.toList());
  // ignore: use_build_context_synchronously
  callPopup(context, filePath);
  print('Update downloaded to: $filePath');

  // You can now prompt the user to install the file manually or attempt an auto-install
}

callPopup(BuildContext context, String filePath) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update Available'),
      content: const Text(
          'A new version of the app is available. Would you like to install it?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            launchInstaller(filePath); // Proceed with installation
          },
          child: const Text('Install'),
        ),
      ],
    ),
  );
}

void launchInstaller(String filePath) {
  Process.start(filePath, []).then((Process process) {
    process.exitCode.then((exitCode) {
      if (exitCode == 0) {
        print('Update installation started successfully.');
      } else {
        print('Error launching the installer.');
      }
    });
  });
}
