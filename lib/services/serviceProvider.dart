import 'package:movie/model/model.dart';

abstract class ServiceProvider {
  Future<MediaData> getSource(
    int id,
    bool isMovie, {
    int? season,
    int? episode,
  });
  String getProviderName();
}
