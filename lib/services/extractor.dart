import 'dart:convert';
import 'package:dio/dio.dart';

var dio = Dio();
// String deobfstr(String d, String i) {
//   i = i.toString();
//   String s = "";
//   for (int j = 0; j < d.length; j += 2) {
//     s += String.fromCharCode(int.parse(d.substring(j, j + 2), radix: 16) ^
//         i.codeUnitAt((j / 2).floor() % i.length));
//   }
//   return s;
// }

Future<Map<String, dynamic>> videosrc(String i, {int attempt = 1}) async {
  try {
    var base = 'https://vidsrc.xyz/embed/$i';
    var r = await dio.get(base);

    var l = await dio
        .get(
          'http://vidsrc.stream${RegExp(r'vidsrc.stream(.*?)"').firstMatch(r.data!)!.group(1)!}',
          options: Options(headers: {
            'Referer': 'https://vidsrc.xyz/',
            "Cookie": "cf_clearance=;"
          }),
        )
        .then((r) => RegExp("(vidsrc.*?)'").firstMatch(r.data)!.group(1));
    var r3 = await dio.get('http://$l',
        options: Options(headers: {'Referer': 'https://vidsrc.xyz/'}));

    var m = base64.decode(
      RegExp(r'file:"(.*?)"')
          .firstMatch(r3.data!)!
          .group(1)!
          .replaceAllMapped(RegExp(r'\/\/\S+?='),
              (match) => '') // Remove everything from '//' to '='
          .substring(2)
          .replaceAll(RegExp(r'\/@#@\/[^=\/]+=='), '')
          .replaceAll('_', '/')
          .replaceAll('-', '+'),
    );
    dio.get(
        'https:${RegExp(r'pass_path.*?"(.*?)"').firstMatch(r3.data!)!.group(1)!}',
        options: Options(
          headers: {"Referer": "http://vidsrc.streams"},
          validateStatus: (status) => true,
        ));
    return {'src': utf8.decode(m), 'sub': ""};
  } catch (e) {
    print('fetching again');
    if (attempt < 5) {
      return await videosrc(i, attempt: attempt + 1);
    } else {
      return {'src': 'Not found!'};
    }
  }
}
