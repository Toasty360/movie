import 'dart:convert';
import 'package:dio/dio.dart';

Future<Map> getLinks(String id) async {
  try {
    Dio dio = Dio();
    Response response = await dio.get("https://flixtor.to$id");
    String? cookie = response.headers.map['set-cookie']?.join('; ');
    String movieID = id.split("/").reversed.toList()[1];
    String url =
        "https://flixtor.to/ajax/v4/m/$movieID?_=${DateTime.now().millisecondsSinceEpoch}";
    Options options = Options(
      headers: {
        'Referer': 'https://flixtor.to/$id',
        'X-Requested-With': 'XMLHttpRequest',
        'Cookie': cookie!,
      },
    );
    Response gResponse = await dio.get(url, options: options);
    String g = gResponse.data;
    String replaced = g.replaceAllMapped(
      RegExp("[a-zA-Z]"),
      (match) {
        String e = match.group(0)!;
        var newCharCode = 0;
        if ('Z'.codeUnitAt(0) >= e.codeUnitAt(0)) {
          newCharCode = e.codeUnitAt(0) + 13;
          if (newCharCode > 'Z'.codeUnitAt(0)) {
            newCharCode -= 26;
          }
        } else {
          newCharCode = e.codeUnitAt(0) + 13;
          if (newCharCode > 'z'.codeUnitAt(0)) {
            newCharCode -= 26;
          }
        }
        return String.fromCharCode(newCharCode);
      },
    );
    String base64Decoded = utf8.decode(base64Url.decode(replaced));
    String uriEscaped = Uri.encodeComponent(base64Decoded);
    var h = Uri.decodeComponent(uriEscaped);
    List<String> l = [];
    for (int m = 0; m < h.length; m++) {
      int p = h.codeUnitAt(m);
      l.add(
        (33 <= p && 126 >= p)
            ? String.fromCharCode(33 + ((p + 14) % 94))
            : String.fromCharCode(p),
      );
    }
    return jsonDecode(l.join(""));
  } catch (e) {
    print('Error: $e');
  }
  return {};
}

void main() async {
  print(await getLinks("/watch/movie/46112786/godzilla-x-kong-the-new-empire"));
}
