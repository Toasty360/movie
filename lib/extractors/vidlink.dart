import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' as fatty;
// import 'package:flutter/foundation.dart';
import 'package:movie/model/model.dart';
import 'package:movie/model/service_provider.dart';
import 'package:encrypt/encrypt.dart';

class CryptoMethods {
  static Key key = Key.fromBase16(
      "5e25af7f72103edbb72ab2b45144b812279181551546acee2d998cc2796169dd");

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
  Future<MediaData> getSource(int id, bool isMovie,
      {int? season, int? episode, String? title}) async {
    if (!fatty.kIsWeb) {
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
    } else {
      var resp = await (await Dio().get(
              "https://val-movieapi.vercel.app/vidlink/watch?isMovie=$isMovie&id=$id&season=$season&episode=$episode"))
          .data;
      return MediaData(
          src: resp["stream"]["playlist"],
          subtitles: [],
          provider: SrcProvider.VidLink,
          headers: {},
          qualities: []);
    }
  }

  @override
  String getProviderName() => 'Embed.su';
}
