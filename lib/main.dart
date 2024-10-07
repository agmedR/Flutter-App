import 'package:flutter/material.dart';
import 'package:movie_app3/Provider/FavoritesProvider.dart';
import 'package:movie_app3/Provider/WatchedProvider.dart';
import 'package:movie_app3/Provider/WatchlistProvider.dart';
import 'package:movie_app3/Screen/HomeScreen.dart';
import 'package:movie_app3/Screen/Login.dart';
import 'Provider/SearchProvider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MyApp()
  );

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> SearchProvider()),
        ChangeNotifierProvider(create: (_)=>FavoritesProvider()),
        ChangeNotifierProvider(create: (_)=>WatchedProvider()),
        ChangeNotifierProvider(create: (_)=>WatchlistProvider()),
      ],
      child: MaterialApp(
        title: 'Movie App',
        theme: ThemeData(
            primarySwatch: Colors.blue
        ),
        debugShowCheckedModeBanner: false,
        home:AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return HomeScreen(isGuest: false,);
    } else {
      return LoginScreen();
    }
  }
}


/*
****LogOut*****
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ),
  );
}*/
