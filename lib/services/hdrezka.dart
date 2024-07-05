import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:movie/model/model.dart';

const String base = 'https://hdrezka.me/';
Dio dio = Dio();

Map<String, String> getData(String x) {
  Map<String, String> v = {
    "file3_separator": "//_//",
    "bk0": r"$$#!!@#!@##",
    "bk1": r"^^^!@##!!##",
    "bk2": r"####^!!##!@@",
    "bk3": r"@@@@@!##!^^^",
    "bk4": r"$$!!@$$@^!@#$$@",
  };
  String a = x.substring(2).replaceAll("\\", "");
  for (int i = 4; i >= 0; i--) {
    if (v['bk$i'] != null) {
      a = a.replaceAll(
        '${v['file3_separator']}${base64.encode(
          utf8.encode(
            Uri.encodeComponent(v['bk$i']!).replaceAllMapped(
              RegExp(r'%([0-9A-F]{2})'),
              (match) =>
                  String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
            ),
          ),
        )}',
        '',
      );
    }
  }
  try {
    a = utf8.decode(base64.decode(a));
    RegExp regex = RegExp(r'\[(.*?)\](https?://[^\s]+)');
    return Map.fromEntries(regex
        .allMatches(a)
        .map((match) => MapEntry(match.group(1)!, match.group(2)!)));
  } catch (e) {
    print("got error: ");
    return {};
  }
}

Future<Map> fetchByBruteForce(String url) async {
  String x = await dio.get(url).then((value) => value.data);
  return getData(RegExp(r'"streams":"(.*?)"').firstMatch(x)!.group(1) ?? "");
}

Future<Map> hdrezka(Episode episode) async {
  Map<String, dynamic> params;
  if (episode.type != 'movie') {
    params = {
      'id': episode.id,
      'translator_id': 238,
      'season': episode.season,
      'episode': episode.episode,
      'action': 'get_stream',
    };
  } else {
    params = {
      'id': episode.id,
      'translator_id': 238,
      'action': 'get_movie',
    };
  }
  print("test params $params");
  try {
    Response response = await dio.post(
      'https://hdrezka.me/ajax/get_cdn_series/?t=${DateTime.now().millisecondsSinceEpoch}',
      data: FormData.fromMap(params),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return {'Sources': getData(data['url']), 'subtitle': data['subtitle']};
    } else {
      return {};
    }
  } catch (e) {
    return {};
  }
}

Future<Map> getIds(String q, String year, String type) async {
  print("test $q , $year, $type");
  type = type.toLowerCase();
  final v = await (await dio.get(
          "https://hdrezka.me/search/?do=search&subaction=search&q=$q",
          options: Options(followRedirects: false)))
      .data;
  final doc = parse(v);
  print(doc.querySelectorAll(".b-content__inline_item").length);
  var item =
      doc.querySelectorAll(".b-content__inline_item").firstWhere((element) {
    print(element.text);
    return element
            .querySelector(".b-content__inline_item-link > div")!
            .text
            .contains(year) &&
        type ==
            (element.querySelector('span.info').runtimeType != Null
                ? "tv"
                : "movie");
  });
  return {"id": item.attributes["data-id"], "url": item.attributes["data-url"]};
}
