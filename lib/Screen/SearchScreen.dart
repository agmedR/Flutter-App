import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/SearchProvider.dart';
import '../Model/model.dart';
import 'MovieDetails.dart';

class SearchScreen extends StatefulWidget {
  final bool isGuest;
  const SearchScreen({Key? key, required this.isGuest}) :super(key: key);
  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Movies'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (query) {
                Provider.of<SearchProvider>(context, listen: false).searchMovies(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (searchProvider.error.isNotEmpty) {
                  return Center(child: Text(searchProvider.error));
                } else if (searchProvider.searchResults.isEmpty) {
                  return Center(child: Text('No results found'));
                } else {
                  return ListView.builder(
                    itemCount: searchProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      Movie movie = searchProvider.searchResults[index];
                      return ListTile(
                        leading: movie.poster_path != null
                            ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie.poster_path}',
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 50,
                          height: 75,
                          color: Colors.grey,
                          child: Icon(Icons.movie),
                        ),
                        title: Text(movie.title),
                        subtitle: Text(
                          movie.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDetailsPage(movie: movie,isGuest: widget.isGuest)));

                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}