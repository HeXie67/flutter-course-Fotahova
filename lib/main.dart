import 'package:flutter/material.dart';
import 'ui/screens/catalog_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Музыкальные альбомы',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFAFAFAF), // Серый фон
        useMaterial3: true,
      ),
      home: const MusicCatalogScreen(), 
    );
  }
}