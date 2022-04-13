import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_caching/models/movie.dart';

class HiveDatabase {
  final String _boxName = 'favorite_movies';

  Future<Box<Movie>> openBox() async {
    Box<Movie> box = await Hive.openBox(_boxName);
    return box;
  }

  // Retrieve
  List<Movie> getMovies(Box box) {
    List<Movie> movies = box.values.toList().cast<Movie>();
    return movies;
  }

  // Create
  void addMovie(Box box, Movie movie) async {
    await box.put(movie.id, movie);
  }

  // Update
  void updateMovie(Box box, Movie movie) async {
    await box.put(movie.id, movie);
  }

  // Delete
  void deleteMovie(Box box, Movie movie) async {
    await box.delete(movie.id);
  }

  // Delete All
  void deleteAllMovies(Box box) async {
    await box.clear();
  }
}
