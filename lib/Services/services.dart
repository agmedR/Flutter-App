import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/model.dart';

const apiKey = "7268c996d0e6ecb06e609a93e3b9259d";

class APIservices {
  final nowShowingApi = "https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey";

  final upComingApi = "https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey";

  final popularApi = "https://api.themoviedb.org/3/movie/popular?api_key=$apiKey";

  final searchApi = "https://api.themoviedb.org/3/search/movie?api_key=$apiKey";

  final topratedApi = "https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey";

  // for nowShowing moveis
  Future<List<Movie>> getNowShowing() async {
    Uri url = Uri.parse(nowShowingApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }

  // for up coming moveis
  Future<List<Movie>> getUpComing() async {
    Uri url = Uri.parse(upComingApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }

  // for popular moves
  Future<List<Movie>> getPopular() async {
    Uri url = Uri.parse(popularApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }

  // for top rated moves
  Future<List<Movie>> getTopRated() async {
    Uri url = Uri.parse(topratedApi);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to load data");
    }
  }

  // for searching movies
  Future<List<Movie>> searchMovies(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    Uri url = Uri.parse('$searchApi&query=$encodedQuery');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception("Failed to search movies");
    }
  }

  //for movie details
  Future<Movie> getMovieDetails(int movieId) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Movie.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  //for movie videos
  Future<String?> getMovieTrailer(int movieId) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey');

    final response = await http.get(url);
    final results = json.decode(response.body)['results'];
    final trailers = results.where((video) => video['type'] == 'Trailer').toList();
    return trailers.isNotEmpty ? trailers.first['key'] : null;
  }

  // Get Movie Credits (Cast & Crew)
  Future<Map<String, List>> getMovieCredits(int movieId) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      final List<dynamic> castList = jsonResponse['cast'];
      final List<dynamic> crewList = jsonResponse['crew'];

      List<Cast> cast = castList.map((cast) => Cast.fromJson(cast)).toList();
      List<Crew> crew = crewList.map((crew) => Crew.fromJson(crew)).toList();

      return {
        'cast': cast,
        'crew': crew,
      };
    } else {
      throw Exception('Failed to load movie credits');
    }
  }


  // Get Movie Reviews
  Future<List<Review>> getMovieReviews(int movieId) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/reviews?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> reviewList = json.decode(response.body)['results'];
      return reviewList.map((review) => Review.fromMap(review)).toList();
    } else {
      throw Exception('Failed to load movie reviews');
    }
  }

  // Get Similar Movies
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/similar?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception('Failed to load similar movies');
    }
  }

  // Get Movie Images
  Future<List<MovieImage>> getMovieImages(int movieId) async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/images?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> backdrops = json.decode(response.body)['backdrops'];
      return backdrops.map((image) => MovieImage.fromJson(image)).toList();
    } else {
      throw Exception('Failed to load movie images');
    }
  }
}