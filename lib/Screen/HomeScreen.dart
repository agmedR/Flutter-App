import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_app3/Screen/User.dart';
import 'package:movie_app3/Services/NetworkService.dart';
import '../Model/model.dart';
import '../Services/services.dart';
import 'MovieDetails.dart';
import 'SearchScreen.dart';
import 'SignUp.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;
  const HomeScreen({super.key, required this.isGuest});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> nowShowing;
  late Future<List<Movie>> upComing;
  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> topratedMovies;

  @override
  void initState() {
    nowShowing = APIservices().getNowShowing();
    upComing = APIservices().getUpComing();
    popularMovies = APIservices().getPopular();
    topratedMovies = APIservices().getTopRated();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movei App"),
        //leading: const Icon(Icons.menu),
       // centerTitle: true,
        actions:[
          IconButton(onPressed: (){Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen(isGuest: widget.isGuest,)),
          );
          }, icon: Icon(Icons.search_rounded)),
          SizedBox(width: 20),
          IconButton(onPressed: (){if(widget.isGuest){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("You're in Guest mode. Please sign up to access this page."),
                action: SnackBarAction(
                  label: 'Sign Up',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserPage()),
            );
          }
            }, icon: Icon(Icons.person)),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ConnectivityHandler(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "  Now Showing",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                  future: nowShowing,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final movies = snapshot.data!;
                    return CarouselSlider.builder(
                      itemCount: movies.length,
                      itemBuilder: (context, index, movieIndex) {
                        final movie = movies[index];
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDetailsPage(movie: movie,isGuest: widget.isGuest,),
                                ),
                                ).then((_){
                                  setState(() {});
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://image.tmdb.org/t/p/original${movie.backdrop_path}",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 0,
                              right: 0,
                              child: Text(
                                movie.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 1.7,
                        autoPlayInterval: const Duration(seconds: 5),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "  Up Coming Movies",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 250,
                  child: FutureBuilder(
                    future: upComing,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDetailsPage(movie: movie,isGuest: widget.isGuest),
                                    ),
                                    ).then((_){
                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    width: 180,
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            "https://image.tmdb.org/t/p/original${movie.backdrop_path}"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    movie.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            );
                          });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "  Popular Movies",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 250,
                  child: FutureBuilder(
                    future: popularMovies,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDetailsPage(movie: movie,isGuest: widget.isGuest),
                                    ),
                                    ).then((_){
                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    width: 180,
                                    margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            "https://image.tmdb.org/t/p/original${movie.backdrop_path}"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    movie.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            );
                          });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "  Top Rated Movies",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 250,
                  child: FutureBuilder(
                    future: topratedMovies,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDetailsPage(movie: movie,isGuest: widget.isGuest),
                                    ),
                                    ).then((_){
                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    width: 180,
                                    margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            "https://image.tmdb.org/t/p/original${movie.backdrop_path}"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    movie.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            );
                          });
                    },
                  ),
                ),

              ],
            ),
            noConnectionWidget: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No internet connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Please check your connection and try again'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}