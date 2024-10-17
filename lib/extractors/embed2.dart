import 'package:dio/dio.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/service_provider.dart';

class Embed2 extends ServiceProvider {
  final baseUrl = "https://www.2embed.cc";

  parseScript(String iframe) {
    String evalF =
        RegExp(r'eval(\(f.*?)\)\)\)').allMatches(iframe).last.group(0)!;
    String p = RegExp(r'\[{.*?"(.*?)"}\]').firstMatch(evalF)![1]!;
    String acMatch =
        RegExp(r',([\d]+,[\d]+),').allMatches(evalF).last.group(1)!;
    List<String> ac = acMatch.split(",");

    List<String> k =
        evalF.split(acMatch).last.split(".")[0].replaceAll("'", "").split("|");

    int a = int.parse(ac[0]);
    int c = int.parse(ac[1]);
    String e(c) {
      return (c < a ? "" : e(c ~/ a)) +
          ((c %= a) > 35 ? String.fromCharCode(c + 29) : c.toRadixString(36));
    }

    while (c-- > 0) {
      if (k[c] != "") {
        var temp = RegExp(r'\b' + e(c) + r'\b');
        p = p.replaceAll(temp, k[c]);
      }
    }
    return p;
  }

  @override
  Future<MediaData> getSource(int id, bool isMovie,
      {int? season, int? episode, String? title = ""}) async {
    final url = isMovie ? "embed/$id" : "embedtv/$id&s=$season&e=$episode";
    print(url);
    final resp = await (await Dio().get("$baseUrl/$url",
            options: Options(
              validateStatus: (status) => true,
            )))
        .data;

    var iframeId = RegExp('''<iframe.*data-src=["'](.*?id=(.*?))["']''')
        .firstMatch(resp)?[2];

    final iframe = await (await Dio().get("https://uqloads.xyz/e/$iframeId",
            options: Options(
              validateStatus: (status) => true,
              headers: {
                "referer": baseUrl,
                "User-Agent":
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36",
              },
            )))
        .data;
    return MediaData(
        src: parseScript(iframe),
        qualities: [],
        headers: {"referer": baseUrl},
        subtitles: [],
        provider: SrcProvider.Embed2);
  }

  @override
  String getProviderName() => "2Embed";
}
