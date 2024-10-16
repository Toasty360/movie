import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/service_provider.dart';

class VidsrcPro implements ServiceProvider {
  String vidSrcBaseURL = "http://embed.su";

  @override
  Future<MediaData> getSource(
    int id,
    bool isMovie, {
    int? season,
    int? episode,
    String? title,
  }) async {
    try {
      final dio = Dio();

      final response = (await dio.get(
        "$vidSrcBaseURL/embed/${isMovie ? 'movie/$id' : 'tv/$id/$season/$episode'}",
        options: Options(
          headers: {'Referer': vidSrcBaseURL},
        ),
      ));

      final vConfigMatch =
          RegExp(r'window\.vConfig\s*=\s*(.*?);').firstMatch(response.data);
      if (vConfigMatch == null) throw 'Pattern not found';
      var data;
      if (vConfigMatch[1]!.startsWith("JSON")) {
        data = json.decode(utf8.decode(base64Decode(
            RegExp(r'\(`(.*)`\)').firstMatch(vConfigMatch[1]!)![1]!)));
      } else {
        data = json.decode(vConfigMatch.group(1)!);
      }

      String atobString = data['hash'].split('').reversed.join('');
      while (atobString.length % 4 != 0) {
        atobString += '=';
      }
      final List decodedHash =
          json.decode(utf8.decode(base64Decode(atobString)));
      final sourceHash = decodedHash[0]['hash'];
      final name = decodedHash[0]['name'];
      final sourceResponse = await dio.get(
        '$vidSrcBaseURL/api/e/$sourceHash',
        options: Options(
          headers: {
            'Referer': vidSrcBaseURL,
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
          },
        ),
      );
      if (sourceResponse.statusCode != 200) {
        throw Exception('Failed to get video source');
      }
      final sourceData = sourceResponse.data;
      String defaultsrc = "https:/${sourceData['source'].split(name).last}";
      return MediaData(
          src: defaultsrc,
          provider: SrcProvider.VidsrcPro,
          qualities: [],
          headers: {
            "Origin": vidSrcBaseURL,
            "referer": vidSrcBaseURL,
            "user-agent":
                "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0"
          },
          subtitles: sourceData['subtitles']);
    } catch (error) {
      throw Exception("Faild to extract from vidsrc.pro $error");
    }
  }

  @override
  String getProviderName() => 'Vidsrc.pro';
}
