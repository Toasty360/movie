import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:movie/model/model.dart';
import 'package:movie/pages/home.dart';
import 'package:movie/services/tmdb.dart';

import 'package:path_provider/path_provider.dart';

// 07707883225-01

void main() async {
  Future<List<Movie>> trending = TMDB.fetchTopRated();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EpisodeAdapter());
  Hive.registerAdapter(SeasonsAdapter());
  Hive.registerAdapter(MovieAdapter());
  await WatchList.initiateHive();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent));
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

class WatchList {
  static late Box<Movie> _watchList;

  static Future<void> initiateHive() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    _watchList =
        await Hive.openBox<Movie>("watchlist", path: appDocumentDirectory.path);
  }

  static Box<Movie> get box => _watchList;
}


// class MySettings {
//   static late Box<String> _settings;

//   static Future<void> initiateHive() async {
//     final appDocumentDirectory = await getApplicationDocumentsDirectory();
//     _settings =
//         await Hive.openBox<String>("settings", path: appDocumentDirectory.path);
//   }

//   static Box<String> get box => _settings;
// }
