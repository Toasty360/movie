import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:media_kit/media_kit.dart';
import 'package:movie/model/model.dart';
import 'package:movie/pages/home.dart';
import 'package:movie/services/tmdb.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  Future<List<HomeData>> trending = TMDB.fetchTopRated();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await MySettings.initiateHive();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Moviemate',
    darkTheme: ThemeData.dark(useMaterial3: true),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: Home(data: trending),
  ));
}

class MySettings {
  static late Box<String> _settings;

  static Future<void> initiateHive() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    _settings =
        await Hive.openBox<String>("settings", path: appDocumentDirectory.path);
  }

  static Box<String> get box => _settings;
}
