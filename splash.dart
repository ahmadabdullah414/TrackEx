import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'home.dart'; // Replace if your home screen is in another file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideo;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video/splash.mp4");
    _initializeVideo = _controller.initialize().then((_) {
      _controller.play();
    });

    // Navigate after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder black background
          Container(color: Colors.black),

          // Video Player (only shows when ready)
          FutureBuilder(
            future: _initializeVideo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                // Return empty container instead of loading spinner
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
