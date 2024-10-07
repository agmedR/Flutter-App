import 'package:flutter/material.dart';
import '../Model/model.dart';
import '../DataBase/DataBase.dart';

class WatchlistProvider with ChangeNotifier {
  List<Movie> _watchlistMovies = [];
  bool _isLoading = false;

  List<Movie> get watchlistMovies => _watchlistMovies;
  bool get isLoading => _isLoading;

  Future<void> loadWatchlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      final movies = await DatabaseHelper.instance.getWatchlistMovies();
      _watchlistMovies = movies;
    } catch (e) {
      print('Error loading watchlist movies: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToWatchlist(Movie movie) async {
    try {
      await DatabaseHelper.instance.insertMovie(movie);
      await DatabaseHelper.instance.addWatchlistMovie(movie.id);
      _watchlistMovies.add(movie);
      notifyListeners();
    } catch (e) {
      print('Error adding movie to watchlist: $e');
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    _isLoading = true;
    notifyListeners();
    await DatabaseHelper.instance.removeWatchlistMovie(movieId);
    _watchlistMovies.removeWhere((movie) => movie.id == movieId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWatchlist(Movie movie) async {
    if (isInWatchlist(movie)) {
      await removeFromWatchlist(movie.id);
    } else {
      await addToWatchlist(movie);
    }
  }

  bool isInWatchlist(Movie movie) {
    return _watchlistMovies.any((watchlistMovie) => watchlistMovie.id == movie.id);
  }
}