import 'package:leavo/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LeavoApp());
}

class LeavoApp extends StatelessWidget {
  const LeavoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// Remove the debug banner
      debugShowCheckedModeBanner: false,

      /// set the routes of the app      
      initialRoute: '/',
      routes: {
      '/': (context) => HomePage(),
      },
    );
  }
}