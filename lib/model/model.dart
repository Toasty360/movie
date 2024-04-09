class Movie {
  final String id;
  final String title;
  // final String episodeId;
  final String description;
  final String image;
  final String cover;
  final String type;
  final String rating;
  final String releaseDate;
  final String geners;
  // final double duration;
  final int totalEpisodes;

  final List<Seasons> seasons;

  Movie(
      this.id,
      this.title,
      // this.episodeId,
      this.description,
      this.image,
      this.cover,
      this.type,
      this.rating,
      this.releaseDate,
      this.geners,
      this.totalEpisodes,
      // this.duration,
      this.seasons);

  static Movie fromJSON(dynamic json) {
    return Movie(
      json["id"],
      json["title"],
      json["description"],
      json["image"],
      json["cover"],
      json["type"],
      json["rating"].toString(),
      json["releaseDate"],
      json["geners"].toString().replaceAll(RegExp(r'[]'), ""),
      json["totalEpisodes"] ?? 1,
      json["seasons"] != null
          ? json["seasons"]
              .map((e) => Seasons.fromJSON(e))
              .toList()
              .cast<Seasons>()
          : [],
    );
  }
}

class Seasons {
  final int season;
  final String image;
  final String cover;
  final List<Episode> episodes;

  Seasons(this.season, this.image, this.cover, this.episodes);

  static Seasons fromJSON(dynamic json) {
    return Seasons(
        json["season"],
        json["image"]["mobile"],
        json["image"]["hd"],
        json["episodes"]
            .map((e) => Episode.fromJSON(e))
            .toList()
            .cast<Episode>());
  }
}

class Episode {
  String id;
  String? title;
  int? episode;
  int? season;
  String? releaseDate;
  String? description;
  String? image;
  String? cover;

  Episode(
      {required this.id,
      this.title,
      this.episode,
      this.season,
      this.releaseDate,
      this.description,
      this.cover,
      this.image});

  static Episode fromJSON(dynamic json) {
    return Episode(
      id: json["id"] ?? "",
      title: json["title"],
      episode: json["episode"],
      season: json["season"],
      releaseDate: json["releaseDate"] ?? "",
      description: json["description"],
      image: json["img"] != null ? json["img"]["mobile"] : "",
      cover: json["img"] != null ? json["img"]["hd"] : "",
    );
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

  static HomeData fromJson(json) {
    // print(json);
    return HomeData(
        json["id"],
        json["original_title"] ?? json["title"] ?? json["name"],
        json["media_type"],
        json["overview"],
        "https://www.themoviedb.org/t/p/original/${json["poster_path"]}",
        "https://www.themoviedb.org/t/p/original/${json["backdrop_path"]}",
        json["popularity"].toString(),
        json["release_date"] ?? "");
  }
}
