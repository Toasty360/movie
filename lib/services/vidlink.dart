import 'package:dio/dio.dart';
import 'package:movie/main.dart';
import 'package:movie/model/model.dart';
import 'package:movie/services/serviceProvider.dart';

class VidLink implements ServiceProvider {
  String apiBaseUrl = "https://hugo.vidlink.pro";
  VidLink() {
    if (MySettings.box.containsKey("vidlink")) {
      apiBaseUrl = MySettings.box.get("vidlink")!;
    } else {
      MySettings.box.put("vidlink", apiBaseUrl);
    }
  }
  @override
  Future<MediaData> getSource(
    int id,
    bool isMovie, {
    int? season,
    int? episode,
  }) async {
    try {
      String url = isMovie
          ? "$apiBaseUrl/api/movie/$id"
          : "$apiBaseUrl/api/tv/$id/$season/$episode";
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'Referer': 'https://vidlink.pro/',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
          },
        ),
      );
      print(response.data["stream"]['captions']);

      return MediaData(
          src: response.data["stream"]["playlist"],
          qualities: [],
          provider: SrcProvider.VidLink,
          referer: 'https://vidlink.pro/',
          subtitles: response.data["stream"]['captions']
              .map((e) => ({"label": e["language"], "file": e["url"]}))
              .toList());
    } catch (error) {
      print("Error fetching source from API: $error");
      throw Exception("Faild to extract from vidlink");
    }
  }
}
