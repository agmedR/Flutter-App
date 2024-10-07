import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/FavoritesProvider.dart';
import '../Provider/WatchedProvider.dart';
import '../Provider/WatchlistProvider.dart';
import '../Model/model.dart';
import 'package:intl/intl.dart';
import '../Services/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'SignUp.dart';


class MovieDetailsPage extends StatefulWidget {
  final Movie movie;
  final bool isGuest;

  const MovieDetailsPage({Key? key, required this.movie, required this.isGuest}) : super(key: key);
  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Movie? movieDetails;
  List<Cast> cast = [];
  List<Crew> crew = [];
  List<Review> reviews = [];
  List<Movie> similarMovies = [];
  String? trailerKey;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMovieData();
  }

  Future<void> _fetchMovieData() async {
    setState(() => isLoading = true);
    try {
      final apiService = APIservices();
      movieDetails = await apiService.getMovieDetails(widget.movie.id);
      final credits = await apiService.getMovieCredits(widget.movie.id);
      cast = (credits['cast'] as List<Cast>).where((person) => person.department == 'Acting').toList();
      crew = (credits['crew'] as List<Crew>).where((person) => person.department == 'Camera' || person.department == 'Directing' || person.department == 'Editing' || person.department == 'Lighting' || person.department == 'Production').toList();      reviews = await apiService.getMovieReviews(widget.movie.id);
      similarMovies = await apiService.getSimilarMovies(widget.movie.id);
      trailerKey = (await apiService.getMovieTrailer(widget.movie.id));
    } catch (e) {
      print('Error fetching movie data: $e');
      // Handle error (e.g., show error message to user)
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Details'),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (trailerKey != null) _buildTrailer(),
            _buildTabBar(),
            _buildTabBarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: trailerKey!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        ),
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(child: _buildDetailsTab()),
          _buildReviewsTab(),
          _buildSimilarMoviesTab(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Image.network(
          'https://image.tmdb.org/t/p/w500${movieDetails!.backdrop_path}',
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              Text(
                movieDetails!.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                _formatReleaseDate(movieDetails!.release_date), // Ensure releaseDate is correctly used
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                movieDetails!.overview,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  String _formatReleaseDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'Unknown'; // Handle cases where date might be null or empty
    }
    DateTime parsedDate = DateTime.parse(date); // Parse the string to DateTime
    return DateFormat('yyyy').format(parsedDate); // Format the DateTime object
  }

  Widget _buildActionButtons() {
    return Consumer3<WatchedProvider, WatchlistProvider, FavoritesProvider>(
      builder: (context, watchedProvider, watchlistProvider, favoritesProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionButton(
                Icons.visibility,
                watchedProvider.isWatched(movieDetails!) ? 'Watched' : 'Watch',
                    () {
                  if (widget.isGuest) {
                    // عرض Snackbar إذا كان المستخدم في وضع الضيف
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You're in Guest mode. Please sign up to add movies to your Watched list."),
                        action: SnackBarAction(
                          label: 'Sign Up',
                          onPressed: () {
                            // الانتقال إلى صفحة التسجيل
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    // تنفيذ الإجراء الأصلي إذا كان المستخدم مسجل دخول
                    if (watchedProvider.isWatched(movieDetails!)) {
                      watchedProvider.removeWatched(movieDetails!.id);
                    } else {
                      watchedProvider.addWatched(movieDetails!);
                      if (watchlistProvider.isInWatchlist(movieDetails!)) {
                        watchlistProvider.removeFromWatchlist(movieDetails!.id);
                      }
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.favorite,
                favoritesProvider.isFavorite(movieDetails!) ? 'Favorited' : 'Favorite',
                    () {
                  if (widget.isGuest) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You're in Guest mode. Please sign up to add movies to your Favorites."),
                        action: SnackBarAction(
                          label: 'Sign Up',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    if (favoritesProvider.isFavorite(movieDetails!)) {
                      favoritesProvider.removeFavorite(movieDetails!.id);
                    } else {
                      favoritesProvider.addFavorite(movieDetails!);
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.add,
                watchlistProvider.isInWatchlist(movieDetails!) ? 'In Watchlist' : 'Watchlist',
                    () {
                  if (widget.isGuest) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You're in Guest mode. Please sign up to add movies to your Watchlist."),
                        action: SnackBarAction(
                          label: 'Sign Up',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    if (watchlistProvider.isInWatchlist(movieDetails!)) {
                      watchlistProvider.removeFromWatchlist(movieDetails!.id);
                    } else {
                      watchlistProvider.addToWatchlist(movieDetails!);
                      if (watchedProvider.isWatched(movieDetails!)) {
                        watchedProvider.removeWatched(movieDetails!.id);
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[800],
        minimumSize: const Size(100, 36),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Details'),
        Tab(text: 'Reviews'),
        Tab(text: 'Similar'),
      ],
    );
  }


  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingAndVotes(),
          const SizedBox(height: 16),
          _buildGenres(),
          const SizedBox(height: 16),
          _buildCastAndCrew('Cast', cast),
          const SizedBox(height: 16),
          _buildCastAndCrew('Crew', crew),
        ],
      ),
    );
  }

  Widget _buildRatingAndVotes() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.yellow[700], size: 24),
        const SizedBox(width: 8),
        Text(
          '${movieDetails!.vote_average.toStringAsFixed(1)}/10',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        Icon(Icons.people, color: Colors.grey[400], size: 24),
        const SizedBox(width: 8),
        Text(
          '${movieDetails!.vote_count} votes',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGenres() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movieDetails!.genres.map((genre) => Chip(
        label: Text(genre.name),
        backgroundColor: Colors.grey[800],
        labelStyle: const TextStyle(color: Colors.white),
      )).toList(),
    );
  }

  Widget _buildCastAndCrew(String title, List<dynamic> people) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: people.map((person) => PersonCard(person: person)).toList(),
          ),
        ),
      ],
    );
  }
  Widget _buildReviewsTab() {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(review.author[0].toUpperCase()),
            backgroundColor: Colors.grey[800],
          ),
          title: Text(review.author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(review.content, style: const TextStyle(color: Colors.white70)),
        );
      },
    );
  }

  Widget _buildSimilarMoviesTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2/3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: similarMovies.length,
      itemBuilder: (context, index) {
        final movie = similarMovies[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsPage(movie: movie,isGuest: widget.isGuest),
              ),
            );
          },
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  'https://image.tmdb.org/t/p/w200${movie.poster_path}',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(movie.title, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}

class PersonCard extends StatelessWidget {
  final dynamic person;

  const PersonCard({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String role = '';
    if (person is Cast) {
      role = (person as Cast).character ?? '';
    } else if (person is Crew) {
      role = (person as Crew).job ?? '';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://image.tmdb.org/t/p/w200${person.profilePath ?? ''}'),
            radius: 30,
          ),
          const SizedBox(height: 8),
          Text(person.name, style: const TextStyle(color: Colors.white)),
          Text(role, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}
