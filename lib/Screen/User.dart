import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app3/Screen/Login.dart';
import 'package:provider/provider.dart';
import '../Provider/FavoritesProvider.dart';
import '../Provider/WatchedProvider.dart';
import '../Provider/WatchlistProvider.dart';
import 'FavoritesMovies.dart';
import 'WatchList.dart';
import 'Watched.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
    FirebaseAuth.instance.currentUser?.photoURL;
  }
  void _loadData(){
    Future.microtask((){
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
      Provider.of<WatchlistProvider>(context, listen: false).loadWatchlist();
      Provider.of<WatchedProvider>(context, listen: false).loadWatchedMovies();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildUserStatistics(context),
            const SizedBox(height: 20),
            _buildNavigationTile(
                context, 'Favorites', Icons.favorite, FavoritesPage()),
            _buildNavigationTile(
                context, 'Watchlist', Icons.bookmark, WatchListPage()),
            _buildNavigationTile(
                context, 'Watched', Icons.check_circle, WatcedPage()),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL??'https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(FirebaseAuth.instance.currentUser!.displayName??'Unknown User'
                , // Replace with the actual username
                style: const TextStyle(fontSize: 24, color: Colors.black),
              ),
              const SizedBox(height: 8),
               Text(FirebaseAuth.instance.currentUser?.email??'User@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatistics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatisticItem('Favorites', Provider.of<FavoritesProvider>(context).favoriteMovies.length),
          _buildStatisticItem('Watchlist', Provider.of<WatchlistProvider>(context).watchlistMovies.length),
          _buildStatisticItem('Watched', Provider.of<WatchedProvider>(context).watchedMovies.length),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNavigationTile(BuildContext context, String title, IconData icon, Widget routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.black12),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => routeName),
        );      },
    );
  }
}
