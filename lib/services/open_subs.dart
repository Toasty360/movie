import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';

const baseUrl = "https://rest.opensubtitles.org/search/";

var dio = Dio();

Future<String> loadSubtitles(String imdb, bool isMovie,
    {int? s, int? e}) async {
  try {
    var response = await dio.get(
        "${baseUrl}episode-$e/imdbid-${imdb.substring(2)}/season-$s/sublanguageid-eng",
        options: Options(headers: {
          "X-User-Agent": "trailers.to-UA",
        }));
    if (response.data.isEmpty) {
      throw Exception('No subtitles found');
    }
    var subs = response.data;
    var downloadLink = subs[0]["SubDownloadLink"];
    var zipResponse = await dio.get<Uint8List>(
      downloadLink,
      options: Options(responseType: ResponseType.bytes),
    );
    var bytes = zipResponse.data!;
    var decodedBytes = GZipDecoder().decodeBytes(bytes);

    String srtContent = utf8.decode(decodedBytes);
    return srtContent;
  } catch (e) {
    throw Exception("Faild to get subtitles");
  }
}
