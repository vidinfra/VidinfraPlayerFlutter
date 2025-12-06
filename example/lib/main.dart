import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/models.dart';
import 'package:vidinfra_player/controller/vidinfra_downloader.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/vidinfra_player_view.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(title: 'Vidinfra Player Flutter SDK'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00FFDD),
          brightness: Brightness.dark,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          strokeWidth: 2,
          color: Color(0xFF00FFDD),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            highlightColor: Color(0xFF00FFDD).withAlpha(69),
          ),
        ),
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

class _HomePageState extends State<HomePage> implements DownloadEventListener {
  final controller = VidinfraPlayerController();
  late final downloader = VidinfraDownloader();

  String url =
      "https://jaemlu16jl.tenbytecdn.com/aa2952e7-289d-4183-9601-9c3b567c0ead/playlist.m3u8";

  String secret =
      "3519307ccba541099e5167b87c60ae50565148413c2af5ef247248fbade90d8f";

  String sprite =
      "https://jaemlu16jl.tenbytecdn.com/aa2952e7-289d-4183-9601-9c3b567c0ead/sprite.vtt";

  void playVideo() {
    try {
      if (url.isEmpty) throw ArgumentError("Url must be provided");

      controller.setupAESAuth(secret: secret);
      controller.play(Media(title: url, url: url, spriteVttUrl: sprite));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> downloadVideo() async {
    try {
      if (url.isEmpty) throw ArgumentError("Url must be provided");
      downloader.setupAESAuth(secret: secret);

      await downloader.startDownloading(
        Media(title: url, url: url, spriteVttUrl: sprite),
        customIdentifier: url.split("/").last,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  PreferredSizeWidget? get appBar {
    if (controller.inFullScreen) return null;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    );
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
    downloader.addListener(this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: Column(
      children: [
        VidinfraPlayerView(controller: controller, aspectRatio: 16 / 9),
        if (!controller.inFullScreen)
          Expanded(
            child: ListView(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              children: [
                TextFormField(
                  initialValue: url,
                  decoration: InputDecoration(labelText: "Video URL"),
                  onChanged: (value) => url = value,
                ),
                TextFormField(
                  initialValue: sprite,
                  decoration: InputDecoration(labelText: "Sprite URL"),
                  onChanged: (value) => sprite = value,
                ),
                TextFormField(
                  initialValue: secret,
                  decoration: InputDecoration(labelText: "Secret"),
                  onChanged: (value) => secret = value,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(onPressed: playVideo, child: Text("Play")),
                    ElevatedButton(
                      onPressed: downloadVideo,
                      child: Text("Download"),
                    ),
                  ],
                ),

                ValueListenableBuilder(
                  valueListenable: controller.kController.state.error,
                  builder: (context, value, child) => Text(value ?? ""),
                ),

                Divider(),

                FutureBuilder(
                  future: downloader.getAllDownloadIds(),
                  builder: (context, snapshot) {
                    final ids = snapshot.data ?? [];
                    return Column(
                      spacing: 8,
                      children: [
                        if (ids.isNotEmpty)
                          TextButton(
                            onPressed: () => downloader.removeAll().then(
                              (value) => setState(() {}),
                            ),
                            child: Text("Remove All"),
                          ),
                        for (final id in ids)
                          FutureBuilder(
                            future: downloader.getDownloadStatus(id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return SizedBox();
                              final data = snapshot.requireData!;
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        LinearProgressIndicator(
                                          value: (data.progress ?? 0) / 100,
                                        ),
                                        Text(data.encode().toString()),
                                      ],
                                    ),
                                  ),
                                  if (data.status ==
                                      DownloadStatus.finished) ...{
                                    IconButton(
                                      onPressed: () {
                                        controller.play(
                                          Media(
                                            title: data.localUri!,
                                            url: data.localUri!,
                                            spriteVttUrl: downloader
                                                .localSpritePath(data.id!),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.play_arrow),
                                    ),
                                  },

                                  IconButton(
                                    onPressed: () {
                                      downloader.remove(data.id!);
                                    },
                                    icon: Icon(Icons.cancel),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ].map((e) => Padding(padding: spacing, child: e)).toList(),
            ),
          ),
      ],
    ),
  );

  final spacing = EdgeInsets.symmetric(vertical: 8);

  @override
  void onCompletion(String id, String location) {
    print("COMPLETE: $id $location");
    setState(() {});
  }

  @override
  void onError(String id, String error) {
    print("ERROR: $id $error");
    setState(() {});
  }

  @override
  void onProgress(String id, int progress) {
    print("PROGRESS: $id $progress");
    setState(() {});
  }

  @override
  void onRemoved(String id) {
    print("REMOVED: $id");
    setState(() {});
  }
}
