import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imageUrl;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool addedToWatchLater;

  const Movie({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.addedToWatchLater = false,
  });

  Movie copyWith({
    String? id,
    String? imageUrl,
    String? name,
    bool? addedToWatchLater,
  }) {
    return Movie(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      addedToWatchLater: addedToWatchLater ?? this.addedToWatchLater,
    );
  }
}
