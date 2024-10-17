import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/service_provider.dart';

class Catflix extends ServiceProvider {
  final String baseUrl = "https://catflix.su/";
  final String juiceUrl = "https://turbovid.eu/api/cucked/juice_key";
  final Dio dio = Dio();

  String _decryptHexWithKey(String hex, String key) {
    final binary = hexToBinary(hex);
    return xorDecrypt(binary, key);
  }

  String hexToBinary(String hex) {
    String binary = '';
    for (int i = 0; i < hex.length; i += 2) {
      binary +=
          String.fromCharCode(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return binary;
  }

  String xorDecrypt(String binary, String key) {
    return String.fromCharCodes(
      List.generate(binary.length, (i) {
        return binary.codeUnitAt(i) ^ key.codeUnitAt(i % key.length);
      }),
    );
  }

  @override
  Future<MediaData> getSource(int id, bool isMovie,
      {int? season, int? episode, String? title = ""}) async {
    var catid = title!
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
    var url = isMovie ? 'movies/$catid' : "series/$catid-${season}x$episode";
    try {
      final iframeResponse = await dio.get('$baseUrl/$url',
          options: Options(
            validateStatus: (status) => true,
          ));
      final String iframeUrl = RegExp(r'<iframe.*?src\s*=\s*"(.*?)"')
          .firstMatch(iframeResponse.data)!
          .group(1)!;

      final options = Options(
        headers: {'Referer': iframeUrl},
        validateStatus: (status) => true,
      );

      final multipleResp = await Future.wait([
        dio.get(juiceUrl, options: options),
        dio.get(iframeUrl, options: options)
      ]);

      final String apkey = RegExp(r'apkey\s*=\s*"(.*?)"')
          .firstMatch(multipleResp[1].data)!
          .group(1)!;
      final String xxid = RegExp(r'xxid\s*=\s*"(.*?)"')
          .firstMatch(multipleResp[1].data)!
          .group(1)!;

      final theJuiceResponse = await dio.get(
        'https://turbovid.eu/api/cucked/the_juice/?$apkey=$xxid',
        options: options,
      );

      return MediaData(
          src: _decryptHexWithKey(jsonDecode(theJuiceResponse.data)["data"],
              jsonDecode(multipleResp[0].data)["juice"]),
          qualities: [],
          headers: {'Origin': baseUrl, "referer": iframeUrl.split('embed')[0]},
          subtitles: [],
          provider: SrcProvider.CatFlix);
    } catch (e) {
      throw Exception("Failed to extract Catflix");
    }
  }

  @override
  String getProviderName() => 'Catflix';
}
