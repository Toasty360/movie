import 'package:dio/dio.dart';
import '../model/model.dart';

class TMDB {
  static Map<int, Movie> bucket = {};
  static var apiDio = Dio(BaseOptions(headers: {
    "accept": "application/json",
    "Authorization":
        "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0NGYzYWQ5ZTBmN2Y1MDQ3N2NlODE5MzgzZjhlYzUxZCIsInN1YiI6IjY0YTY4MjZjMDM5OGFiMDBjYTIwN2RjNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.bjz5ilcldqN6GZPqjTsANgzJprPSOXJ-FYVWLv_dJZw"
  }));
  static Future<List<HomeData>> fetchTopRated({String page = "1"}) async {
    List<HomeData> data = [];

    Response v =
        await apiDio.get("https://api.themoviedb.org/3/trending/all/day");
    for (Map e in v.data["results"]) {
      try {
        data.add(HomeData.fromJson(e));
      } catch (error) {
        print("$error at ${e["title"]}");
      }
    }
    return data;
  }

  static Future<dynamic> fetchInfo(int id, String type) async {
    print("called info toasty-kun.vercel.app/meta/tmdb/info/$id?type=$type");
    Response v = await Dio()
        .get("https://valley-api.vercel.app/meta/tmdb/info/$id?type=$type",
            options: Options(
              validateStatus: (status) => true,
            ));

    return v.statusCode == 200 ? Movie.fromJSON(v.data) : "";
  }

  static Future<List<HomeData>> fetchSearchData(String text) async {
    Response v =
        await Dio().get("https://valley-api.vercel.app/meta/tmdb/$text");
    List<HomeData> data = [];
    for (Map e in v.data["results"]) {
      try {
        if (!(e["image"].toString().endsWith("null") ||
            e["image"].toString().endsWith("undefined"))) {
          data.add(HomeData.fromConsumet(e));
        }
      } catch (error) {
        print(error);
      }
    }
    return data;
  }

  static Future<Movie> fetchMovieDetails(int tmdbID, bool isTv) async {
    if (bucket.containsKey(tmdbID)) {
      print("in Bucket $tmdbID");
      return Future.delayed(Duration.zero).then((value) => bucket[tmdbID]!);
    }
    print("not in Bucket $tmdbID");

    final response = await apiDio.get(
        "https://api.themoviedb.org/3/${isTv ? "tv" : "movie"}/$tmdbID?language=en-US");
    final data = response.data;

    Movie item = Movie(tmdbID.toString())
      ..releaseDate = data["first_air_date"]
      ..title = data["name"]
      ..description = data["overview"]
      ..image = data["poster_path"].runtimeType != Null
          ? "https://media.themoviedb.org/t/p/w600_and_h900_bestv2${data["poster_path"]}"
          : "https://picsum.photos/seed/picsum/200/300"
      ..cover = data["backdrop_path"].runtimeType != Null
          ? "https://media.themoviedb.org/t/p/w1066_and_h600_bestv2${data["backdrop_path"]}"
          : "https://picsum.photos/seed/picsum/200/300";
    if (isTv) {
      item
        ..totalSeasons = data["number_of_seasons"]
        ..geners =
            (data["genres"] as List).map((e) => e["name"] as String).toList()
        ..seasons = data["seasons"]
            .map((e) {
              if ((!e["name"].contains("Specials")) &&
                  e["poster_path"] != null) {
                return Seasons(e["season_number"],
                    "https://media.themoviedb.org/t/p/w260_and_h390_bestv2${e["poster_path"]}")
                  ..episodes = [];
              }
            })
            .whereType<Seasons>()
            .toList();

      // Fetch seasons concurrently
      final seasonRequests = List.generate(
        item.totalSeasons!,
        (i) => apiDio.get(
            "https://api.themoviedb.org/3/tv/$tmdbID/season/${i + 1}?language=en-US"),
      );
      final seasonResponses = await Future.wait(seasonRequests);
      for (var i = 0; i < seasonResponses.length; i++) {
        for (var e in (seasonResponses[i].data['episodes'] as List)) {
          if (e["still_path"] != null) {
            item.seasons![i].episodes!.add(Episode.fromJSON(e));
          }
        }
      }
      // for (var res in seasonResponses) {
      //   print(res.data['episodes'].length);
      //   try {
      //     item.seasons![index].episodes = (res.data['episodes'] as List)
      //         .map((e) => Episode.fromJSON(e))
      //         .toList();
      //     index++;
      //   } catch (e) {
      //     print(e);
      //   }
      // }
    }
    print(item.seasons?.length);
    bucket[tmdbID] = item;
    print(item.geners);
    return item;
  }
}
//https://api.themoviedb.org/3/tv/76479?language=en-US
//https://api.themoviedb.org/3/tv/76479/season/1?language=en-US