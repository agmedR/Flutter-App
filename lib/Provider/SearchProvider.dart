import 'package:flutter/material.dart';
import '../Model/model.dart';
import '../Services/services.dart';

class SearchProvider extends ChangeNotifier {
  final APIservices _apiServices = APIservices();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _searchResults = await _apiServices.searchMovies(query);
    } catch (e) {
      _error = 'Failed to search movies: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _error = '';
    notifyListeners();
  }
}