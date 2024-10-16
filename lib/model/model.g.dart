// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 2;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      fields[0] as String,
    )
      ..title = fields[1] as String?
      ..logo = fields[2] as String?
      ..description = fields[3] as String?
      ..image = fields[4] as String?
      ..cover = fields[5] as String?
      ..type = fields[6] as String?
      ..rating = fields[7] as String?
      ..releaseDate = fields[8] as String?
      ..geners = (fields[9] as List?)?.cast<dynamic>()
      ..totalEpisodes = fields[10] as int?
      ..totalSeasons = fields[11] as int?
      ..seasons = (fields[12] as List?)?.cast<Seasons>();
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.logo)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.cover)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.releaseDate)
      ..writeByte(9)
      ..write(obj.geners)
      ..writeByte(10)
      ..write(obj.totalEpisodes)
      ..writeByte(11)
      ..write(obj.totalSeasons)
      ..writeByte(12)
      ..write(obj.seasons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeasonsAdapter extends TypeAdapter<Seasons> {
  @override
  final int typeId = 1;

  @override
  Seasons read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Seasons(
      fields[0] as int,
      fields[1] as String?,
      fields[3] as String,
    )..episodes = (fields[2] as List?)?.cast<Episode>();
  }

  @override
  void write(BinaryWriter writer, Seasons obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.season)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.episodes)
      ..writeByte(3)
      ..write(obj.overview);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 0;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      id: fields[0] as int,
      title: fields[2] as String?,
      type: fields[1] as String,
      episode: fields[3] as int?,
      season: fields[4] as int?,
      releaseDate: fields[5] as String?,
      description: fields[6] as String?,
      cover: fields[8] as String?,
      image: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.episode)
      ..writeByte(4)
      ..write(obj.season)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.image)
      ..writeByte(8)
      ..write(obj.cover);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
