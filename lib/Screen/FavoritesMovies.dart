import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/model.dart';
import '../Provider/FavoritesProvider.dart';
import 'MovieDetails.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.loadFavorites();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final movies = favoritesProvider.favoriteMovies;

          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return movies.isEmpty
              ? const Center(child: Text('No favorite movies added yet.'))
              : ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return Dismissible(
                key: Key(movie.id.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _onRemove(context, movie);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      movie.poster_path != null
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsPage(movie: movie, isGuest: false,),
                            ),
                          );
                        },
                        child: Image.network(
                          "https://image.tmdb.org/t/p/original${movie.poster_path!}",
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        width: 100,
                        height: 150,
                        color: Colors.grey,
                        child: const Center(
                          child: Text('No Image'),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                movie.release_date ?? 'Unknown Release Date',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.overview,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onRemove(BuildContext context, Movie movie) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.removeFavorite(movie.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${movie.title} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            favoritesProvider.addFavorite(movie);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
