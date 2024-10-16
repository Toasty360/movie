import 'package:movie/extractors/catflix.dart';
import 'package:movie/extractors/vidlink.dart';
import 'package:movie/extractors/vidsrcNet.dart';
import 'package:movie/extractors/vidsrcPro.dart';
import 'package:movie/model/model.dart';

abstract class ServiceProvider {
  Future<MediaData> getSource(int id, bool isMovie,
      {int? season, int? episode, String? title});
  String getProviderName();
}

final List<ServiceProvider> providers = [
  VidsrcNet(),
  VidLink(),
  Catflix(),
  VidsrcPro(),
];
