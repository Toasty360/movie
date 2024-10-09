import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/serviceProvider.dart';
import 'package:encrypt/encrypt.dart';

class CryptoMethods {
  static Key key = Key.fromBase16(
      "9f8dff95f42e0b9823f16bef28d2ca76063ab987ddd1f69718638f280db2df45");

  static encode(String data) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return '${iv.base16}:${encrypted.base16}';
  }

  static decode(String encrypted) {
    final parts = encrypted.split(':');
    final iv = IV.fromBase16(parts[0]);
    final encryptedText = Encrypted.fromBase16(parts[1]);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt(encryptedText, iv: iv);
  }
}

class VidLink implements ServiceProvider {
  String baseURL = "https://vidlink.pro/api/";

  @override
  Future<MediaData> getSource(
    int id,
    bool isMovie, {
    int? season,
    int? episode,
  }) async {
    try {
      final encoded = CryptoMethods.encode(id.toString());

      final response = await Dio().get(baseURL +
          (isMovie ? 'movie/$encoded' : 'tv/$encoded/$season/$episode'));
      final data = jsonDecode(CryptoMethods.decode(response.data));

      return MediaData(
          src: data["stream"]["playlist"],
          qualities: [],
          provider: SrcProvider.VidLink,
          headers: {
            "referer": 'https://vidlink.pro/',
            "user-agent":
                "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0"
          },
          subtitles: data["stream"]['captions']
              .map((e) => ({"label": e["language"], "file": e["url"]}))
              .toList());
    } catch (error) {
      print("Error fetching source from API: $error");
      throw Exception("Faild to extract from vidlink");
    }
  }

  @override
  String getProviderName() => 'Vidlink';
}
