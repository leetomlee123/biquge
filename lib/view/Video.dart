import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _VideoState();
  }
}

class _VideoState extends State<Video> {
  ChewieController _chewieController;

//  final videoPlayerController = VideoPlayerController.network();
  final videoPlayerController = VideoPlayerController.network(
      'http://120.27.244.128/%E9%A3%8E%E6%9C%88%E6%B5%B7%E6%A3%A0%E6%9C%80%E6%96%B0%E9%AB%98%E6%B8%85%E7%B2%BE%E5%93%81%E7%AC%AC01%E5%AD%A3%EF%BC%9A%E5%A4%A7%E5%99%A8%E7%94%B7%E8%8D%89%E5%93%AD%E7%BE%8E%E8%89%B3%E5%B0%8F%E5%B0%91%E5%A6%87.mp4');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 2 / 2,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _chewieController.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('Video'),
    );
  }
}
