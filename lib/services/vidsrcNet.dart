import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:movie/main.dart';
import 'package:movie/model/model.dart';
import 'package:movie/services/serviceProvider.dart';

class VidsrcNet implements ServiceProvider {
  var vidSrcBaseURL = "https://vidsrc.net";
  VidsrcNet() {
    if (MySettings.box.containsKey("beta")) {
      vidSrcBaseURL = MySettings.box.get("beta")!;
    } else {
      MySettings.box.put("beta", vidSrcBaseURL);
    }
  }

  final Map decryptMethods = {
    "TsA2KGDGux": (String input) {
      final reversed = input.split('').reversed.join('');
      final base64String = reversed.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64.decode(base64String));
      return decoded.codeUnits.map((c) => String.fromCharCode(c - 7)).join();
    },
    "ux8qjPHC66": (String input) {
      final reversed = input.split('').reversed.join('');
      final hexPairs = List.generate(
          reversed.length ~/ 2, (i) => reversed.substring(i * 2, i * 2 + 2));
      final hexString = hexPairs
          .map((hex) => String.fromCharCode(int.parse(hex, radix: 16)))
          .join('');
      const key = 'X9a(O;FMV2-7VO5x;Ao:dN1NoFs?j,';
      return String.fromCharCodes(hexString.codeUnits
          .asMap()
          .entries
          .map((e) => e.value ^ key.codeUnitAt(e.key % key.length)));
    },
    "xTyBxQyGTA": (String input) {
      final reversed = input.split('').reversed.join('');
      final result =
          List.generate(reversed.length ~/ 2, (i) => reversed[i * 2]).join();
      return utf8.decode(base64.decode(result));
    },
    "IhWrImMIGL": (String input) {
      final reversed = input.split('').reversed.join('');
      final rot13 = reversed.codeUnits
          .map((c) => (c >= 65 && c <= 90)
              ? ((c - 65 + 13) % 26 + 65)
              : (c >= 97 && c <= 122)
                  ? ((c - 97 + 13) % 26 + 97)
                  : c)
          .map((c) => String.fromCharCode(c))
          .join();
      final finalReversed = rot13.split('').reversed.join('');
      return utf8.decode(base64.decode(finalReversed));
    },
    "o2VSUnjnZl": (String input) {
      final substitutionMap = {
        'x': 'a',
        'y': 'b',
        'z': 'c',
        'a': 'd',
        'b': 'e',
        'c': 'f',
        'd': 'g',
        'e': 'h',
        'f': 'i',
        'g': 'j',
        'h': 'k',
        'i': 'l',
        'j': 'm',
        'k': 'n',
        'l': 'o',
        'm': 'p',
        'n': 'q',
        'o': 'r',
        'p': 's',
        'q': 't',
        'r': 'u',
        's': 'v',
        't': 'w',
        'u': 'x',
        'v': 'y',
        'w': 'z',
        'X': 'A',
        'Y': 'B',
        'Z': 'C',
        'A': 'D',
        'B': 'E',
        'C': 'F',
        'D': 'G',
        'E': 'H',
        'F': 'I',
        'G': 'J',
        'H': 'K',
        'I': 'L',
        'J': 'M',
        'K': 'N',
        'L': 'O',
        'M': 'P',
        'N': 'Q',
        'O': 'R',
        'P': 'S',
        'Q': 'T',
        'R': 'U',
        'S': 'V',
        'T': 'W',
        'U': 'X',
        'V': 'Y',
        'W': 'Z'
      };
      return input.replaceAllMapped(
          RegExp(r'[xyzabcdefghijklmnopqrstuvwXYZABCDEFGHIJKLMNOPQRSTUVW]'),
          (match) => substitutionMap[match.group(0)]!);
    },
    "eSfH1IRMyL": (String input) {
      final reversed = input.split('').reversed.join('');
      final shifted =
          reversed.codeUnits.map((c) => String.fromCharCode(c - 1)).join();
      return List.generate(shifted.length ~/ 2,
              (i) => int.parse(shifted.substring(i * 2, i * 2 + 2), radix: 16))
          .map((code) => String.fromCharCode(code))
          .join();
    },
    "Oi3v1dAlaM": (String input) {
      final reversed = input.split('').reversed.join('');
      final base64String = reversed.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64.decode(base64String));
      return decoded.codeUnits.map((c) => String.fromCharCode(c - 5)).join();
    },
    "sXnL9MQIry": (String input) {
      const xorKey = 'pWB9V)[*4I`nJpp?ozyB~dbr9yt!_n4u';
      final hexDecoded = List.generate(
          input.length ~/ 2,
          (i) => String.fromCharCode(
              int.parse(input.substring(i * 2, i * 2 + 2), radix: 16))).join();
      final decrypted = hexDecoded.codeUnits
          .asMap()
          .entries
          .map((e) => String.fromCharCode(
              e.value ^ xorKey.codeUnitAt(e.key % xorKey.length)))
          .join();
      final shifted =
          decrypted.codeUnits.map((c) => String.fromCharCode(c - 3)).join();
      return utf8.decode(base64.decode(shifted));
    },
    "JoAHUMCLXV": (String input) {
      final reversed = input.split('').reversed.join('');
      final base64String = reversed.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64.decode(base64String));
      return decoded.codeUnits.map((c) => String.fromCharCode(c - 3)).join();
    },
    "KJHidj7det": (String input) {
      final decoded =
          utf8.decode(base64.decode(input.substring(10, input.length - 16)));
      const key = '3SAY~#%Y(V%>5d/Yg"\$G[Lh1rK4a;7ok';
      final extendedKey = key * (decoded.length ~/ key.length + 1);
      return List.generate(
          decoded.length,
          (i) => String.fromCharCode(
              decoded.codeUnitAt(i) ^ extendedKey.codeUnitAt(i))).join();
    }
  };

  List<Quality> extractQualityAndLinks(String m3u8Content) {
    final lines = m3u8Content.split("\n");
    final List<Quality> results = [];

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith("#EXT-X-STREAM-INF")) {
        final resolutionMatch =
            RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(lines[i]);
        final urlMatch = lines[i + 1].startsWith("http")
            ? lines[i + 1]
            : RegExp(r'\?url=(.*)').firstMatch(lines[i + 1])?.group(1);
        if (resolutionMatch != null && urlMatch != null) {
          final resolution = resolutionMatch.group(1)?.split("x").last;
          var url = Uri.decodeComponent(urlMatch);
          if (!url.startsWith("http")) {
            url =
                "https://${url.split("base=").last}${url.split("viper").last.split(".png")[0]}";
          }
          results.add(
              Quality(resolution: resolution ?? "Unknow Quality", url: url));
        }
      }
    }

    return results;
  }

  @override
  Future<MediaData> getSource(
    int id,
    bool isMovie, {
    int? season,
    int? episode,
  }) async {
    MediaData result;
    var url =
        '$vidSrcBaseURL/embed/${isMovie ? "movie?tmdb=$id" : "tv?tmdb=$id&season=$season&episode=$episode"}';
    print(url);
    try {
      final response = await Dio().get(url);
      final source = response.data;
      final urlRCP =
          'https:${RegExp(r'src="(.*?)"').firstMatch(source)!.group(1)!}';

      final urlPRORCPResponse =
          await Dio().get(urlRCP, options: Options(headers: {'Referer': url}));
      final urlPRORCP = urlRCP.split('rcp')[0] +
          RegExp(r"src.*'(.*?)'").firstMatch(urlPRORCPResponse.data)!.group(1)!;

      final encryptedURLResponse = await Dio()
          .get(urlPRORCP, options: Options(headers: {'Referer': urlRCP}));
      final node = parse(encryptedURLResponse.data)
          .querySelector("#reporting_content")!
          .nextElementSibling;
      result = MediaData(
          src: decryptMethods[node!.id]!(node.text),
          qualities: [],
          provider: SrcProvider.VidsrcNet,
          referer: urlRCP.split("rcp")[0],
          subtitles: []);
    } catch (e) {
      print(e);
      throw Exception("Vidsrc.xyz Faild to Extract");
    }
    return result;
  }
}
