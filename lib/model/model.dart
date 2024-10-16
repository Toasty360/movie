import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 2)
class Movie extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? logo;
  @HiveField(3)
  String? description;
  @HiveField(4)
  String? image;
  @HiveField(5)
  String? cover;
  @HiveField(6)
  String? type;
  @HiveField(7)
  String? rating;
  @HiveField(8)
  String? releaseDate;
  @HiveField(9)
  List? geners;
  @HiveField(10)
  int? totalEpisodes;
  @HiveField(11)
  int? totalSeasons;
  @HiveField(12)
  List<Seasons>? seasons;
  Movie(
    this.id,
  );

  static Movie fromJSON(dynamic json) {
    return Movie(json["id"])
      ..title = json["title"]
      ..description = json["description"]
      ..image = json["image"]
      ..cover = json["cover"]
      ..type = json["type"]
      ..rating = json["rating"].toString()
      ..releaseDate = json["releaseDate"]
      ..geners = json["geners"]
      ..totalEpisodes = json["totalEpisodes"]
      ..seasons = json["seasons"] != null
          ? json["seasons"]
              .map((e) => Seasons.fromJSON(e))
              .toList()
              .cast<Seasons>()
          : [];
  }

  @override
  String toString() {
    return 'Movie{tmdbID: $id, releaseDate: $releaseDate, title: $title, description: $description, image: $image, cover: $cover, totalSeasons: $totalSeasons, genres: $geners, seasons: $seasons}';
  }
}

@HiveType(typeId: 1)
class Seasons extends HiveObject {
  @HiveField(0)
  final int season;
  @HiveField(1)
  String? image;
  @HiveField(2)
  List<Episode>? episodes;
  @HiveField(3)
  String overview;

  Seasons(this.season, this.image, this.overview);

  static Seasons fromJSON(dynamic json) {
    return Seasons(
        json["season"],
        json["image"].runtimeType != Null
            ? json["image"]["mobile"]
            : json["img"]["mobile"],
        json["overview"])
      ..episodes = json["episodes"]
          .map((e) => Episode.fromJSON(e))
          .toList()
          .cast<Episode>();
  }

  @override
  String toString() {
    return 'Season{seasonNumber: $season, posterPath: $image, episodes: $episodes}';
  }
}

@HiveType(typeId: 0)
class Episode extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String type;
  @HiveField(2)
  String? title;
  @HiveField(3)
  int? episode;
  @HiveField(4)
  int? season;
  @HiveField(5)
  String? releaseDate;
  @HiveField(6)
  String? description;
  @HiveField(7)
  String? image;
  @HiveField(8)
  String? cover;

  Episode(
      {required this.id,
      this.title,
      required this.type,
      this.episode,
      this.season,
      this.releaseDate,
      this.description,
      this.cover,
      this.image});

  static Episode fromJSON(dynamic json) {
    return Episode(
      id: json["episode_number"],
      type: "tv",
      title: json["name"],
      episode: json["episode_number"],
      season: json["season_number"],
      releaseDate: json["air_date"] ?? "",
      description: json["overview"],
      image:
          "https://media.themoviedb.org/t/p/w454_and_h254_bestv2/${json["still_path"]}",
    );
  }

  @override
  String toString() {
    return 'id: $id, Episodenumber: $episode title: $title description: $description image: $image';
  }
}

class HomeData {
  final int id;
  final String title;
  final String description;
  final String type;
  final String image;
  final String cover;
  final String popularity;
  final String releaseDate;

  HomeData(this.id, this.title, this.type, this.description, this.image,
      this.cover, this.popularity, this.releaseDate);

  static HomeData fromConsumet(json) {
    return HomeData(
        json["id"],
        json["title"],
        json["type"].split(" ").first,
        json["description"] ?? "",
        json["image"],
        json["cover"] ?? "",
        json["popularity"] ?? json["rating"].toString(),
        json["releaseDate"]);
  }

  static HomeData fromJson(Map json) {
    // print(json);
    return HomeData(
        json["id"],
        json["title"] ?? json["original_title"] ?? json["name"],
        json["media_type"],
        json["overview"],
        "https://www.themoviedb.org/t/p/original/${json["poster_path"]}",
        "https://www.themoviedb.org/t/p/original/${json["backdrop_path"]}",
        json["popularity"].toString(),
        // json["release_date"] ?? json["first_air_date"] ?? ""
        (RegExp(r'^(\d{4})')
                    .firstMatch(
                        json["release_date"] ?? json["first_air_date"] ?? "")
                    ?.group(1) ??
                'No match')
            .trim());
  }
}

class MediaData {
  final String src;
  List<Quality> qualities;
  final Map<String, String> headers;
  List subtitles;
  SrcProvider provider;

  MediaData(
      {required this.src,
      required this.qualities,
      required this.headers,
      required this.subtitles,
      required this.provider});
}

class Quality {
  final String resolution;
  final String url;

  Quality({required this.resolution, required this.url});

  @override
  String toString() {
    return 'Resolution: $resolution, URL: $url';
  }
}

enum SrcProvider {
  VidsrcPro,
  VidsrcNet,
  VidLink,
  CatFlix,
  Embed2,
  none;
}
