import 'package:flutter/material.dart';
import '../Model/model.dart';
import '../DataBase/DataBase.dart';

class WatchedProvider with ChangeNotifier {
  List<Movie> _watchedMovies = [];
  bool _isLoading = false;

  List<Movie> get watchedMovies => _watchedMovies;
  bool get isLoading => _isLoading;

  Future<void> loadWatchedMovies() async {
    _isLoading = true;
    notifyListeners();
    try {
      final movies = await DatabaseHelper.instance.getWatchedMovies();
      _watchedMovies = movies;
    } catch (e) {
      print('Error loading watched movies: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWatched(Movie movie) async {
    try {
      await DatabaseHelper.instance.insertMovie(movie);
      await DatabaseHelper.instance.addWatchedMovie(movie.id);
      _watchedMovies.add(movie);
      notifyListeners();
    } catch (e) {
      print('Error adding watched movie: $e');
    }
  }

  Future<void> removeWatched(int movieId) async {
    _isLoading = true;
    notifyListeners();
    await DatabaseHelper.instance.removeWatchedMovie(movieId);
    _watchedMovies.removeWhere((movie) => movie.id == movieId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWatched(Movie movie) async {
    if (isWatched(movie)) {
      await removeWatched(movie.id);
    } else {
      await addWatched(movie);
    }
  }

  bool isWatched(Movie movie) {
    return _watchedMovies.any((watched) => watched.id == movie.id);
  }
}