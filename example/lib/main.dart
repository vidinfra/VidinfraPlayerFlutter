import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/models.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/vidinfra_player_view.dart';

void main() {
  runApp(
    MaterialApp(
      home: const HomePage(title: 'Vidinfra Player Flutter SDK'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00FFDD)),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
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
  String url = "";
  String secret = "";

  void playVideo() {
    try {
      if (url.isEmpty) throw ArgumentError("Url must be provided");

      controller.setupAESAuth(secret: secret);
      controller.play(Media(url: url));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: Column(
      children: [
        VidinfraPlayerView(controller: controller, aspectRatio: 16 / 9),
        Expanded(
          child: ListView(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 8),
            children: [
              TextFormField(
                initialValue: url,
                decoration: InputDecoration(labelText: "Video URL"),
                onChanged: (value) => url = value,
              ),
              TextFormField(
                initialValue: secret,
                decoration: InputDecoration(labelText: "Secret"),
                onChanged: (value) => secret = value,
              ),
              Wrap(
                children: [
                  ElevatedButton(onPressed: playVideo, child: Text("Play")),
                ],
              ),

              ValueListenableBuilder(
                valueListenable: controller.kController.state.error,
                builder: (context, value, child) => Text(value ?? ""),
              ),
            ].map((e) => Padding(padding: spacing, child: e)).toList(),
          ),
        ),
      ],
    ),
  );

  final spacing = EdgeInsets.symmetric(vertical: 8);
}
