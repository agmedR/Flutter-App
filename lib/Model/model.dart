import 'dart:convert';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? release_date;
  final String? backdrop_path;
  final String? poster_path;
  final double vote_average;
  final int vote_count;
  final List<Genre> genres;
  final String? tagline;
  final int? runtime;
  final int? budget;
  final int? revenue;
  final String status;
  final String original_language;
  final double popularity;
  final List<ProductionCompany> production_companies;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.release_date,
    this.backdrop_path,
    this.poster_path,
    required this.vote_average,
    required this.vote_count,
    required this.genres,
    this.tagline,
    this.runtime,
    this.budget,
    this.revenue,
    required this.status,
    required this.original_language,
    required this.popularity,
    required this.production_companies,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? 'Unknown title',
      overview: map['overview'] ?? 'No overview available',
      release_date: map['release_date'] as String?,
      backdrop_path: map['backdrop_path'] as String?,
      poster_path: map['poster_path'] as String?,
      vote_average: (map['vote_average'] as num?)?.toDouble() ?? 0.0,
      vote_count: map['vote_count'] ?? 0,
      genres: (map['genres'] as List<dynamic>?)
          ?.map((genre) => Genre.fromMap(genre))
          .toList() ?? [],
      tagline: map['tagline'] as String?,
      runtime: map['runtime'] as int?,
      budget: map['budget'] as int?,
      revenue: map['revenue'] as int?,
      status: map['status'] ?? 'Unknown',
      original_language: map['original_language'] ?? 'Unknown',
      popularity: (map['popularity'] as num?)?.toDouble() ?? 0.0,
      production_companies: (map['production_companies'] as List<dynamic>?)
          ?.map((company) => ProductionCompany.fromMap(company))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'release_date': release_date,
      'backdrop_path': backdrop_path,
      'poster_path': poster_path,
      'vote_average': vote_average,
      'vote_count': vote_count,
      'genres': genres.map((genre) => genre.toMap()).toList(),
      'tagline': tagline,
      'runtime': runtime,
      'budget': budget,
      'revenue': revenue,
      'status': status,
      'original_language': original_language,
      'popularity': popularity,
      'production_companies': production_companies.map((company) => company.toMap()).toList(),
    };
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromMap(Map<String, dynamic> map) {
    return Genre(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Unknown genre',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ProductionCompany.fromMap(Map<String, dynamic> map) {
    return ProductionCompany(
      id: map['id'] ?? 0,
      logoPath: map['logo_path'] as String?,
      name: map['name'] ?? 'Unknown company',
      originCountry: map['origin_country'] ?? 'Unknown country',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'logo_path': logoPath,
      'name': name,
      'origin_country': originCountry,
    };
  }
}

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({required this.englishName, required this.iso6391, required this.name});

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'],
      iso6391: json['iso_639_1'],
      name: json['name'],
    );
  }
}

class MovieVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final int size;
  final String type;

  MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.size,
    required this.type,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      site: json['site'],
      size: json['size'],
      type: json['type'],
    );
  }
}

// models.dart

class Cast {
  final int id;
  final String name;
  final String? profilePath;
  final String? character;
  final String department;

  Cast({
    required this.id,
    required this.name,
    this.profilePath,
    this.character,
    required this.department,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'],
      department: json['known_for_department'],
    );
  }

}

class Crew {
  final int id;
  final String name;
  final String? profilePath;
  final String? job;
  final String department;

  Crew({
    required this.id,
    required this.name,
    this.profilePath,
    this.job,
    required this.department,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      job: json['job'],
      department: json['known_for_department'],
    );
  }
}

class Review {
  final String author;
  final String content;
  final String createdAt;

  Review({
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      author: map['author'] ?? 'Unknown author',
      content: map['content'] ?? 'No review content',
      createdAt: map['created_at'] ?? 'Unknown date',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'content': content,
      'created_at': createdAt,
    };
  }
}

class MovieImage {
  final String filePath;
  final double aspectRatio;
  final int width;
  final int height;

  MovieImage({
    required this.filePath,
    required this.aspectRatio,
    required this.width,
    required this.height,
  });

  factory MovieImage.fromJson(Map<String, dynamic> json) {
    return MovieImage(
      filePath: json['file_path'] ?? '',
      aspectRatio: (json['aspect_ratio'] as num).toDouble(),
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}
