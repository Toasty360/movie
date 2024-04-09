import 'package:dio/dio.dart';

import '../model/model.dart';

class TMDB {
  static Future<List<HomeData>> fetchTopRated({String page = "1"}) async {
    List<HomeData> data = [];

    Response v =
        await Dio().get("https://api.themoviedb.org/3/trending/all/day",
            options: Options(headers: {
              "accept": "application/json",
              "Authorization":
                  "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0NGYzYWQ5ZTBmN2Y1MDQ3N2NlODE5MzgzZjhlYzUxZCIsInN1YiI6IjY0YTY4MjZjMDM5OGFiMDBjYTIwN2RjNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.bjz5ilcldqN6GZPqjTsANgzJprPSOXJ-FYVWLv_dJZw"
            }));
    for (Map e in v.data["results"]) {
      data.add(HomeData.fromJson(e));
    }
    return data;
  }

  static Future<Movie> fetchInfo(int id, String type) async {
    print("called info toasty-kun.vercel.app/meta/tmdb/info/$id?type=$type");
    Response v = await Dio()
        .get("https://toasty-kun.vercel.app/meta/tmdb/info/$id?type=$type");
    return Movie.fromJSON(v.data);
  }

  static Future<List<HomeData>> fetchSearchData(String text) async {
    Response v =
        await Dio().get("https://toasty-kun.vercel.app/meta/tmdb/$text");
    List<HomeData> data = [];
    for (Map e in v.data["results"]) {
      if (!(e["image"].toString().endsWith("null") ||
          e["image"].toString().endsWith("undefined"))) {
        data.add(HomeData.fromConsumet(e));
      }
    }
    return data;
  }
}
