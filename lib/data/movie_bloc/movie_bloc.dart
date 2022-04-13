import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_caching/data/services/hive_database.dart';
import 'package:offline_caching/models/movie.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final HiveDatabase hiveDatabase;
  MovieBloc({required this.hiveDatabase}) : super(MovieLoading()) {
    on<LoadMovies>(_onLoadMovies);
    on<AddMovie>(_onAddMovie);
    on<UpdateMovie>(_onUpdateMovie);
    on<DeleteMovie>(_onDeleteMovie);
    on<DeleteAllMovies>(_onDeleteAllMovies);
  }

  Future<void> _onLoadMovies(
    LoadMovies event,
    Emitter<MovieState> emit,
  ) async {
    // ensure box is opened
    Future<void>.delayed(const Duration(seconds: 1));
    Box<Movie> box = await hiveDatabase.openBox();

    // load movies as a list and emit them back
    List<Movie> movies = await hiveDatabase.getMovies(box);
    emit(MovieLoaded(movies: movies));
  }

  Future<void> _onAddMovie(
    AddMovie event,
    Emitter<MovieState> emit,
  ) async {
    if (state is MovieLoaded) {
      Box<Movie> box = await hiveDatabase.openBox();
      await hiveDatabase.addMovie(box, event.movie);
      emit(MovieLoaded(movies: await hiveDatabase.getMovies(box)));
    }
  }

  Future<void> _onUpdateMovie(
    UpdateMovie event,
    Emitter<MovieState> emit,
  ) async {
    if (state is MovieLoaded) {
      Box<Movie> box = await hiveDatabase.openBox();
      await hiveDatabase.updateMovie(box, event.movie);

      // emit new version of data
      emit(MovieLoaded(movies: await hiveDatabase.getMovies(box)));
    }
  }

  Future<void> _onDeleteMovie(
    DeleteMovie event,
    Emitter<MovieState> emit,
  ) async {
    if (state is MovieLoaded) {
      Box<Movie> box = await hiveDatabase.openBox();
      await hiveDatabase.deleteMovie(box, event.movie);
      emit(MovieLoaded(movies: await hiveDatabase.getMovies(box)));
    }
  }

  Future<void> _onDeleteAllMovies(
    DeleteAllMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (state is MovieLoaded) {
      Box<Movie> box = await hiveDatabase.openBox();
      await hiveDatabase.deleteAllMovies(box);
      emit(MovieLoaded(movies: await hiveDatabase.getMovies(box)));
    }
  }
}
