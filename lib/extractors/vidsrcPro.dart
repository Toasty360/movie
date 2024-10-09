import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:movie/main.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/serviceProvider.dart';

class VidsrcPro implements ServiceProvider {
  String vidSrcBaseURL = "http://embed.su";

  VidsrcPro() {
    if (MySettings.box.containsKey("vidsrc.pro")) {
      vidSrcBaseURL = MySettings.box.get("alpha")!;
    } else {
      MySettings.box.put("alpha", vidSrcBaseURL);
    }
  }

  // List<Quality> _extractQualityAndLinks(String m3u8Content) {
  //   final lines = m3u8Content.split("\n");
  //   final List<Quality> results = [];
  //   try {
  //     for (var i = 0; i < lines.length; i++) {
  //       if (lines[i].startsWith("#EXT-X-STREAM-INF")) {
  //         final resolutionMatch =
  //             RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(lines[i]);
  //         final urlMatch = lines[i + 1].contains("http")
  //             ? RegExp(r'\?url=(.*)').firstMatch(lines[i + 1])?.group(1)
  //             : lines[i + 1];
  //         if (resolutionMatch != null && urlMatch != null) {
  //           final resolution = resolutionMatch.group(1)?.split("x").last;
  //           var url = Uri.decodeComponent(urlMatch);
  //           if (!url.startsWith("http")) {
  //             url =
  //                 "https://${url.split("base=").last}${url.split("viper").last.split(".png")[0]}";
  //           }
  //           results.add(
  //               Quality(resolution: resolution ?? "Unknown Quality", url: url));
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("got Error");
  //   }
  //   return results;
  // }

  @override
  Future<MediaData> getSource(
    int id,
    bool isMovie, {
    int? season,
    int? episode,
  }) async {
    try {
      final dio = Dio();
      // print(
      //     "$vidSrcBaseURL/embed/${isMovie ? 'movie/$id' : 'tv/$id/$season/$episode'}"
      //         .split(":"));
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
      String defaultsrc = sourceData['source'];
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
