import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/vidinfra_player_view.dart';

void main() {
  runApp(
    MaterialApp(
      home: const HomePage(title: 'Vidinfra Player Flutter SDK'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00FFDD)),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = VidinfraPlayerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          VidinfraPlayerView(controller: controller, aspectRatio: 16 / 9),
        ],
      ),
    );
  }
}
