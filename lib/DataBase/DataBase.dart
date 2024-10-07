import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../Model/model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies(
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        release_date TEXT,
        backdrop_path TEXT,
        poster_path TEXT,
        vote_average REAL,
        vote_count INTEGER,
        genres TEXT,
        tagline TEXT,
        runtime INTEGER,
        budget INTEGER,
        revenue INTEGER,
        status TEXT,
        original_language TEXT,
        popularity REAL,
        production_companies TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE watched_movies(
        id INTEGER PRIMARY KEY,
        movie_id INTEGER,
        FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE watchlist_movies(
        id INTEGER PRIMARY KEY,
        movie_id INTEGER,
        FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Add new tables for watched and watchlist
      await db.execute('''
        CREATE TABLE watched_movies(
          id INTEGER PRIMARY KEY,
          movie_id INTEGER,
          FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE watchlist_movies(
          id INTEGER PRIMARY KEY,
          movie_id INTEGER,
          FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Map<String, dynamic> _movieToMap(Movie movie) {
    return {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'release_date': movie.release_date,
      'backdrop_path': movie.backdrop_path,
      'poster_path': movie.poster_path,
      'vote_average': movie.vote_average,
      'vote_count': movie.vote_count,
      'genres': jsonEncode(movie.genres.map((genre) => genre.toMap()).toList()),
      'tagline': movie.tagline,
      'runtime': movie.runtime,
      'budget': movie.budget,
      'revenue': movie.revenue,
      'status': movie.status,
      'original_language': movie.original_language,
      'popularity': movie.popularity,
      'production_companies': jsonEncode(movie.production_companies.map((company) => company.toMap()).toList()),
    };
  }

  Movie _mapToMovie(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      overview: map['overview'],
      release_date: map['release_date'],
      backdrop_path: map['backdrop_path'],
      poster_path: map['poster_path'],
      vote_average: map['vote_average'],
      vote_count: map['vote_count'],
      genres: (jsonDecode(map['genres']) as List).map((genre) => Genre.fromMap(genre)).toList(),
      tagline: map['tagline'],
      runtime: map['runtime'],
      budget: map['budget'],
      revenue: map['revenue'],
      status: map['status'],
      original_language: map['original_language'],
      popularity: map['popularity'],
      production_companies: (jsonDecode(map['production_companies']) as List).map((company) => ProductionCompany.fromMap(company)).toList(),
    );
  }
  // Existing methods...

  // New methods for watched movies
  Future<int> addWatchedMovie(int movieId) async {
    final db = await database;
    return await db.insert('watched_movies', {'movie_id': movieId});
  }

  Future<int> removeWatchedMovie(int movieId) async {
    final db = await database;
    return await db.delete('watched_movies', where: 'movie_id = ?', whereArgs: [movieId]);
  }

  Future<bool> isMovieWatched(int movieId) async {
    final db = await database;
    final result = await db.query(
      'watched_movies',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
    return result.isNotEmpty;
  }

  Future<List<Movie>> getWatchedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT movies.* FROM movies
      INNER JOIN watched_movies ON movies.id = watched_movies.movie_id
    ''');
    return List.generate(maps.length, (i) => _mapToMovie(maps[i]));
  }

  // New methods for watchlist movies
  Future<int> addWatchlistMovie(int movieId) async {
    final db = await database;
    return await db.insert('watchlist_movies', {'movie_id': movieId});
  }

  Future<int> removeWatchlistMovie(int movieId) async {
    final db = await database;
    return await db.delete('watchlist_movies', where: 'movie_id = ?', whereArgs: [movieId]);
  }

  Future<bool> isMovieInWatchlist(int movieId) async {
    final db = await database;
    final result = await db.query(
      'watchlist_movies',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
    return result.isNotEmpty;
  }

  Future<List<Movie>> getWatchlistMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT movies.* FROM movies
      INNER JOIN watchlist_movies ON movies.id = watchlist_movies.movie_id
    ''');
    return List.generate(maps.length, (i) => _mapToMovie(maps[i]));
  }

// Existing helper methods...

  Future<int> insertMovie(Movie movie) async {
    final db = await database;
    var existing = await db.query('movies', where: 'id = ?', whereArgs: [movie.id]);
    if (existing.isNotEmpty) {
      print('Movie already exists: ${movie.title}');
      return await db.update('movies', _movieToMap(movie), where: 'id = ?', whereArgs: [movie.id]);
    }
    return await db.insert('movies', _movieToMap(movie));
  }

  Future<List<Movie>> getMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movies');
    print('Fetched ${maps.length} movies from database');
    return List.generate(maps.length, (i) {
      print('Movie ${i + 1}: ${maps[i]['title']}');
      return _mapToMovie(maps[i]);
    });
  }

  Future<int> deleteMovie(int id) async {
    final db = await database;
    return await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Movie>> searchMovies(String title) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['%$title%'],
    );

    return List.generate(maps.length, (i) => _mapToMovie(maps[i]));
  }

  Future<bool> isMovieExists(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}


/*
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../Model/model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies(
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        release_date TEXT,
        backdrop_path TEXT,
        poster_path TEXT,
        vote_average REAL,
        vote_count INTEGER,
        genres TEXT,
        tagline TEXT,
        runtime INTEGER,
        budget INTEGER,
        revenue INTEGER,
        status TEXT,
        original_language TEXT,
        popularity REAL,
        production_companies TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Add new columns
      await db.execute('ALTER TABLE movies ADD COLUMN vote_count INTEGER');
      await db.execute('ALTER TABLE movies ADD COLUMN tagline TEXT');
      await db.execute('ALTER TABLE movies ADD COLUMN runtime INTEGER');
      await db.execute('ALTER TABLE movies ADD COLUMN budget INTEGER');
      await db.execute('ALTER TABLE movies ADD COLUMN revenue INTEGER');
      await db.execute('ALTER TABLE movies ADD COLUMN status TEXT');
      await db.execute('ALTER TABLE movies ADD COLUMN original_language TEXT');
      await db.execute('ALTER TABLE movies ADD COLUMN popularity REAL');
      await db.execute('ALTER TABLE movies ADD COLUMN production_companies TEXT');
    }
  }

  Future<int> insertMovie(Movie movie) async {
    final db = await database;
    var existing = await db.query('movies', where: 'id = ?', whereArgs: [movie.id]);
    if (existing.isNotEmpty) {
      print('Movie already exists: ${movie.title}');
      return await db.update('movies', _movieToMap(movie), where: 'id = ?', whereArgs: [movie.id]);
    }
    return await db.insert('movies', _movieToMap(movie));
  }

  Future<List<Movie>> getMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movies');
    print('Fetched ${maps.length} movies from database');
    return List.generate(maps.length, (i) {
      print('Movie ${i + 1}: ${maps[i]['title']}');
      return _mapToMovie(maps[i]);
    });
  }

  Future<int> deleteMovie(int id) async {
    final db = await database;
    return await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Movie>> searchMovies(String title) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['%$title%'],
    );

    return List.generate(maps.length, (i) => _mapToMovie(maps[i]));
  }

  Future<bool> isMovieExists(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  Map<String, dynamic> _movieToMap(Movie movie) {
    return {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'release_date': movie.releaseDate,
      'backdrop_path': movie.backdropPath,
      'poster_path': movie.posterPath,
      'vote_average': movie.voteAverage,
      'vote_count': movie.voteCount,
      'genres': jsonEncode(movie.genres.map((genre) => genre.toMap()).toList()),
      'tagline': movie.tagline,
      'runtime': movie.runtime,
      'budget': movie.budget,
      'revenue': movie.revenue,
      'status': movie.status,
      'original_language': movie.originalLanguage,
      'popularity': movie.popularity,
      'production_companies': jsonEncode(movie.productionCompanies.map((company) => company.toMap()).toList()),
    };
  }

  Movie _mapToMovie(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      overview: map['overview'],
      releaseDate: map['release_date'],
      backdropPath: map['backdrop_path'],
      posterPath: map['poster_path'],
      voteAverage: map['vote_average'],
      voteCount: map['vote_count'],
      genres: (jsonDecode(map['genres']) as List).map((genre) => Genre.fromMap(genre)).toList(),
      tagline: map['tagline'],
      runtime: map['runtime'],
      budget: map['budget'],
      revenue: map['revenue'],
      status: map['status'],
      originalLanguage: map['original_language'],
      popularity: map['popularity'],
      productionCompanies: (jsonDecode(map['production_companies']) as List).map((company) => ProductionCompany.fromMap(company)).toList(),
    );
  }
}*/
