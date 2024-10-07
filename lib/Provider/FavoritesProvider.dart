import 'package:flutter/material.dart';
import 'package:movie_app3/Model/model.dart';
import '../DataBase/DataBase.dart';

class FavoritesProvider with ChangeNotifier {
  List<Movie> _favoriteMovies = [];
  bool _isLoading = false;


  List<Movie> get favoriteMovies => _favoriteMovies;
  bool get isLoading => _isLoading;


  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final movies = await DatabaseHelper.instance.getMovies();
      _favoriteMovies = movies;
    } catch (e) {
      print('Error loading favorite movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(Movie movie) async {
    try {
      await DatabaseHelper.instance.insertMovie(movie);
      _favoriteMovies.add(movie);
      notifyListeners();
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(int movieId) async {
    _isLoading=true;
    notifyListeners();
    await DatabaseHelper.instance.deleteMovie(movieId);
    _favoriteMovies.removeWhere((movie) => movie.id == movieId);
    _isLoading=false;
    notifyListeners();
  }

  bool isFavorite(Movie movie) {
    return _favoriteMovies.any((fav) => fav.id == movie.id);
  }
}
